# PingFederate Flex Image Example Values

These example values files demonstrate running PingFederate's "flex" image variant with the
`pingidentity/ping-devops` Helm chart.

## NOTE: These examples are for demonstration purposes and may not be suitable for production use without modification

## PRE-REQUISITES

- Helm chart version `0.15.0` or later (for the `flex.enabled` probe convenience and `tpl`-templated
  `sidecars`/`initContainers`).
- A valid PingFederate license file.

Files:
- `01-standalone.yaml`
  - Single-replica admin console. License delivery, license acceptance, and initial administrator
    creation via a bootstrap sidecar.
- `02-clustered.yaml`
  - Builds on `01-standalone.yaml` with a 2-replica admin console and DNS_PING cluster discovery.
- `flex-bootstrap.sh`
  - The bootstrap script both example files mount into the `flex-bootstrap` sidecar via a ConfigMap.
- `create-cluster-config.sh <release-name> <namespace>`
  - Creates the `pingfederate-cluster-config` ConfigMap required by `02-clustered.yaml`, computing
    the `jgroups.properties` DNS_PING `dns_query` value from the release name and namespace you
    pass in.
