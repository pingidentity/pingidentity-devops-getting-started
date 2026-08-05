#!/bin/sh
# Copyright © 2026 Ping Identity Corporation
#
# PingFederate flex-image bootstrap sidecar.
#
# The PingFederate "flex" image ships no DevOps hook-script system, so
# nothing in the image itself accepts the license agreement, creates the
# initial administrator user, or promotes an admin node to ACTIVE in a
# cluster. This script performs that bootstrap over the admin API once
# PingFederate is up, mirroring what the legacy image's
# 80-post-start.sh/81-after-start-process.sh/83-configure-admin.sh hooks
# did. Bulk-config import is intentionally not done here: unlike
# license-accept/admin-create, it is not safely re-runnable from a
# read-only ConfigMap mount without an explicit "already imported" guard.
#
# Requires: curl, jq (both present on pingidentity/pingtoolkit).
#
# Required environment variables:
#   ROOT_USER              admin username to create/use
#   PING_IDENTITY_PASSWORD admin password (from the release's devops secret)
#   PF_ADMIN_PORT          the admin console's HTTPS container port
# Optional:
#   OPERATIONAL_MODE       STANDALONE (default) or CLUSTERED_CONSOLE. Must
#                          match whatever PF_RUN_pf_operational_mode
#                          resolves to for this pod - this variable only
#                          controls this script's own behavior, it does
#                          not itself set PF's operational mode.
#
# In CLUSTERED_CONSOLE mode, requires cluster-admin-nodes-sync.conf
# (enabled=true) and a jgroups.properties with DNS_PING or TCPPING
# discovery configured to be delivered via configMapVolumes -
# PF_CLUSTER_ADMIN_NODES_SYNC_ENABLED does NOT work on that file in flex.
# Without working discovery, every admin pod self-promotes ACTIVE
# (split-brain).
#
# The retry budget below (900s) is tied to the flex startupProbe window
# (failureThreshold: 90 * periodSeconds: 10 = 900s) - if that probe
# changes, update this number to match, or this sidecar will give up
# heartbeat-waiting while PF is still legitimately starting.
set -e

echo "Waiting for PingFederate admin API..."
curl --retry-connrefused --retry 9999 --retry-delay 5 --retry-max-time 900 -sS -k -o /dev/null "https://localhost:${PF_ADMIN_PORT}/pf/heartbeat.ping"

_pfCurl() {
    curl --insecure --silent --write-out '%{http_code}' --user "${ROOT_USER}:${PING_IDENTITY_PASSWORD}" --header 'X-XSRF-Header: PingFederate' "$@"
}

_configureAdmin() {
    echo "Accepting license agreement (if needed)..."
    _licenseCode=$(curl --insecure --silent --write-out '%{http_code}' --output /tmp/license.out --request PUT --header 'X-XSRF-Header: PingFederate' --header 'Content-Type: application/json' --data '{"accepted":true}' "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/license/agreement")
    case "${_licenseCode}" in
        200) echo "License accepted." ;;
        401) echo "License already accepted (administrator exists)." ;;
        403) echo "License already accepted." ;;
        *)
            echo "ERROR ${_licenseCode} accepting license:"
            cat /tmp/license.out
            return 1
            ;;
    esac

    echo "Creating initial administrator (if needed)..."
    _adminCode=$(curl --insecure --silent --write-out '%{http_code}' --output /tmp/admin.out --request POST --header 'X-XSRF-Header: PingFederate' --header 'Content-Type: application/json' --data "{\"username\":\"${ROOT_USER}\",\"password\":\"${PING_IDENTITY_PASSWORD}\",\"description\":\"Initial administrator user.\",\"auditor\":false,\"active\":true,\"roles\":[\"ADMINISTRATOR\",\"USER_ADMINISTRATOR\",\"CRYPTO_ADMINISTRATOR\",\"EXPRESSION_ADMINISTRATOR\",\"DATA_COLLECTION_ADMINISTRATOR\"]}" "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/administrativeAccounts")
    case "${_adminCode}" in
        200) echo "Administrator created." ;;
        401) echo "Administrator already exists." ;;
        409) echo "Administrator already created by another node." ;;
        *)
            echo "ERROR ${_adminCode} creating administrator:"
            cat /tmp/admin.out
            return 1
            ;;
    esac
}

if test "${OPERATIONAL_MODE:-STANDALONE}" != "CLUSTERED_CONSOLE"; then
    _configureAdmin || exit 1
else
    echo "Checking whether this node needs to seed the cluster..."
    _seedCheckCode=$(_pfCurl --output /tmp/seedcheck.out "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/cluster/status")
    _needsSeed="false"
    if test "${_seedCheckCode}" = "403"; then
        _notLicensed=$(jq -r 'if .resultId == "license_agreement_not_accepted" then "true" else "false" end' /tmp/seedcheck.out 2> /dev/null)
        test "${_notLicensed}" = "true" && _needsSeed="true"
    fi
    if test "${_needsSeed}" = "true"; then
        echo "Node is unseeded. Running initial admin setup."
        _configureAdmin || exit 1
    else
        echo "Cluster already seeded."
    fi

    echo "Querying cluster for an existing active admin node..."
    _activeCount="0"
    _queryAttempt=0
    while test "${_queryAttempt}" -lt 10; do
        _statusCode=$(_pfCurl --output /tmp/cluster.status "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/cluster/status")
        if test "${_statusCode}" = "200"; then
            _activeCount=$(jq -r '[.nodes[]? | select(.adminConsoleInfo.consoleRole == "ACTIVE")] | length' /tmp/cluster.status 2> /dev/null)
            _activeCount="${_activeCount:-0}"
            test "${_activeCount}" != "0" && break
        fi
        _queryAttempt=$((_queryAttempt + 1))
        if test "${_queryAttempt}" -lt 10; then
            echo "No active admin found yet (attempt ${_queryAttempt}/10). Retrying in 3s..."
            sleep 3
        fi
    done

    if test "${_activeCount}" != "0"; then
        echo "Active admin already present. This node remains passive."
    else
        echo "No active admin in cluster. Promoting this node to active."
        _promoteCode=$(_pfCurl --request POST --output /tmp/promote.out "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/cluster/adminNode/role/active")
        if test "${_promoteCode}" != "200"; then
            echo "ERROR ${_promoteCode} promoting to active:"
            cat /tmp/promote.out
            exit 1
        fi
        echo "Promoted to active admin."
    fi
fi

touch /tmp/flex-bootstrap-ready
echo "Bootstrap complete."
sleep infinity
