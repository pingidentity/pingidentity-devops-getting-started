---
title: Orchestrate Deployments with Kubernetes
---
# Orchestrate Deployments with Kubernetes

The Kubernetes examples contain configurations and scripts to orchestrate deployments of our DevOps images for:

* [Kubernetes For General Use](deployK8sGeneral.md)
* [Kubernetes For Cloud Platforms](deployK8sCloud.md), such as Amazon Web Services (AWS)

!!! note "Kustomize vs Helm"
    The examples in these two sections use [Kustomize](https://kustomize.io/) and `kubectl apply` as the method for deploying the products.  While they work, the emphasis forward is away from kustomize and toward the use of the provided and maintained Helm charts.  These examples will be reviewed in the future for conversion to this recommended practice.
