---
title: Upgrading PingDirectory
---
# Upgrading PingDirectory

Because PingDirectory is essentially a database, in its container form, each node in a cluster has its own persisted volume. Additionally, because PingDirectory is an application that _focuses_ on state, rolling out an upgrade isn't really the same as any other configuration update. However, the product software, and scripts in the image provide a process through which upgrades are drastically simplified.

This use case focuses on a PingDirectory upgrade in a default Kubernetes environment where you upgrade a PingDirectory StatefulSet 8.0.0.1 to 8.1.0.0 using an incremental canary roll-out.

## Tips

To ensure a successful upgrade process:

* Avoid combining configuration changes and version upgrades in the same rollout. This adds unnecessary complexity to debugging errors during an upgrade.
* Successfully complete an upgrade in a proper Dev/QA environment before trying anything in production.
* Upgrades will happen on one server at a time. Ensure you have enough resources on the remaining machines to prevent client impact.
* Follow a canary deployment pattern to ensure the changes will be successful before doing a full rollout. There is no _good_ way to roll back a completed upgrade, so take any necessary steps to avoid this.

## Before you begin

You must:

* Complete [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Clone or download the `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` repository to your local `${HOME}/projects/devops` directory.
* Understand how to use our DevOps server profiles.
* Have access to a Kubernetes cluster and a default StorageClass.
* Understand how StatefulSets in Kubernetes is helpful.
* If you're upgrading in your own environment and using mounted licenses, have the license for the existing version in the `/opt/out` persisted volume and a license for the new version needs to be in `/opt/in`.

   The license locations aren't an needed if you're using our DevOps credentials in an evaluation context.

## About this task

You will:

* Start with a base stack.
* Set up a partition to make changes on just one node.
* Deploy changes to one node and fix any errors.
* Rollout changes to other nodes.

## Upgrade process overview

The key functionality for PingDirectory upgrades is the relationship between the image hooks and the `manage-profile` command in the product.

The upgrade is processed as follows:

1. When a node starts for the first time, it' i's in `SETUP` mode and runs `manage-profile setup`.

1. When a node restarts (for whatever reason), it runs `manage-profile replace-profile`.

      * This command compares the new profile to the old profile, and if there is a change, it tries standing up the server with the new profile.

      * Errors are thrown if there's a configuration in the new profile that prevents it from being applied.

1. If `manage-profile replace-profile` detects a product version difference, it takes the same approach as any other restart. It attempts to migrate PingDirectory to the new version, and if it can't, the command fails.

      Because there is processing that happens automatically in the container during the upgrade, you should roll the change out to a small partition first and test it thoroughly before rolling it out to all. This partition also gives us room to revert back without impacting traffic in case something is not as expected.

      This process in standard Kubernetes is called a Canary Rollout and is derived from [Kubernetes documentation on StatefulSet update strategies](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies).

      > "Canary Rollout" in this scenario focuses only on an incremental rollout of containers, not actually separating traffic. That could be done with additional tools like Istio or standing up another service and pairing separate labels and selectors.

## Setting up the base stack

The YAML configuration files for this use case are in your cloned local copy of the `pingidentity-devops-getting-started` repository

1. To use the `1-initial.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to start with a PingDirectory StatefulSet using persistent volumes, enter:

      ```sh
      kubectl apply -f 1-initial.yaml
      ```

      > All kubectl commands for this use case need to be run from the `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory.

      This stands up a two directory topology, each with its own Persistent Volume Claim using the default storage class.

1. Wait for both nodes to be healthy before continuing and then enter:

      ```sh
      kubectl get pods
      ```

      `pingdirectory-0` and `pingdirectory-1` should show `1/1` in the `READY` column.

## Setting up a partition

To use the `2-partition.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to add a partition to `StatefulSet` for `updateStrategy`, enter:

```sh
kubectl apply -f 2-partition.yaml
```

This partition configuration signifies that any changes to `spec.template` will only be applied to nodes with a cardinal value higher than the partition definition.

## Staging changes

To use the `3-staging.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to stage the change, enter:

```sh
kubectl apply -f 3-staging.yaml
```

The only _actual_ change is to the image tag. When this change is applied:

1. The `pingdirectory-1` pod is terminated and a new one with the new image is started.

1. The new PingDirectory container is based on a specific version of PingDirectory, found in the `/opt/server` volume.

1. The `manage-profile replace-profile` command is eventually triggered when the container detects PingDirectory is in a `RESTART` state. This command identifies the difference in the database version running, based on the persisted volume attached to `/opt/out`, and then attempts to upgrade. Information similar to the following will be displayed:

      ```text
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

      If `manage-profile replace-profile` fails, an error is displayed and the container exits. The errors are because of some conflict in the server profile. The partition you set up previously provides an isolated environment for working out errors.

      Work through any errors until you can get `manage-profile replace-profile` to complete successfully before continuing.

## Rolling out the changes

When you're confident your upgrade will occur smoothly:

To use the `4-rollout.yaml` file in your local `pingidentity-devops-getting-started/20-kubernetes/12-pingdirectory-upgrade` directory to deploy the rollout to the remaining nodes, enter:

```sh
kubectl apply -f 4-rollout.yaml
```

This removes the partition.
