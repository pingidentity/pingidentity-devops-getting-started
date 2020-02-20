# Orchestrate a PingFederate cluster deployment

You'll use kustomize for the PingFederate cluster deployment from your local `pingidentity-devops-getting-started/20-kubernetes/06-clustered-pingfederate` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations. 

We use layered server profiles: 

* The server profile in our [pingidentity-server-profiles/pf-dns-ping-clustering](../../pingidentity-server-profiles/pf-dns-ping-clustering) repository.
* The server profile in our [pingidentity-server-profiles/getting-started/pingfederate](../../pingidentity-server-profiles/getting-started/pingfederate) repository.

See [Layering server profiles](docs/profilesLayered.md) for more information.

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

## Deploy the cluster

1. Set the environment variable that we assign to the Kubernetes variable `DNS_QUERY_LOCATION`. Either:

   * Add `PING_IDENTITY_K8S_NAMESPACE=<your-k8s-namespace>` to your `~/.pingidentity/devops` file.
   * Run `export PING_IDENTITY_K8S_NAMESPACE=<your-k8s-namespace>`.

2. To orchestrate the clustered PingFederate deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

   ```bash
   kustomize build . | envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | kubectl apply -f -
   ```

   > In some situations, the PingFederate engine deployment can create a cluster before the admin deployment, thereby creating cluster silos. This can be overcome by using an initializing container.

3. Wait for the `pingfederate-engine` pod to be running, then validate clustering has worked. You can port-forward the admin service and view the clustering using the admin console. For example: 

   ```
   kubectl port-forward svc/pingfederate 9999:9999
   ```

4. Scale up the engines: 

   ```
   kubectl scale deployment pingfederate-engine --replicas=2
   ```

5. To clean up when you're finished, enter: 

   ```bash
   kustomize build . | envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | kubectl delete -f -
   ```
