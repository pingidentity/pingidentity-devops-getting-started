# Kubernetes deployments for general use

In all of these examples, we'll use the standalone configurations in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory to supply the base product configurations.

To minimize repetitive and irrelevant information, we'll also use [kustomize](https://kustomize.io/). For effective use of the examples, we recommended that you be familiar with concepts such as "resources" and "patches" in `kustomize`.

You'll find useful comments in the `kustomization.yaml` files in your local `pingidentity-devops-getting-started/20-kubernetes` example directories.

## Prerequisites

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've created a Kubernetes secret using your DevOps credentials. See the *For Kubernetes* topic in [Using your DevOps user and key](devopsUserKey.md).

## What you'll do

* Install kustomize.
* Orchestrate standalone deployments.
* Orchestrate a full stack deployment.
* Orchestrate a replicated PingDirectory deployment.
* Orchestrate a clustered PingAccess deployment.
* Orchestrate a clustered PingFederate deployment.

## Install kustomize

1. Install [kustomize](https://kustomize.io/).: `brew install kustomize`.
2. To view standard YAML outputs in each directory, run commands like: 

     `kustomize build <path/to/directory>` 
  
    For the fullstack configuration (pingidentity-devops-getting-started/20-kubernetes/02-fullstack), for example, you might use: 
  
    `kustomize build ./20-kubernetes/02-fullstack > ./output.yaml` 
  
    This builds and redirects the output to the `output.yaml` file.

## Orchestrate standalone deployments

You'll use the standalone configurations in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory as the base product configurations with the server profiles in our [pingidentity-server-profiles/getting-started](../../pingidentity-server-profiles/getting-started) repository.  

The commands in this topic are meant to be used with or without kustomize. When used without kustomize (as the steps in this topic do), the commands will return some benign errors regarding `kustomization.yaml`. An example of a benign kustomize error is: 
```bash
unable to recognize "01-standalone/kustomization.yaml": no matches for kind "Kustomization" in version "kustomize.config.k8s.io/v1beta1"
```

You can deploy a single (standalone) product container, or a set of standalone containers using Kubernetes.

### Procedure

1. Go to any one of the product subdirectories in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory.
2. Orchestrate the deployment using the Kubernetes commands. For example:

   ```bash
   kubectl apply -f pingfederate/
   ```

3. To orchestrate a deployment of all of the products in your `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory. From your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter: 

   ```bash
   kubectl apply -R -f 01-standalone/
   ```

4. To clean up when you're finished, for a single product container, enter: 

   ```bash
   kubectl delete -f <container>/
   ```

   Where \<container> is the name of a product container (such as, `pingfederate`).

   For all products in the `01-standalone` directory, enter:

   ```bash
   kubectl delete -R -f 01-standalone/
   ```

## Orchestrate a full stack deployment

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

### Procedure

1. To orchestrate the full stack deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

  ```bash
  kubectl apply -k 02-fullstack/
  ```

2. To clean up when you're finished, enter: 

   ```bash
   kubectl delete -k 02-fullstack/
   ```

## Orchestrate a replicated PingDirectory deployment

You'll use kustomize for the replicated deployment of PingDirectory from your local `pingidentity-devops-getting-started/20-kubernetes/03-replicated-pingdirectory` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdirectory` and `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdataconsole` directories for the base product configurations. You'll use the PingDirectory server profile in our [pingidentity-server-profiles/baseline](../../pingidentity-server-profiles/baseline) repository.

The `env_vars.pingdirectory` file contains: 

* The environment variables to use for `pingidentity-server-profiles/baseline/pingdirectory`. 
* The Kubernetes declarations for PingDirectory. 
* An initial creation of 1,000 PingDirectory users. 
* A command to `tail` the log files for display. 

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdirectory` and `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdataconsole` directories for the base product configurations. 
* References a mounted Kubernetes storage class volume for disaster recovery (`storage.yaml`). 
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.pingdirectory` file.

See also [Orchestrate PingDirectory deployments across Kubernetes clusters](deployK8sPD-clusters.md).

### Procedure

1. To orchestrate the replicated PingDirectory deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

   ```bash
   kubectl apply -k 03-replicated-pingdirectory/
   ```

2. To clean up when you're finished, enter: 

   ```bash
   kubectl delete -k 03-replicated-pingdirectory/
   ```

## Orchestrate a PingAccess cluster deployment

You'll use kustomize for the PingAccess cluster deployment from your local `pingidentity-devops-getting-started/20-kubernetes/04-clustered-pingaccess` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory for the base product configurations. You'll use the server profile in our [pingidentity-server-profiles/pa-clustering](../../pingidentity-server-profiles/pa-clustering) repository.

We use separate deployments for the PingAccess admin node (`env_vars.pingaccess`) and the PingAccess engine node (`env_vars.pingaccess-engine` and `pingaccess-engine.yaml`). To scale out replicas, use the PingAccess engine node.

The `env_vars.pingaccess` and `env_vars.pingaccess-engine` files contain: 

* The environment variables to use for `pingidentity-server-profiles/pa-clustering`. 
* Sets the clustering (operational) mode for each deployment: CLUSTERED_CONSOLE for `pingaccess` and CLUSTERED_ENGINE for `pingaccess-engine`. 

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingaccess` directory for the base product configurations.
* Uses patches to remove the `pingaccess` engine port (3000). 
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.pingaccess` and `env_vars.pingaccess-engine` files.

### Procedure

1. To orchestrate the replicated PingDirectory deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

   ```bash
   kubectl apply -k 04-clustered-pingaccess/
   ```

2. Scale up the engines: 

   ```bash
   kubectl scale deployment pingaccess-engine --replicas=2
   ```

3. To clean up when you're finished, enter: 

   ```bash
   kubectl delete -k 04-clustered-pingaccess/
   ```

## Orchestrate a PingFederate cluster deployment

### Prerequisites

* `envsubst`. Substitutes shell format strings with environment variables. See [envsubst](https://command-not-found.com/envsubst) if your OS doesn't have this utility.
* PingFederate build image for version 10 or greater.

### Overview

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

### Procedure

1. Set the environment variable that we assign to the Kubernetes variable `DNS_QUERY_LOCATION`. Either:
   * Add `PING_IDENTITY_K8S_NAMESPACE=<your-k8s-namespace>` to your `~/.pingidentity/devops` file.
   * Run `export PING_IDENTITY_K8S_NAMESPACE=<your-k8s-namespace>`.

2. To orchestrate the clustered PingFederate deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:
   ```bash
   kustomize build . | envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | kubectl apply -f -
   ```

   > In some situations, the PingFederate engine deployment can create a cluster before the admin deployment, thereby creating cluster silos. This can be overcome by using an initializing container.

3. Wait for the pingfederate-engine pod to be running, then validate clustering has worked. You can port-forward the admin service and view the clustering using the admin console. For example: 
   ```
   kubectl port-forward svc/pingfederate 9999:9999
   ```

3. Scale up the engines: 
   ```
   kubectl scale deployment pingfederate-engine --replicas=2
   ```

4. To clean up when you're finished, enter: 

   ```bash
   kustomize build . | envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | kubectl delete -f -
   ```
