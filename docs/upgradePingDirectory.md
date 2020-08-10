# PingDirectory Upgrade in a Devops environment

PingDirectory is a database, as such, in it's container form each node in a cluster has it's own persisted volume. With PingDirectory being an application that _focuses_ on state, rolling out an upgrade cannot necessarily be considered the same as any other configuration update. However, the product software and scripts in the image provide a process in which upgrades are drastically simplified. 

> This document will focus on a PingDirectory upgrade specifically in a default Kubernetes environment. 

As an example, we'll walk through upgrading a PingDirectory Statefulset 8.0.0.1 to 8.1.0.0 via an incremental canary roll-out. 

## Tips

To build confidence in the upgrade process, follow some considerations:

* Avoid combining configuration changes and version upgrades in the same rollout. This adds unnecessary complexity to debugging errors during an upgrade.
* Successfully complete an upgrade in a proper dev/QA environment before trying anything in production. 
* Upgrades will happen on one server at a time. Ensure you have enough resources on the remaining machines to prevent client impact.
* Follow a canary deployment pattern (example below) to ensure the changes will be successful before a full rollout. There is no _good_ way to roll back a completed upgrade, so take any steps to avoid the need.


## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products
* A good understanding of how to use our DevOps server profiles
* Access to a Kubernetes cluster and a default StorageClass
* An understanding of statefulsets in Kubernetes is helpful
* If in your own environment and using mounted licenses, you will need the license for current version to be in /opt/out (persisted volume) and a license corresponding to the new version in /opt/in. (not needed if using devops user/key in evaluation)

## What you'll do

* [Setup](#setup) - start with a base stack
* [Partition](#partition) - set up a partion to make changes on just one node
* [Stage](#stage) - deploy changes to one node fix any errors
* [Rollout](#rollout) - rollout changes to other nodes


## Summary

The key functionality to note in PingDirectory upgrades is the relationship between the image hooks and the `manage-profile` command in the product. 

In a simple explanation: 
  1. When a node starts for the first time it is in `SETUP` mode and runs `manage-profile setup`. 
  2. When a node restarts (for whatever reason), it runs `manage-profile replace-profile`. 
    - this command stands compares the new profile to the old profile, and if there is a change, it tries standing up the server with the new profile. 
    - Errors will be thrown if there is a configuration in the new profile that prevents it from being applied. 
  3. If `manage-profile replace-profile` notices a product version difference, it takes the same approach as any other restart. It will attempt to migrate the database to the new version, and the command will fail if it cannot. 

Because there is processing that happens automatically in the container during this, we want to roll the change out to a small partition first and test it thoroughly before rolling it out to all. This partition also gives us room to revert back without impacting traffic in case something is not as expected. 
This process in standard Kubernetes is called a Canary Rollout and is derived from [Kubernetes documentation on StatefulSet update strategies](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies)]

> Note "Canary Rollout" in this scenario focuses only on an incremental rollout of containers, not actually separating traffic. That could be done with additional tools like Istio, or standing up a another service with and pairing separate labels and selectors. 

## Setup


Start with a PingDirectory statefulset using persistent volumes. 
> All kubectl commands should be run from their corresponding directory. 

  ```
  kubectl apply -f 1-initial.yaml
  ```

This will stand up a two directory topology, each with its own Persistent Volume Claim using the default storage class. 

Wait for both nodes to be healthy before continuing. 

  ```
  kubectl get pods
  ```
`pingdirectory-0` and `pingdirectory-1` should show `1/1` in the `READY` column

## Partition

Now add a partition to the `StatefulSet` `UpdateStrategy`, 

  ```
  kubectl apply -f 2-partition.yaml
  ```

This partition signifies that any changes to the `spec.template` with only be applied to nodes with cardinal higher than the partition definition.

## Stage

Then stage the change. 

  ```
  kubectl apply -f 3-staging.yaml
  ```
The only _actual_ change is to the image tag. When this change is applied:
  1. `pingdirectory-1` pod will be terminated and a new one with the new image will started.
  2. the new pingdirectory container is based on a specific version of PingDirectory, whose software 'bits' are found in /opt/server. 
  3. the `manage-profile replace-profile` command will eventually be triggered when the container notices PingDirectory is in a `RESTART` state. This command sees the difference in the database version from what is running based on the persisted volume attached to `/opt/out`, and then attempts to upgrade: 

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

> Note - this process requires having licenses for both server versions available and in the right location.

If `manage-profile replace-profile` completes without error, you will see the container continue the migration and eventually start up PingDirectory. 

If `manage-profile replace-profile` fails, you will be given an error and the container will exit. The errors will be due to some conflict in the server profile. The partition set up previously provides an isolated environment for working out errors. Work through any errors until you can get `manage-profile replace-profile` to complete successfully before continuing.

## Rollout

Now that you are confident your upgrade will occur smoothly, you can deploy the rollout to remaining nodes by removing the partition 

  ```
  kubectl apply -f 4-rollout.yaml
  ```