# Secrets Store CSI Driver with HashiCorp Vault

This example deploys PingDirectory and PingFederate with all secrets sourced from HashiCorp Vault via the [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/).

Secrets are delivered as mounted files at `/run/vault-secrets`. Setting `SECRETS_DIR` to that path tells the Ping startup hooks to source `*.env` files there, injecting all `KEY=VALUE` pairs as environment variables. No Kubernetes `Secret` objects are created.

See the [full walkthrough](https://developer.pingidentity.com/helm/examples/vault-spc-walkthrough.html) for step-by-step instructions including cluster setup, Vault installation, secret seeding, and Kubernetes auth configuration.

## Quick start

After completing the setup steps in the walkthrough:

```bash
helm install ping pingidentity/ping-devops \
  -n ping \
  --set global.rbac.serviceAccountName=ping-vault-auth \
  --set global.rbac.applyServiceAccountToWorkload=true \
  -f ping-values.yaml
```

## Files

| File | Description |
|------|-------------|
| `ping-values.yaml` | Helm values for the full deployment |

## Verify

**Mounted secret files:**
```bash
kubectl exec -n ping \
  $(kubectl get pod -n ping -l app.kubernetes.io/name=pingdirectory -o name | head -1) \
  -- ls /run/vault-secrets
```

**PingDirectory — env vars sourced from mounted file:**
```bash
kubectl exec -n ping \
  $(kubectl get pod -n ping -l app.kubernetes.io/name=pingdirectory -o name | head -1) \
  -- env | grep -E 'SECRETS_DIR|ROOT_USER_PASSWORD_FILE'
```

**PingFederate — env vars sourced from mounted file:**
```bash
kubectl exec -n ping \
  $(kubectl get pod -n ping -l app.kubernetes.io/name=pingfederate-admin -o name | head -1) \
  -- env | grep SECRETS_DIR
```
