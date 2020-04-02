# PingFederate Product Version Upgrade in a DevOps Environment

Traditionally, PingFederate upgrades would follow the guide on product documentation. In a proper devops environment upgrades are drastically simplified through automation, orchestration and separation of concerns. As a result, upgrading to a new version of PingFederate is much more like deploying any other configuration <!-- (link here to doc explaining config deployments) -->. The slight difference being that configuration updates can be achieved with zero-downtime and no loss of state, wheras  in version upgrades we consciously sacrifice state to maintain zero overall downtime. Note, you can take a traditional upgrade approach to a containerized environment, but it provides no value above the process described here. 

In this document, we'll cover upgrading a PingFederate deployment from 9.3.3 to 10.0.0 withinin a Kubernetes environment by following an example

## Overview

> Prerequisites: **Required** before following this document, you should have a solid understanding of what profiles are. **Optional** it will help to have an understanding of how blue-gren happens in services in kubernetes. 

> Note: This guide discusses an upgrade for a Kubernetes deployment, but the concepts should work with any container orchestrator.

A successful version upgrade follows these steps:

  1. [Setup and Background](#setup-and-background) - How to set up your environment for success
  2. [Local Profile Upgrade](#local-profile-upgrade) - 
  3. [Blue-Green It](#blue-green-it)
  - [Considerations](#considerations)

## Setup and Background

The most important factor to a successful version upgrade is preparing an environment for success. 

This means: 
  - Following "the devops way"
  - Having a process for Blue-green - In Kubernetes, we simply update a selector on a service.

### the devops way

In a proper devops setup:
  - _**All software features migrate through environments**_ - yes, identity software too! You should have at least 2 environments (non-prod and production). This gives room to test everything before putting it in production. 
  - _**Environments are nearly identical**_ - All deployments should be stringintly validated before rolling into production. To be confident in your manual and automated tests, your environments need to be as close to identitcal as possible. In an ideal world, environments have dummy data, but function the exact same. You know you're doing a good job when the only thing that changes (related to configuration) between environments is URLs, endpoints, and variable values.
  - _**Containers in production are immutable**_ - Nobody is perfect. So, we should never trust manual changes directly in production. Cut-off all admin access to production!
  - _**All configurations are maintained in source control**_ - If you can roll it out, you better be able to roll it back too!

Our "example" environment is set up with jmeter throwing load to a Kubernetes "service" [[1](#1)] (which routes load to downstream pingfederate containers). 

<img>

The key here is that the service is pointing to this deployment of PingFederate because of a "selector" defined on the service that matches a label on the PingFederate "deployment" [[2](#2)]. This is what will make the blue-green approach possible. 

## Local Profile Upgrade

Once you have an environment set up for success, you can do the product upgrade 'offline'. Meaning we'll pull the profile in a docker container on our local workstation to upgrade it. 

Before going into the actual steps for a profile upgrade. It is very worth noting that if your profile is made well, meaning it's bare minimum files that are specific to the PingFederate configuration, you may be able to avoid this entire section. For example, our "baseline" profile (https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline) worked almost flawlessly from 9.3.3 to 10.0.0. In face the only file that required an update was adding a "Pairwise definition" to `./instance/server/default/conf/hivemodule.xml`. This may very well be the case for you also. So, perhaps try just using your profile with the new version image tag watch the logs

The following steps discuss at a generic level what needs to happed to upgrade a pingfederate profile. Some details of the upgrade will be different in your case based on the considerations of PingFederate profiles. You may notice these steps are similar to "[Upgrading PingFederate on Linux systems](https://docs.pingidentity.com/bundle/pingfederate-100/page/ukh1564003034797.html)" As such, you will want to refer to this document during steps 3-4. 
<!--- TODO: link to PF profile --->

1. Check out a feature branch (e.g. `pf-10.0.0`) off the master of _your_ current version of PingFederate (9.3.3 in our example)

2. Spin up a pingfederate container/deployment based on this branch with /opt/out mounted. For clarity, we'll do this in docker-compose and consider this mount like `~/tmp/pf93/instance:/opt/out/instance`. Once the container is healthy, stop the container. 

3. Download the latest version of the PingFederate Server distribution .zip file from the Ping Identity website. Unzip the distribution .zip file into `~/tmp/pf93`

4. cd to `~/tmp/pf93`. Run the upgrade utility. `./upgrade.sh <pf_install_source> [-l <newPingFederateLicense>] [-c]`

5. Clean up! The result of Step 4 is an upgraded PingFederate profile, plus a lot of bloat. The goal for cleanup is to be able to run `git diff` and see _only_ upgraded files. A good text editor like VScode with git extensions is invaluable for this process. Copy over files from your new profile `~/tmp/pf93/instance` on top of your current profile. This part is annoying, but you have to watch out to not directly copy over and replace `.subst` files. If you are using VScode, you can `right-click`>'Select for compare' on the old file and `right-click`>'Compare with selected' on the new file. This compares line-by-line diffs. If all you see is your variables, you can ignore the whole file. 

6. After you test it out, push your new changes to your source control.

## Blue Green It

Now that we have a new profile, we simply stand up a new deployment that uses it and flip all our traffic over to it. 

1. Stand up a new 'deployment' that is using the: 1. the correct product image version 2. the new profile. 3. has a label on the deployment that separates it vs the old deployment (e.g. `version: 10.0.0`)

2. Once the deployment is healthy and ready to accept traffic, update the "selector" on the 'service'. This now routes all traffic to the new PingFederate without taking any downtime!

## Considerations

If you've followed this document you may have noted that parts of it can be intimidating. This is common in organizations that have adopted devops. You sacrifice things like 'comfortable setup' and 'admin UI in production' for 'zero-downtime rollouts and rollbacks', which for most organizations that have customers as end-users is a very worthwhile tradeoff. In our scenario, it may feel cumbersome to upgrade a profile, but we must keep the value of not taking downtime top of mind. 

Additionally, note that we have used the terms 'zero-downtime' and 'loss-of-state' separately. The two terms are significantly different. Zero-downtime is what this document achieves. This means there is no point in time that users should experience a `500 bad gateway` error. But, we are sacrificing state to achieve this. Because we are moving from one entire deployment to another, the new deployment does not (and _cannot_) have access to runtime state in the previous deployment. This is why it is **critical** to externalize as much state as possible. 

##### 1
service - this is essentially a load balancer that follows a round-robin strategy with keep-alive.
##### 2 
deployment - a deployment in kubernetes is a sort of manager of containers in pods. It defines things like: which containers to run, how many, metadata labels, and update strategy. 
