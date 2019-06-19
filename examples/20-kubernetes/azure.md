# Azure

## Microsoft Azure Kubernetes Service \(AKS\)

This directory contains scripts and deployment files to help with the deployment, management and scaling of Ping Identity DevOps Docker Images to Microsoft Azure Kubernets Service

### Getting Started

* [Microsoft Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes)

## Steps for setting up AKS Environment

> Pre-req: Azure CLI: [https://docs.microsoft.com/cli/azure/install-azure-cli](https://docs.microsoft.com/cli/azure/install-azure-cli)

### Creating an Azure Resource Group

Create an Azure Resource Group to put all resources into.

```text
az group create \
    --name ping-devops-rg \
    --location westus
```

### Creating an Azure AKS Cluster

```text
az aks create \
    --resource-group ping-devops-rg \
    --name ping-devops-cluster \
    --node-count 2 \
    --enable-addons monitoring \
    --ssh-key-value ~/.ssh/id_rsa.pub
```

### Get AKS Credentials into .kube/config

```text
az aks get-credentials \
    --resource-group ping-devops-rg \
    --name ping-devops-cluster
```

### Running Kubernetes Use Cases in AKS

You can now apply the kubernetes use cases into the new AKS environment.

The following command will startup the full stack.

```text
# from your 20-kubernetes directory
./setup -u fullstack
```

To get the status of the environment:

```text
./status
```

And to cleanup the environment

```text
./cleanup -u fullstack
```

### Cleanup AKS and Azure Resource Group

To clean up the Azure Resource Group and all resources associated including the AKS Cluster created.

> Note: This will remove **everything** you created associated with this resource group

```text
az group delete \
    --name ping-devops-rg
```

