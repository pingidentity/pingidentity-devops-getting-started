# 01-standalone

This directory contains examples for standalone versions of the software products.
These examples use the `getting-started` profile. 

You can deploy any of the directories to get a kubernetes configmap, deployment, and service for the product

Example:

```
kubectl apply -f pingfederate/
```

You can deploy `01-standalone` to deploy everything in this directory: 

```
kubectl apply -R -f 01-standalone/
```

> Note: These commands will return some benign errors regarding `kustomization.yaml`. These examples are meant to be able to be deployed with, or without kustomize. Everything beyond these examples will depend on `kustomize`. 
example benign kustomization error: 
```
unable to recognize "01-standalone/kustomization.yaml": no matches for kind "Kustomization" in version "kustomize.config.k8s.io/v1beta1"
```






