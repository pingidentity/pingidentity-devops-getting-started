# PingFederate Flex Image Example Values

These example values files demonstrate running PingFederate's "flex" image variant with the
`pingidentity/ping-devops` Helm chart.

## NOTE: These examples are for demonstration purposes and may not be suitable for production use without modification

## PRE-REQUISITES

- Released Helm chart version `0.14.0` or later.
- Chart 0.14.0 requires explicit Flex probe commands and literal Secret/ConfigMap names in
  sidecars
- A valid PingFederate license file.
- A credential Secret named `pingfederate-admin-creds` containing `PING_IDENTITY_PASSWORD` for
  Examples 1 and 2 (Example 3 uses `devops-secret`; Example 4 uses the credential Secret).

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
