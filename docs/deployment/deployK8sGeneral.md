---
title: Kubernetes Deployments for General Use
---
# Kubernetes Deployments for General Use

In all of these examples, we'll use the standalone configurations in your local `pingidentity-devops-getting-started/20-kustomize/01-standalone` directory to supply the base product configurations.

To minimize repetitive and irrelevant information, we'll also use [kustomize](https://kustomize.io/). For effective use of the examples, we recommended that you be familiar with concepts such as "resources" and "patches" in `kustomize`.

You'll find useful comments in the `kustomization.yaml` files in your local `pingidentity-devops-getting-started/20-kustomize` example directories.

## Before you begin

You must:

* Complete [Get Started](../get-started/introduction.md) to set up your DevOps environment and run a test deployment of the products.
* Create a Kubernetes secret using your DevOps credentials. For more information, see *For Kubernetes* in [Using your DevOps user and key](../how-to/devopsUserKey.md).
* For the PingFederate cluster:
  * `envsubst`. Substitutes shell format strings with environment variables. See [envsubst](https://command-not-found.com/envsubst) if your OS doesn't have this utility.
  * PingFederate build image for version 10 or greater. (The DNS Discovery feature first available in version 10 is needed.)

## About this task

You will:

* Install kustomize
* Choose one or more of these examples to deploy:
    * Orchestrate standalone deployments
    * Orchestrate a full stack deployment
    * Orchestrate a replicated PingDirectory deployment
    * Orchestrate a clustered PingAccess deployment
    * Orchestrate a clustered PingFederate deployment
* Expose the applications

## Installing kustomize

1. Install [kustomize](https://kustomize.io/).
1. To view standard YAML outputs in each directory, run the following commands:

     `kustomize build <path/to/directory>`

    For the fullstack configuration (pingidentity-devops-getting-started/20-kustomize/02-fullstack), for example, you might use:

    `kustomize build ./20-kustomize/02-fullstack > ./output.yaml`

    This builds and redirects the output to the `output.yaml` file.

## Exposing the Applications

There are multiple ways to expose applications outside of a cluster. The main ways are Service with `type: Loadbalancer`, Service with `type: Nodeport`, and with an Ingress Controller and Ingresses.

Most of our examples will use Ingresses with Nginx as the ingress controller. This is for the following reasons:

* Prevalence of this pattern.
* Cost efficiency - Cheaper than a load balancer per service.
* Reliability and scenario coverage - vs. NodePort: less chance of contention on cluster ports, reduction of need to hard-code ports, easier hostname and DNS management.

### Before you begin

You must have:

1. An Ingress Controller. The following example shows an Nginx ingress-controller with an AWS Network Load Balancer:

    ```sh
    kustomize build https://github.com/pingidentity/ping-cloud-base/k8s-configs/cluster-tools/ingress/nginx/public > output.yaml
    ```

    !!! note "Use of Nginx"
        We use the Nginx ingress controller for reasons similar to why we chose exposing with Ingresses over Services.

        In addition to Nginx's prevalence in Kubernetes, Nginx doesn't trigger creation of an ALB, as happens with the AWS ALB ingress controller, and Nginx Network Load Balancers allow for TCP traffic instead of just Layer 7 (HTTP(s)).

1. A public certificate and private key to use as a TLS secret to be presented by the ingress. You can generate this TLS secret in Kubernetes yaml format with the [ping-devops tool](../tools/pingctlUtil.md).

    ```sh
   ping-devops generate devops-secret | kubectl apply -f -
   ```

## Steps

* Find sample yaml files for ingresses on products that ingresses make sense for in `20-kustomize/10-ingress`.
   > These examples should be generally applicable, with the exception of `metadata.annotations`.

* Deploy one of the examples with commands, such as:

      ```sh
      envsubst '${PING_IDENTITY_DEVOPS_DNS_ZONE}' \
        < 10-ingress/pingfederate-standalone-ingress.yaml | \
        kubectl apply -f -
      ```
