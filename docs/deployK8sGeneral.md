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
* Expose the applications

## Install kustomize

1. Install [kustomize](https://kustomize.io/).
2. To view standard YAML outputs in each directory, run commands like: 

     `kustomize build <path/to/directory>` 
  
    For the fullstack configuration (pingidentity-devops-getting-started/20-kubernetes/02-fullstack), for example, you might use: 
  
    `kustomize build ./20-kubernetes/02-fullstack > ./output.yaml` 
  
    This builds and redirects the output to the `output.yaml` file.

## Expose the Applications

There are multiple ways to expose applications outside of a cluster. The main ways are Service with `type: Loadbalancer`, Service with `type: Nodeport`, and with an Ingress Controller and Ingresses. 

Most of our examples will use Ingresses with Nginx as the ingress controller. This is for the following reasons: 
- prevalence of this pattern
- cost efficiency - Cheaper than a load balancer per service. 
- reliability and scenario coverage - vs. NodePort: less chance of contention on cluster ports, reduction of need to hard-code ports, easier hostname and DNS management. 

### Pre-requisite

1. Before deploying ingresses for the products, there must be an Ingress Controller available. An Nginx ingress-controller example with an AWS Network Load Balancer example can be found here like this: 

```
kustomize build https://github.com/pingidentity/ping-cloud-base/k8s-configs/cluster-tools/ingress/nginx/public > output.yaml
```

> We use the Nginx ingress controller for reasons similar to why we chose exposing via Ingresses over Services. In addition to Nginx's prevalence in Kubernetes, it is preferred over the AWS ALB ingress controller (another common ingress controller) because: 1. Each Ingress with ALB ingress controller triggers creation of an ALB 2. Network Load Balancers allow us to do TCP traffic rather than just Layer 7 (HTTP(s). 

2. You'll also need a public certificate and private key to use as a tls secret to be presented by the ingress. You can generate this tls secret in kubernetes yaml format with the [ping-devops tool](../docs/pingDevopsUtil.md)
```
ping-devops generate devops-secret > output.yaml
kubectl apply -f output.yaml
```

## Instructions

You can find sample `.yaml`s for ingresses on products that is makes sense for in `20-kubernetes/10-ingress` 
> These examples should be generally applicable, with the exception of `metadata.annotations`



