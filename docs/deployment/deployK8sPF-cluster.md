---
title: Orchestrate a PingFederate Cluster Deployment
---
# Orchestrate a PingFederate Cluster Deployment

You'll use kustomize for the PingFederate cluster deployment from your local `pingidentity-devops-getting-started/20-kubernetes/06-clustered-pingfederate` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations.

We use layered server profiles:

* The server profile in our [pingidentity-server-profiles/pf-dns-ping-clustering](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pf-dns-ping-clustering) repository.
* The server profile in our [pingidentity-server-profiles/getting-started/pingfederate](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingfederate) repository.

See [Layering Server Profiles](../how-to/profilesLayered.md) for more information.

We use separate deployments for the PingFederate admin node (`env_vars.pingfederate`) and the PingFederate engine node (`env_vars.pingfederate-engine` and `pingfederate-engine.yaml`). To scale out replicas, use the PingFederate engine node.

The `env_vars.pingfederate` and `env_vars.pingfederate-engine` files contain:

* The environment variables to use for `pingidentity-server-profiles/pf-dns-ping-clustering` and `pingidentity-server-profiles/getting-started/pingfederate`.
* Sets the clustering (operational) mode for each deployment: CLUSTERED_CONSOLE for `pingfederate` and CLUSTERED_ENGINE for `pingfederate-engine`.
* Assigns the Kubernetes variable `DNS_QUERY_LOCATION`.

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingfederate` directory for the base product configurations.
* Uses patches to remove the `pingfederate` engine port (9031).
* Adds a `pingfederate` cluster port (7600).
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.pingfederate` and `env_vars.pingfederate-engine` files.

## Prerequisites

* `envsubst`. Substitutes shell format strings with environment variables. See [envsubst](https://command-not-found.com/envsubst) if your OS doesn't have this utility.
* PingFederate build image for version 10 or greater. (The DNS Discovery feature first available in version 10 is needed.)

## Deploy the Cluster

1. Set the environment variable that we assign to the Kubernetes variable `DNS_QUERY_LOCATION`. Either:

   * Add `PING_IDENTITY_K8S_NAMESPACE=<your-k8s-namespace>` to your `~/.pingidentity/devops` file.
   * Run `export PING_IDENTITY_K8S_NAMESPACE=<your-k8s-namespace>`.

1. To orchestrate the clustered PingFederate deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

      ```sh
      kustomize build . | \
         envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | \
         kubectl apply -f -
      ```

    !!! note "Cluster Startup"
        In some situations, the PingFederate engine deployment can create a cluster before the admin deployment, thereby creating cluster silos. This can be overcome by using an [Init](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) container.

1. Wait for the `pingfederate-engine` pod to be running, then validate clustering has worked. You can port-forward the admin service and view the clustering using the admin console. For example:

      ```sh
      kubectl port-forward svc/pingfederate 9999:9999
      ```

1. Scale up the engines:

      ```sh
      kubectl scale deployment pingfederate-engine --replicas=2
      ```

## Cleanup

To clean up when you're finished, enter:

```sh
kustomize build . | \
   envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | \
   kubectl delete -f -
```
