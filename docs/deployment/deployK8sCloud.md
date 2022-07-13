---
title: Kubernetes deployments for cloud platforms
---
# Kubernetes deployments for cloud platforms

We currently have instructions for typical configuration of Kubernetes for use with Ping products on these platforms:

* Amazon Web Services (AWS) Elastic Kubernetes Service (EKS)
* Microsoft Azure Kubernetes Service (AKS)

Each hosting platform supports and manages Kubernetes differently.

## Before you begin

You must:

* Complete [Get Started](../get-started/introduction.md) to set up your DevOps environment and run a test deployment of the products.
* Create a Kubernetes cluster on one of these platforms:
    * Amazon EKS
    * Microsoft AKS

* Create a Kubernetes secret using your DevOps credentials. For more information, see *For Kubernetes*  in [Using your DevOps user and key](../how-to/devopsUserKey.md).

## AWS EKS

See [Deploy Peered EKS Clusters](deployK8s-AWS.md).

## AKS

See [Deploy to Azure Kubernetes Service](deployK8s-AKS.md).