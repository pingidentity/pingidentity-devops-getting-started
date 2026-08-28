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
  Examples 1 and 2 (Examples 3 and 5 use `devops-secret`; Examples 4 and 6 use the credential
  Secret).
- Examples 5 and 6 additionally require a default StorageClass capable of ReadWriteOnce volumes
  (the admin StatefulSet requests a 4Gi PVC).

Files:
- `01-standalone.yaml`
  - Single-replica admin console. License delivery, license acceptance, and initial administrator
    creation via a bootstrap sidecar.
- `02-clustered.yaml`
  - Builds on `01-standalone.yaml` with a 2-replica admin console and DNS_PING cluster discovery.
- `03-server-profile.yaml`
  - Compatibility bridge for v1 server-profile users: full runtime + Git profile staged by an
    init container. Ephemeral staging; no persistent volume.
- `04-minimal-server-profile.yaml`
  - Env-first target model: scalar settings as environment variables, selected profile files
    mounted with `subPath`. Ephemeral staging; no persistent volume.
- `05-server-profile-pvc.yaml`
  - Migration starting point for v1 profile users who keep PVC-backed runtime data: the full
    runtime + profile staging of Example 3, with the admin console as a StatefulSet whose PVC
    mounts exactly at `/opt/out/instance/server/default/data`. Staging stays a separate
    ephemeral `emptyDir`. Labeled temporary: masks the image runtime and couples the profile
    to the image tag.
- `06-minimal-server-profile-pvc.yaml`
  - Destination of the migration: Example 4's env-first/selected-file model with the same
    StatefulSet PVC at `/opt/out/instance/server/default/data`. The Flex image owns
    `/opt/pingidentity/runtime`; only verified profile files are overlaid via `subPath` mounts
    from an init-staged `emptyDir`.
- `flex-bootstrap.sh`
  - The bootstrap script both example files mount into the `flex-bootstrap` sidecar via a ConfigMap.
- `create-cluster-config.sh <release-name> <namespace>`
  - Creates the `pingfederate-cluster-config` ConfigMap required by `02-clustered.yaml`, computing
    the `jgroups.properties` DNS_PING `dns_query` value from the release name and namespace you
    pass in.

Migration path (Git-hosted profile + PVC-backed data): start with 05 to keep the existing
profile working, then reduce the profile toward 06 by moving scalar settings to
`PF_<FILE>_<property>` environment variables and delivering only filesystem-required artifacts.
The PVC stays mounted only at `/opt/out/instance/server/default/data` throughout; staging is
rebuilt on every pod while the PVC survives pod deletion and helm upgrades.
