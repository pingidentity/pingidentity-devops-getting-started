# Ping Identity DevOps - Kubernetes Cloud Environments

## Getting started
This directory contains example `.yaml` files and scripts to help with deploying into your Kubernetes environment. 

In the repository you will find: 
```
20-kubernetes
├── cloud #Create k8s clusters in different cloud providers
│   ├── amazon
│   ├── azure
│   ├── google
│   └── minikube #sample scripts to use with minikube
├── usecases # sample k8s deployments
│   └── fullstack # integrated PA,PF, PD, PDC
├── setup #script to deploy k8s definition to cluster/context
├── cleanup # script to clean k8s deployment
```

## Development Environments

* [minikube](minikube/README.md)

## Public Clouds

* [Amazon AWS - EKS](amazon/README.md)
* [Azure](azure/README.md)
* [Google](google/README.md)
