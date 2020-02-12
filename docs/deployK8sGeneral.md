# Kubernetes deployments for general use

In all of these examples, we'll use the standalone configurations in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory to supply the base product configurations.

To minimize repetitive and irrelevant information, we'll also use [kustomize](https://kustomize.io/). For effective use of the examples, we recommended that you be familiar with concepts such as "resources" and "patches" in `kustomize`.

You'll find useful comments in the `kustomization.yaml` files in your local `pingidentity-devops-getting-started/20-kubernetes` example directories.

## Prerequisites

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've created a Kubernetes secret using your DevOps credentials. See the *For Kubernetes* topic in [Using your DevOps user and key](devopsUserKey.md).
* For the PingFederate cluster:
  * `envsubst`. Substitutes shell format strings with environment variables. See [envsubst](https://command-not-found.com/envsubst) if your OS doesn't have this utility.
  * PingFederate build image for version 10 or greater. (The DNS Discovery feature first available in version 10 is needed.)

## What you'll do

* Install kustomize.
* Choose one or more of these examples to deploy:
  * Orchestrate standalone deployments.
  * Orchestrate a full stack deployment.
  * Orchestrate a replicated PingDirectory deployment.
  * Orchestrate a clustered PingAccess deployment.
  * Orchestrate a clustered PingFederate deployment.

## Install kustomize

1. Install [kustomize](https://kustomize.io/).
2. To view standard YAML outputs in each directory, run commands like: 

     `kustomize build <path/to/directory>` 
  
    For the fullstack configuration (pingidentity-devops-getting-started/20-kubernetes/02-fullstack), for example, you might use: 
  
    `kustomize build ./20-kubernetes/02-fullstack > ./output.yaml` 
  
    This builds and redirects the output to the `output.yaml` file.

