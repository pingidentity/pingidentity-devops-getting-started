# Upgrading PingFederate

In a DevOps environment, upgrades are drastically simplified through automation, orchestration and separation of concerns. As a result, upgrading to a new version of PingFederate is much more like deploying any other configuration. <!-- (link here to doc explaining config deployments) --> The slight difference is that configuration updates can be achieved with zero downtime and no loss of state, whereas in version upgrades we consciously sacrifice state to maintain zero downtime overall.

> You can take a traditional upgrade approach to a containerized environment, but it provides no value above the process described here.

As an example, we'll walk through upgrading a PingFederate deployment from 9.3.3 to 10.0.0 in a Kubernetes environment. However, the concepts should work with any container orchestrator.

## Prerequisites

* You've already been through [Get started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* A good understanding of how to use our DevOps server profiles.
* An understanding of blue-green deployments in Kubernetes is helpful.

## What You'll Do

* Setup and preparation
* Upgrade using a local profile
* Blue-Green Deployment
* Some final considerations

## Setup and Preparation

The most important factor to a successful version upgrade is preparing an environment for success. This means using the DevOps process, and a blue-green deployment. For a blue-green Kubernetes deployment, we simply update a selector on a service.

The DevOps process:

* **All software features migrate through environments**.

  You should have at least 2 environments (non-production and production). This gives you room to test everything before putting it into production.

* **Environments are nearly identical**.

  All deployments should be stringently validated before rolling into production. To be confident in your manual and automated tests, your environments need to be as close to identical as possible. In an ideal world, environments have dummy data, but function exactly the same. You know you're doing a good job when the only thing that changes (related to configuration) between environments is URLs, endpoints, and variable values.

* **Containers in production are immutable**.

  Nobody is perfect. So, we should never trust manual changes directly in production. You should disable all admin access to production.

* **All configurations are maintained in source control**.

  If you can roll it out, you better be able to roll it back too!

Our example environment is set up with Apache JMeter throwing load to a Kubernetes service (which routes load to downstream PingFederate containers). This Kubernetes service is essentially a load balancer that follows a round-robin strategy with keep-alive.

![alt text](../images/pf-upgrade_1_version9.3.3.png "Initial deployment")

The key here is that the service is pointing to this deployment of PingFederate due to a selector defined on the service that matches a label on the PingFederate deployment. This is what will make the blue-green approach possible.

> A deployment in Kubernetes manages containers in pods, defining things like which containers to run, how many containers, the metadata labels, and the update strategy.

## Upgrade Using a Local Profile

With your environment set up properly, you can do the product upgrade offline. Offline here means we'll pull the profile into a Docker container on our local workstation to upgrade it.

Before going into the actual steps for a profile upgrade. It's very worth noting that if your profile is well-constructed, using the minimum number of files that are specific to the PingFederate configuration, you may be able to avoid this entire section.

For example, the upgrade for our baseline profile (https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline) worked almost flawlessly from 9.3.3 to 10.0.0. In fact the only file that required an update was adding a "Pairwise definition" to `./instance/server/default/conf/hivemodule.xml`. This may very well be the case for you as well. If you want to try this, just use your PingFederate profile with the new version image tag, and watch the logs for errors.

Some details of the upgrade process may be different for you, based on your PingFederate profile.
<!--- TODO: link to PF profile --->

1. Check out a PingFederate feature branch (such as, `pf-10.0.0`) off of the master of _your_ current version of PingFederate (9.3.3 in our example).

1. Spin up a PingFederate deployment based on this branch with the `/opt/out` volume mounted. For clarity, let's do this in Docker Compose and assume the mount looks something like this: `~/tmp/pf93/instance:/opt/out/instance`. Once the container is healthy, stop the container.

1. Download the latest version of the PingFederate Server distribution ZIP file from the Ping Identity website. Extract the distribution ZIP file into `~/tmp/pf93`.

1. Go to the `~/tmp/pf93` directory, and run the PingFederate upgrade utility:

    ```shell
    ./upgrade.sh <pf_install_source> [-l <newPingFederateLicense>] [-c].
    ```

    > See [Upgrading PingFederate on Linux Systems](https://docs.pingidentity.com/bundle/pingfederate-100/page/ukh1564003034797.html) for more information.

1. The result is an upgraded PingFederate profile with a lot of bloat. Let's clean this up so that we're able to run `git diff` and see _only_ upgraded files. A good text editor (such as, Microsoft Visual Studio Code) with Git extensions is invaluable for this process.

    1. Copy over files from your new profile `~/tmp/pf93/instance` on top of your current profile. Be careful not to directly copy over and replace `.subst` files. If you are using Visual Studio Code, you can `right-click` -> Select for compare on the old file and `right-click`>'Compare with selected' on the new file. This compares line-by-line diffs. If all you see is your variables, you can ignore the whole file.

6. After you test the upgrade, push your changes to Git.

## Blue-Green Deployment

Now that you have a new profile, you can stand up a new deployment that uses it and flip all of the traffic over to it.

1. Stand up a new deployment using:

    * The correct product image version.
    * The new profile.
    * A label on the deployment that distinguishes it from the prior deployment (such as, `version: 10.0.0`).

2. When the deployment is healthy and ready to accept traffic, update the selector on the Kubernetes service. This routes all traffic to the new PingFederate deployment without downtime occurring.

## Some Final Considerations

Using DevOps processes can mean that things like comfortable setup processes and admin UIs in production are sacrificed, but for most organizations, the resulting zero downtime for rollouts and rollbacks is easily worth it.

Note that terms "zero downtime" and "loss-of-state" are significantly different. Zero downtime is what this upgrade process achieves: at no point in time will users experience a `500 bad gateway` error. However, we are sacrificing state to achieve this. Because we are moving from one entire deployment to another, the new deployment does _cannot_ have access to runtime state in the previous deployment. For this reason, it's critical to externalize state as much as possible.
