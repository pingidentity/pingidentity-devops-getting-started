---
title: Orchestrate a Full Stack Deployment
---
# Orchestrating a Full Stack Deployment

Use kustomize for the full stack deployment from your local `pingidentity-devops-getting-started/20-kustomize/02-fullstack` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kustomize/01-standalone` directory for the base product configurations.

For this deployment, use the server profiles in our [pingidentity-server-profiles/baseline](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline) repository instead of the [pingidentity-server-profiles/getting-started](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started) repository, which we did for the standalone deployments.

The `env_vars.*` files contain the environment variables for `pingidentity-server-profiles/baseline`.

For example:

```yaml
SERVER_PROFILE_URL=https://www.github.com/pingidentity/pingidentity-server-profiles.git
SERVER_PROFILE_PATH=baseline/pingaccess
PING_IDENTITY_ACCEPT_EULA=YES
```

The `kustomization.yaml` file:

* References your local `pingidentity-devops-getting-started/20-kustomize/01-standalone` directory for the base product configurations
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.*` files

## Deploying the Stack

To orchestrate the full stack deployment, from your local `pingidentity-devops-getting-started/20-kustomize` directory, enter:

```sh
kustomize build . | kubectl apply -f -
```

> If you don't want to deploy everything,  comment out what you don't want in the `kustomization.yaml` file before deploying the stack.

## Cleaning Up

To clean up when you're finished, enter:

```sh
kustomize build . | kubectl delete -f -
```
