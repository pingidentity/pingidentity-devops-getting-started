---
title: Orchestrate a PingAccess Cluster Deployment
---
# Orchestrate a PingAccess Cluster Deployment

You'll use kustomize for the PingAccess cluster deployment from your local `pingidentity-devops-getting-started/20-kubernetes/04-clustered-pingaccess` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations. You'll use the server profile in our [pingidentity-server-profiles/pa-clustering](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pa-clustering) repository.

We use separate deployments for the PingAccess admin node (`env_vars.pingaccess`) and the PingAccess engine node (`env_vars.pingaccess-engine` and `pingaccess-engine.yaml`). To scale out replicas, use the PingAccess engine node.

The `env_vars.pingaccess` and `env_vars.pingaccess-engine` files contain:

* The environment variables to use for `pingidentity-server-profiles/pa-clustering`.
* Sets the clustering (operational) mode for each deployment: CLUSTERED_CONSOLE for `pingaccess` and CLUSTERED_ENGINE for `pingaccess-engine`.

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingaccess` directory for the base product configurations.
* Uses patches to remove the `pingaccess` engine port (3000).
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.pingaccess` and `env_vars.pingaccess-engine` files.

## Deploy the Cluster

1. To orchestrate the replicated PingAccess deployment, from your local `pingidentity-devops-getting-started/20-kubernetes/04-clustered-pingaccess` directory, enter:

      ```sh
      kustomize build . | kubectl apply -f -
      ```

1. Scale up the engines:

      ```sh
      kubectl scale deployment pingaccess-engine --replicas=2
      ```

## Clean Up

To clean up when you're finished, enter:

   ```sh
   kustomize build . | kubectl delete -f -
   ```
