---
title: Orchestrate Deployments with Kubernetes
---
# Orchestrate Deployments with Kubernetes

The Kubernetes examples contain configurations and scripts to orchestrate deployments of our DevOps images for:

* [Kubernetes For General Use](deployK8sGeneral.md)
* [Kubernetes For Cloud Platforms](deployK8sCloud.md), such as Amazon Web Services (AWS)

!!! note "Kustomize vs Helm"
    The examples in these two sections were written using [Kustomize](https://kustomize.io/) and `kubectl apply` as the method for deploying the products.  While the examples work, the emphasis moving forward is away from kustomize and toward using Ping's Helm charts.
