# Upgrading PingDirectory in a DevOps environment

Because PingDirectory is essentially a database, in it's container form each node in a cluster has its own persisted volume. Additionally, because PingDirectory is an application that _focuses_ on state, rolling out an upgrade isn't really the same as any other configuration update. However, the product software, and scripts in the image provide a process through which upgrades are drastically simplified. 

This use case focuses on a PingDirectory upgrade in a default Kubernetes environment. You'll upgrade a PingDirectory StatefulSet 8.0.0.1 to 8.1.0.0 using an incremental canary roll-out. 

## Tips

To ensure a successful upgrade process:

* Avoid combining configuration changes and version upgrades in the same rollout. This adds unnecessary complexity to debugging errors during an upgrade.
  
* Successfully complete an upgrade in a proper Dev/QA environment before trying anything in production. 
  
* Upgrades will happen on one server at a time. Ensure you have enough resources on the remaining machines to prevent client impact.
  
* Follow a canary deployment pattern to ensure the changes will be successful before doing a full rollout. There is no _good_ way to roll back a completed upgrade, so take any necessary steps to avoid this.

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
  
* You've cloned or downloaded the `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` repository to your local `${HOME}/projects/devops` directory.

* A good understanding of how to use our DevOps server profiles.
  
* Access to a Kubernetes cluster and a default StorageClass.
  
* An understanding of StatefulSets in Kubernetes is helpful.
  
* If you're upgrading in your own environment and using mounted licenses, the license for the existing version needs to be in the `/opt/out` persisted volume, and a license for the new version needs to be in `/opt/in`. The license locations are not an needed if you're using our DevOps credentials in an evaluation context.

## What you'll do

* [Setup](#setup). Start with a base stack.
  
* [Partition](#partition). Set up a partition to make changes on just one node.
  
* [Stage](#stage). Deploy changes to one node and fix any errors.
  
* [Rollout](#rollout). Rollout changes to other nodes.


## Summary

The key functionality for PingDirectory upgrades is the relationship between the image hooks and the `manage-profile` command in the product. 

The upgrade is processed in this way:

1. When a node starts for the first time it is in `SETUP` mode and runs `manage-profile setup`. 

2. When a node restarts (for whatever reason), it runs `manage-profile replace-profile`. 

   - This command compares the new profile to the old profile, and if there is a change, it tries standing up the server with the new profile. 

   - Errors will be thrown if there is a configuration in the new profile that prevents it from being applied. 

3. If `manage-profile replace-profile` detects a product version difference, it takes the same approach as any other restart. It will attempt to migrate PingDirectory to the new version, and the command will fail if it cannot. 

Because there is processing that happens automatically in the container during the upgrade, you want to roll the change out to a small partition first and test it thoroughly before rolling it out to all. This partition also gives us room to revert back without impacting traffic in case something is not as expected. 

This process in standard Kubernetes is called a Canary Rollout and is derived from [Kubernetes documentation on StatefulSet update strategies](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies).

> "Canary Rollout" in this scenario focuses only on an incremental rollout of containers, not actually separating traffic. That could be done with additional tools like Istio, or standing up another service and pairing separate labels and selectors. 

## Setup

The YAML configuration files for this use case are in your local 

1. Use the `1-initial.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to start with a PingDirectory StatefulSet using persistent volumes. Enter:

     ```shell
     kubectl apply -f 1-initial.yaml
     ```

   > All kubectl commands for this use case need to be run from the `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory. 

   This will stand up a two directory topology, each with its own Persistent Volume Claim using the default storage class. 

2. Wait for both nodes to be healthy before continuing. Enter:

   ```shell
   kubectl get pods
   ```

   `pingdirectory-0` and `pingdirectory-1` should show `1/1` in the `READY` column.

## Partition

Use the `2-partition.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to add a partition to `StatefulSet` for `updateStrategy`. Enter: 

```
kubectl apply -f 2-partition.yaml
```

This partition configuration signifies that any changes to `spec.template` will only be applied to nodes with a cardinal value higher than the partition definition.

## Stage

Use the `3-staging.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to stage the change. Enter:

```shell
kubectl apply -f 3-staging.yaml
```

The only _actual_ change is to the image tag. When this change is applied:

  1. The `pingdirectory-1` pod will be terminated and a new one with the new image will started.

  2. The new PingDirectory container is based on a specific version of PingDirectory, found in the `/opt/server` volume. 

  3. The `manage-profile replace-profile` command will eventually be triggered when the container detects PingDirectory is in a `RESTART` state. This command identifies the difference in the database version running, based on the persisted volume attached to `/opt/out`, and then attempts to upgrade. Information similar to the following will be displayed:

     ```
     ...
     pingdirectory-1 Validating source and existing servers ..... Done
     pingdirectory-1 Updating the server version from 8.0.0.1 to 8.1.0.0. Local database backends
     pingdirectory-1 will be exported before the update in case a revert is necessary
     pingdirectory-1 Exporting backend with backendID userRoot. This may take a while ..... Done
     pingdirectory-1 Running the update tool ..... Done
     ...
     pingdirectory-1 Cleaning up after replace ..... Done
     pingdirectory-1   manage-profile replace-profile returned 0
     ```

> This process requires having licenses for both server versions available and in the right location.

If `manage-profile replace-profile` completes without error, you'll see the container continue the migration and eventually start up PingDirectory. 

If `manage-profile replace-profile` fails, an error is displayed and the container will exit. The errors will be due to some conflict in the server profile. The partition you set up previously provides an isolated environment for working out errors. Work through any errors until you can get `manage-profile replace-profile` to complete successfully before continuing.

## Rollout

When you're confident your upgrade will occur smoothly, use the `4-rollout.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to deploy the rollout to the remaining nodes. This will remove the partition. Enter:

```shell
kubectl apply -f 4-rollout.yaml
```
