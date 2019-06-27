# Minikube

The easiest way to get started with kubernetes is probably to get familiar with Minikube, an all-in-one local kubernetes turn-key cluster.

This documentation was created with the intention of making this as simple as possible, to better demonstrate only the basics of Kubernetes with PingDirectory; rather than confusing the issue with other things more specific to Docker or the rest of the automation that is coming next.

## Pre-requisites

You will need:

* Minikube: [installation instructions](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* kubectl: [installation instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Configuration for local development

At present, you must use the ubuntu-based docker images for DNS discovery to work properly in kubernetes. Steps to get through the scenario

* build images locally with `./build.sh`
* manually push the images to the registry `./k8s-registry-prepare.sh`
* start minikube `./k8s-minikube-prepare.sh`
* run the service `./k8s-run.sh`
* stop the service `./k8s-cleanup.sh`
* Stop minikube `./k8s-minikube-cleanup.sh`

## What to look at

* env\_vars: environment variable that will be expanded from template to produce a working deployment

