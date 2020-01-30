# Kubernetes orchestration for general use

We'll use the standalone configurations in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory as the base product configurations with the server profiles in our [pingidentity-server-profiles/getting-started/](../../pingidentity-server-profiles/getting-started/) repository.  

You'll find useful comments in the `kustomization.yaml` files in your local `pingidentity-devops-getting-started/20-kubernetes` example directories.

To minimize repetitive and irrelevant information, we'll also use [kustomize](https://kustomize.io/). For effective use of the examples, we recommended that you be familiar with concepts such as "resources" and "patches" in `kustomize`.

## Prerequisites

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've created a Kubernetes cluster for:
  - [Amazon](../22-cloud/cloud/amazon/README.md)
  - [Azure](../22-cloud/cloud/azure/README.md)
  - [Google](../22-cloud/cloud/google/README.md)
* You've created a Kubernetes secret using your DevOps credentials. See the *For Kubernetes* topic in [Using your DevOps user and key](devopsUserKey.md).

## Install kustomize

1. Install [kustomize](https://kustomize.io/).: `brew install kustomize`.
2. To view standard YAML outputs in each directory, run commands like: 

     `kustomize build <path/to/directory>` 
  
    For the fullstack configuration (pingidentity-devops-getting-started/20-kubernetes/02-fullstack), for example, you might use: 
  
    `kustomize build ./20-kubernetes/02-fullstack > ./output.yaml` 
  
    This builds and redirects the output to the `output.yaml` file.

## Standalone deployments
