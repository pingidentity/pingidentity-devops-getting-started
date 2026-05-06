# Secrets Store CSI Driver with HashiCorp Vault

This example deploys PingDirectory and PingFederate with all secrets sourced from HashiCorp Vault via the [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/).

The two products use different delivery mechanisms intentionally:

| Product | Mechanism | How it works |
|---------|-----------|--------------|
| PingDirectory | Mounted files | Secrets written to `/run/secrets`; startup scripts source them automatically |
| PingFederate (admin + engine) | Environment variables | `secretObjects` syncs secrets into a Kubernetes `Secret`; `container.envFrom` injects them as env vars |

See the full walkthrough at `docs/vault-spc-walkthrough.adoc` for step-by-step instructions including cluster setup, Vault installation, secret seeding, and Kubernetes auth configuration.

## Quick start

After completing the setup steps in the walkthrough:

```bash
helm install ping pingidentity/ping-devops \
  -n ping \
  -f ping-values.yaml
```

## Files

| File | Description |
|------|-------------|
| `ping-values.yaml` | Helm values for the full deployment |

## Verify

**PingDirectory — secrets as files:**
```bash
kubectl exec -n ping \
  $(kubectl get pod -n ping -l app.kubernetes.io/name=pingdirectory -o name | head -1) \
  -- ls /run/secrets
```

**PingFederate — secrets as environment variables:**
```bash
kubectl exec -n ping \
  $(kubectl get pod -n ping -l app.kubernetes.io/name=pingfederate-admin -o name | head -1) \
  -- env | grep -E 'ADMINISTRATOR_PASSWORD|PING_IDENTITY_DEVOPS'
```
