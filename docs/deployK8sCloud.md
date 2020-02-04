# Kubernetes orchestration for cloud platforms

## Prerequisites

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've created a Kubernetes cluster on one of these platforms:
  - Amazon Web Services (AWS) Elastic Kubernetes Service (EKS). See Amazon's [Getting Started with Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html).
  - Microsoft Azure Kubernetes Service (AKS). See Microsoft's [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes).
  <!-- - [Google](../22-cloud/cloud/google/README.md) -->
* You've created a Kubernetes secret using your DevOps credentials. See the *For Kubernetes* topic in [Using your DevOps user and key](devopsUserKey.md).
* You've installed [kustomize](https://kustomize.io/), and have some familiarity with its resources and patches concepts.
