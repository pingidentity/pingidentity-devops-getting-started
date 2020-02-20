# Orchestrate a full stack deployment

You'll use kustomize for the full stack deployment from your local `pingidentity-devops-getting-started/20-kubernetes/02-fullstack` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations. However, this time we'll use the server profiles in our [pingidentity-server-profiles/baseline](../../pingidentity-server-profiles/baseline) repository, rather than the [pingidentity-server-profiles/getting-started](../../pingidentity-server-profiles/getting-started) repository, as we did for the standalone deployments.

The `env_vars.*` files contain the environment variables for `pingidentity-server-profiles/baseline`. For example:
```yaml
SERVER_PROFILE_URL=https://www.github.com/pingidentity/pingidentity-server-profiles.git
SERVER_PROFILE_PATH=baseline/pingaccess
PING_IDENTITY_ACCEPT_EULA=YES
```

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations. 
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.*` files.

## Deploy the stack

1. To orchestrate the full stack deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

   ```bash
   kubectl apply -k 02-fullstack/
   ```

2. To clean up when you're finished, enter: 

   ```bash
   kubectl delete -k 02-fullstack/
   ```

