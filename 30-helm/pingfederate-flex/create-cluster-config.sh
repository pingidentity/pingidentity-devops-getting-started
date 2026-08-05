#!/usr/bin/env sh
# Copyright © 2026 Ping Identity Corporation
#
# Creates the pingfederate-cluster-config ConfigMap used by
# 02-clustered.yaml. The chart does not generate this ConfigMap itself
# (see the comment at the top of 02-clustered.yaml), so it must be created
# before installing that example - the jgroups.properties DNS_PING
# dns_query value must match the actual admin cluster headless Service
# FQDN exactly, or the admin console pods will not discover each other
# and every pod will self-promote ACTIVE (split-brain).

test "${VERBOSE}" = "true" && set -x

usage() {
    test -n "${*}" && echo "${*}"
    cat << END_USAGE
Usage: ${0} <release-name> <namespace> [kubectl-namespace-flag-value]

    <release-name>
        The Helm release name you will use (or already used) with
        "helm install"/"helm upgrade --install" for this example.

    <namespace>
        The Kubernetes namespace the release is/will be installed into.

    Builds the jgroups.properties DNS_PING dns_query value as:
        <release-name>-pingfederate-cluster.<namespace>.svc.cluster.local
    which must match the pingfederate-admin cluster headless Service FQDN.
END_USAGE
    exit 99
}

test -z "${1}" && usage "ERROR: A release name must be provided"
test -z "${2}" && usage "ERROR: A namespace must be provided"

_releaseName="${1}"
_namespace="${2}"
_clusterServiceFqdn="${_releaseName}-pingfederate-cluster.${_namespace}.svc.cluster.local"

echo "Creating pingfederate-cluster-config ConfigMap in namespace '${_namespace}'"
echo "  jgroups.properties dns_query: ${_clusterServiceFqdn}"

kubectl create configmap pingfederate-cluster-config \
    --namespace "${_namespace}" \
    --from-literal=cluster-admin-nodes-sync.conf="enabled=true" \
    --from-literal=jgroups.properties="$(
        cat << EOF
pf.cluster.discovery.protocol=DNS_PING
pf.cluster.DNS_PING.dns_query=${_clusterServiceFqdn}
EOF
    )"
