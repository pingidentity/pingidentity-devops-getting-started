---
title: Deploy to Azure Kubernetes Service
---
# Deploying to Azure Kubernetes Service

This directory contains scripts and deployment files to help with the deployment, management, and scaling of Ping Identity DevOps Docker images to Microsoft Azure Kubernetes Service (AKS).

## Prerequisites
Before you begin, you must:

* Set up your DevOps environment and run a test deployment of the products. For more information, see [Get Started](../get-started/introduction.md).
* Create a Kubernetes cluster on AKS.
* Create a Kubernetes secret using your DevOps credentials. See the *For Kubernetes* topic in [Using your DevOps user and key](../how-to/devopsUserKey.md).
* Download and install the [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli).

We also highly recommend you are familiar with the information in these AKS articles:

* [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes)

## Deploying our fullstack example in AKS

1. Create an Azure Resource Group to put all resources into by entering:

      ```sh
      az group create \
         --name ping-devops-rg \
         --location westus
      ```

1. Create a two-node Azure AKS cluster by entering the following.

      ```sh
      az aks create \
         --resource-group ping-devops-rg \
         --name ping-devops-cluster \
         --node-count 2 \
         --enable-addons monitoring \
         --ssh-key-value ~/.ssh/id_rsa.pub
      ```

      You need a public certificate by default in ~/.ssh/id_rsa.pub.

1. Import the AKS Credentials into `.kube/config` by entering:

      ```sh
      az aks get-credentials \
         --resource-group ping-devops-rg \
         --name ping-devops-cluster
      ```

1. From your local `pingidentity-devops-getting-started/20-kustomize/02-fullstack` directory, start our fullstack example in AKS by entering:

      ```sh
      kustomize build . | kubectl apply -f -
      ```

1. To display the status of the environment, enter:

      ```sh
      kubectl get all
      ```

1. To clean up the environment, enter:

      ```sh
      kustomize build . | kubectl delete -f -
      ```

1. To clean up the Azure Resource Group and all associated resources, including the AKS cluster created, enter the following command.

!!! warning
    This will remove everything you created that is associated with this resource group.

    ```sh
    az group delete \
      --name ping-devops-rg
    ```
