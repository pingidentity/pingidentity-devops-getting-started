---
title: Orchestrating a Replicated PingDirectory Deployment
---
# Orchestrating a Replicated PingDirectory Deployment

Use kustomize for the replicated deployment of PingDirectory from your local `pingidentity-devops-getting-started/20-kustomize/03-replicated-pingdirectory` directory (the location of the YAML files) and call into your local `pingidentity-devops-getting-started/20-kustomize/01-standalone/pingdirectory` and `pingidentity-devops-getting-started/20-kustomize/01-standalone/pingdataconsole` directories for the base product configurations.

Use the PingDirectory server profile in our [pingidentity-server-profiles/baseline](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline) repository.

The `env_vars.pingdirectory` file contains:

* The environment variables to use for `pingidentity-server-profiles/baseline/pingdirectory`
* The Kubernetes declarations for PingDirectory
* An initial creation of 1,000 PingDirectory users
* A command to `tail` the log files for display

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kustomize/01-standalone/pingdirectory` and `pingidentity-devops-getting-started/20-kustomize/01-standalone/pingdataconsole` directories for the base product configurations.
* References a mounted Kubernetes storage class volume for disaster recovery (`storage.yaml`).
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.pingdirectory` file.

See also [Orchestrate PingDirectory Deployments Across Kubernetes Clusters](deployK8sPD-clusters.md).

## Deploying the stack

To orchestrate the replicated PingDirectory deployment, from your local `pingidentity-devops-getting-started/20-kustomize/03-replicated-pingdirectory` directory, enter:

```sh
kustomize build . | kubectl apply -f -
```

## Cleaning Up

To clean up when you're finished, enter:

```sh
kustomize build . | kubectl delete -f -
```
