# Orchestrate a replicated PingDirectory deployment

You'll use kustomize for the replicated deployment of PingDirectory from your local `pingidentity-devops-getting-started/20-kubernetes/03-replicated-pingdirectory` directory (the location of the YAML files), and call into your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdirectory` and `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdataconsole` directories for the base product configurations. You'll use the PingDirectory server profile in our [pingidentity-server-profiles/baseline](../../pingidentity-server-profiles/baseline) repository.

The `env_vars.pingdirectory` file contains: 

* The environment variables to use for `pingidentity-server-profiles/baseline/pingdirectory`. 
* The Kubernetes declarations for PingDirectory. 
* An initial creation of 1,000 PingDirectory users. 
* A command to `tail` the log files for display. 

`kustomization.yaml` does the following:

* References your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdirectory` and `pingidentity-devops-getting-started/20-kubernetes/01-standalone/pingdataconsole` directories for the base product configurations. 
* References a mounted Kubernetes storage class volume for disaster recovery (`storage.yaml`). 
* Replaces the environment variables in the parent `configMap` with those in the specified `env_vars.pingdirectory` file.

See also [Orchestrate PingDirectory deployments across Kubernetes clusters](deployK8sPD-clusters.md).

## Deploy the stack

1. To orchestrate the replicated PingDirectory deployment, from your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter:

   ```bash
   kubectl apply -k 03-replicated-pingdirectory/
   ```

2. To clean up when you're finished, enter: 

   ```bash
   kubectl delete -k 03-replicated-pingdirectory/
   ```

