---
title: Orchestrate a Full Stack Deployment
---
# Orchestrate a Full Stack Deployment

You'll use kustomize for the full stack deployment from your local `pingidentity-devops-getting-started/20-kubernetes/02-fullstack` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations. However, this time we'll use the server profiles in our [pingidentity-server-profiles/baseline](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline) repository, rather than the [pingidentity-server-profiles/getting-started](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started) repository, as we did for the standalone deployments.

The `env_vars.*` files contain the environment variables for `pingidentity-server-profiles/baseline`. For example:
```yaml
SERVER_PROFILE_URL=https://www.github.com/pingidentity/pingidentity-server-profiles.git
SERVER_PROFILE_PATH=baseline/pingaccess
PING_IDENTITY_ACCEPT_EULA=YES
```

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations.
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.*` files.

## Deploy the Stack

To orchestrate the full stack deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

```sh
kustomize build . | kubectl apply -f -
```

> Optionally, if you don't want to deploy everything, first comment out what you don't want in the `kustomization.yaml` file.

## Clean Up

To clean up when you're finished, enter:

```bash
kustomize build . | kubectl delete -f -
```
