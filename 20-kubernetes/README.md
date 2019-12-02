# Kubernetes

## Pre-Requisites

Prior to deploying to Kubernetes, please ensure you have completed the following items:

* Ping Identity DevOps Setup - [Quickstart](../docs/QUICKSTART.md)
* Create a Kubernetes cluster
  * [Amazon](../22-cloud/cloud/amazon/README.md)
  * [Azure](../22-cloud/cloud/azure/README.md)
  * [Google](../22-cloud/cloud/google/README.md)
  * Minikube (docs coming soon)
  * Rancher (docs coming soon)
* [Create devops user and key as k8s secret](#licenses)

## Overview

The `20s` section contain examlples, instructions, scripts, for Kubernetes general and cloud-provider specific use-cases. 
To minimize repetitive and irrelevant information, this section makes use of [kustomize](https://kustomize.io/). Each level in this section builds on top of the others with `20-kubernetes/01-standalone` as the base. Though it is not necessary, for effective use of the exampmles it is recommended to be familiar with concepts such as "resources" and "patches" in `kustomize`. 

First, install kustomize: `brew install kustomize`. Then, to view standard yaml outputs in each directory, run commands like `kustomize build <path/to/directory>`. Example, for "fullstack": `kustomize build ./20-kubernetes/02-fullstack > ./output.yaml`. This command builds and redirects the output to a file called output.yaml, without the redirect, the output is sent to stdout. 

In addition to these general examples, there are more complete resources available for advanced users on the [ping-cloud-base repo](https://github.com/pingidentity/ping-cloud-base).

Since we are using `kustomize`, look in the kustomization.yaml files for comments on what is done to achieve the use-case.

## Licenses

This section describes how to create a kubernetes secret that contains variables: `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY`. The values for these variables can be obtained from these instructions: [Obtain and Use Product Licenses](../docs/PROD-LICENSE.md)

The examples in the kubernetes section are fitted to **optionally** look for a kubernetes secret named "devops-secret".

You can generate this secret like so: 
```
kubectl create secret generic devops-secret --from-literal=PING_IDENTITY_DEVOPS_USER="${PING_IDENTITY_DEVOPS_USER}" --from-literal=PING_IDENTITY_DEVOPS_KEY="${PING_IDENTITY_DEVOPS_KEY"
```

## 20-kubernetes

General use examples - These examples focus on deploying the products without considering the surrounding infrastructure.

<!-- ### 01-standalone
Focus on a baseline deployment for each product. Leverages the `getting-started` profile to provide a vanilla, standalone instance. 

### 02-fullstack
Improves on the deployment from 01-standalone by using the `baseline` profile. This profile provides a simple use case and all of the products integrated together. -->

## 21-cluster-tools
Tools that may not relate directly to any individual Ping Identity product, but instead to the broader Kubernetes infrastructure in which Ping Identity products reside. Examples include fitting the products in with ingress-controllers and monitoring tools. 

## 22-cloud
Examples to cover various nuances relative to the platform that your kubernetes infrastructure may be running on. These examples range from standing up a Kubernetes cluster in cloud providers, to annotations on Kubernetes resources for specific cloud providers. 
