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
# Credential handling: the password is never placed in curl's --user
# argument or interpolated into JSON. It is written to a 0700 netrc file
# consumed via --netrc-file, and the administrative-account request body
# is built with jq so quotes/backslashes in the password are escaped
# correctly. All temporary credential/request files are removed on exit.
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
set -eu

: "${ROOT_USER:?ROOT_USER must be set}"
: "${PING_IDENTITY_PASSWORD:?PING_IDENTITY_PASSWORD must be supplied by a Secret}"
: "${PF_ADMIN_PORT:?PF_ADMIN_PORT must be set}"

for _cmd in curl jq; do
    if ! command -v "${_cmd}" >/dev/null 2>&1; then
        echo "ERROR: ${_cmd} is required by the bootstrap sidecar." >&2
        exit 1
    fi
done

# Protected temporary files. umask 077 keeps them private while they
# exist; the EXIT trap removes them on every termination path.
_response_file=/tmp/flex-bootstrap-response
_request_file=/tmp/flex-bootstrap-request
_password_file=/tmp/flex-bootstrap-password
_auth_file=/tmp/flex-bootstrap-netrc
umask 077
printf '%s' "${PING_IDENTITY_PASSWORD}" > "${_password_file}"
printf 'machine localhost login %s password %s\n' "${ROOT_USER}" "${PING_IDENTITY_PASSWORD}" > "${_auth_file}"
cleanup() {
    rm -f "${_response_file}" "${_request_file}" "${_password_file}" "${_auth_file}"
}
trap cleanup EXIT HUP INT TERM

_api_status() {
    curl --insecure --silent --show-error --write-out '%{http_code}' \
        --output "${_response_file}" \
        --header 'X-XSRF-Header: PingFederate' "$@"
}

# Verify (authenticated) that the license agreement reports accepted.
_license_is_accepted() {
    _licenseStatus=$(_api_status --netrc-file "${_auth_file}" --request GET \
        "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/license/agreement")
    if test "${_licenseStatus}" != "200"; then
        echo "ERROR: license agreement verification returned HTTP ${_licenseStatus}." >&2
        return 1
    fi
    if ! jq -e '.accepted == true' "${_response_file}" >/dev/null 2>&1; then
        echo "ERROR: license agreement verification did not report accepted=true." >&2
        return 1
    fi
}

# Verify (authenticated) that the configured administrator exists and
# the supplied credentials work. Distinguishes a wrong-password Secret
# from "administrator already exists" before declaring success.
_admin_exists_with_credentials() {
    _adminStatus=$(_api_status --netrc-file "${_auth_file}" --request GET \
        "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/administrativeAccounts")
    if test "${_adminStatus}" != "200"; then
        echo "ERROR: authenticated administrator lookup returned HTTP ${_adminStatus}." >&2
        return 1
    fi
    if ! jq -e --arg username "${ROOT_USER}" \
        'if type == "array" then any(.[]?; .username == $username)
         elif (.items? | type) == "array" then any(.items[]?; .username == $username)
         else false end' "${_response_file}" >/dev/null 2>&1; then
        echo "ERROR: authenticated administrator lookup did not verify the configured administrator." >&2
        return 1
    fi
}

_configureAdmin() {
    echo "Accepting license agreement (if needed)..."
    _licenseCode=$(curl --insecure --silent --show-error --write-out '%{http_code}' \
        --output "${_response_file}" --request PUT --netrc-file "${_auth_file}" \
        --header 'X-XSRF-Header: PingFederate' \
        --header 'Content-Type: application/json' \
        --data-binary '{"accepted":true}' \
        "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/license/agreement")
    case "${_licenseCode}" in
        200|204)
            echo "License accepted."
            ;;
        401|403|409)
            echo "License acceptance returned HTTP ${_licenseCode}; verifying the endpoint state..."
            _license_is_accepted
            echo "License already accepted."
            ;;
        *)
            echo "ERROR ${_licenseCode} accepting license; inspect the endpoint and license state." >&2
            return 1
            ;;
    esac

    echo "Creating initial administrator (if needed)..."
    jq -n --arg username "${ROOT_USER}" --rawfile password "${_password_file}" \
        '{username:$username,password:($password | rtrimstr("\n")),description:"Initial administrator user.",auditor:false,active:true,roles:["ADMINISTRATOR","USER_ADMINISTRATOR","CRYPTO_ADMINISTRATOR","EXPRESSION_ADMINISTRATOR","DATA_COLLECTION_ADMINISTRATOR"]}' \
        > "${_request_file}"
    # PingFederate can report the heartbeat before the administrative-account
    # resource has finished initializing. Retry only that transient validation
    # response; other failures remain fatal and the response body stays private.
    _adminCode=422
    _adminAttempt=0
    while test "${_adminAttempt}" -lt 12 && test "${_adminCode}" = "422"; do
        _adminCode=$(_api_status --request POST \
            --netrc-file "${_auth_file}" \
            --header 'Content-Type: application/json' \
            --data-binary "@${_request_file}" \
            "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/administrativeAccounts")
        if test "${_adminCode}" = "422"; then
            _adminAttempt=$((_adminAttempt + 1))
            if test "${_adminAttempt}" -lt 12; then
                echo "Administrator endpoint is still initializing (attempt ${_adminAttempt}/12); retrying in 5s..."
                sleep 5
            fi
        fi
    done
    case "${_adminCode}" in
        200|201|204)
            echo "Administrator created."
            ;;
        401)
            echo "Administrator creation returned 401; verifying the configured credentials..."
            _admin_exists_with_credentials
            echo "Administrator already exists and credentials were verified."
            ;;
        409)
            echo "Administrator already created by another node."
            ;;
        *)
            echo "ERROR ${_adminCode} creating administrator; inspect the Admin API response without printing it." >&2
            return 1
            ;;
    esac
}

echo "Waiting for PingFederate admin API..."
curl --insecure --silent --show-error --fail --netrc-file "${_auth_file}" \
    --retry-connrefused --retry 9999 --retry-delay 5 --retry-max-time 900 \
    -o /dev/null "https://localhost:${PF_ADMIN_PORT}/pf/heartbeat.ping"

if test "${OPERATIONAL_MODE:-STANDALONE}" != "CLUSTERED_CONSOLE"; then
    _configureAdmin || exit 1
else
    echo "Checking whether this node needs to seed the cluster..."
    _seedCheckCode=$(_api_status --netrc-file "${_auth_file}" --output "${_response_file}" "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/cluster/status")
    _needsSeed="false"
    if test "${_seedCheckCode}" = "403"; then
        _notLicensed=$(jq -r 'if .resultId == "license_agreement_not_accepted" then "true" else "false" end' "${_response_file}" 2> /dev/null)
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
        _statusCode=$(_api_status --netrc-file "${_auth_file}" --output "${_response_file}" "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/cluster/status")
        if test "${_statusCode}" = "200"; then
            _activeCount=$(jq -r '[.nodes[]? | select(.adminConsoleInfo.consoleRole == "ACTIVE")] | length' "${_response_file}" 2> /dev/null)
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
        _promoteCode=$(_api_status --netrc-file "${_auth_file}" --request POST --output "${_response_file}" "https://localhost:${PF_ADMIN_PORT}/pf-admin-api/v1/cluster/adminNode/role/active")
        if test "${_promoteCode}" != "200"; then
            echo "ERROR ${_promoteCode} promoting to active; inspect the Admin API response without printing it." >&2
            exit 1
        fi
        echo "Promoted to active admin."
    fi
fi

touch /tmp/flex-bootstrap-ready
echo "Bootstrap complete."
sleep infinity
