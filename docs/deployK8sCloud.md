# Kubernetes deployments for cloud platforms

We currently have instructions and examples for deploying our product containers using Kubernetes on these platforms:

* Amazon Web Services (AWS) Elastic Kubernetes Service (EKS).
* Microsoft Azure Kubernetes Service (AKS).

Each hosting platform supports and manages Kubernetes differently. 

## Prerequisites

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've created a Kubernetes cluster on one of these platforms:
  - Amazon's AWS EKS.
  - Microsoft's AKS. 
  <!-- - Google -->
* You've created a Kubernetes secret using your DevOps credentials. See the *For Kubernetes* topic in [Using your DevOps user and key](devopsUserKey.md).

## AWS EKS

See [Deploy to Amazon Web Services EKS](deployK8s-AWS.md).

## AKS

See [Deploy to Azure Kubernetes Service](deployK8s-AKS.md).