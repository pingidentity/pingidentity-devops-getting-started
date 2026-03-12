# Utility Sidecar Example Values

These example values files demonstrate updates for the `utilitySidecar` enhancement.

## NOTE: These examples are for demonstration purposes and may not be suitable for production use without modification

## PRE-REQUISITES

- These examples will only work with the Helm chart version 0.12.1 or later, the version in which the necessary enhancements for utility sidecars were introduced.  If you are using an older version of the Helm chart, you will need to upgrade to at least version 0.12.1 to use these examples.

Files:
- `01-pingdirectory-periodic-backup-compatible.yaml`
  - Backward-compatible pattern based on the existing getting-started backup example.  This example will work with Helm chart versions prior to 0.12.1, but does not take advantage of the new `command`, `args`, and `envFrom` fields.
- `02-pingdirectory-custom-command-envfrom.yaml`
  - Uses the new `command`, `args`, and `envFrom` fields.
- `03-pingdataconsole-deployment-sidecar.yaml`
  - Deployment example showing implicit `temp` and `out-dir` volume creation.
