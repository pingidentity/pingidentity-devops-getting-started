---
title: Upgrading PingFederate
---

# Upgrading PingFederate

In a DevOps environment, upgrades can be simplified through automation, orchestration, and separation of concerns.

General Steps:

- [Persistent Volume Upgrade](#persistent-volume-upgrade) of `/opt/out/instance/server/default/data` on pingfederate-admin
- [Server Profile Upgrade](#server-profile-upgrade)
- [Migrate Cluster Discovery Settings](#migrate-cluster-discovery-settings)
- [Post Upgrade](#post-upgrade)

[Persistent Volume Upgrade](#persistent-volume-upgrade) will include steps helpful to both pieces. [Server Profile Upgrade](#server-profile-upgrade) will discuss extracting upgraded files.

## Caveats

1.  **This Document Assumes Kubernetes and Helm**

    The terms in this document will focus on deployments in a Kubernetes Environment using the ping-devops Helm chart. However, the concepts should apply to any containerized PingFederate Deployment.

1.  **This Document will Become Outdated**

    The examples referenced in this document point to a specific tag. This tag may not exist anymore at the time of reading. To correct the issue, update the tag on your file to N -1 from the current PF version.

1.  **Upgrades from Traditional Deployment**

    It may be desirable to upgrade PingFederate along with migrating from a traditional environment. This is not recommended. Instead you should upgrade your current environment to the desired version of PingFederate and then [create a profile](./buildPingFederateProfile.md) that can be used in a containerized deployment.

1.  **Persistent Volume on `/opt/out`**

    The suggested script should not be used if a persistent volume is attached to `/opt/out`. New software bits will not include special files built into the docker image. It is recommended to mount volumes on PingFederate Admin to `/opt/out/instance/server/default/data`.
    <!--TODO: If you do have /opt/out mounted, instead of running the the example script,  -->

1.  **Irrelevant Ingress**

    The values.yaml files mentioned in this document expects and nginx ingress controller with class `nginx-public`. It is not an issue if your environment doesn't have this, the created ingresses will not be used.

    <!--TODO: flip. upgrade happens first. then discuss persistence and server profile.   -->

## Persistent Volume Upgrade

Steps needed in both Server-Profile upgrade and Persistent Volume upgrade include:

1.  Deploy your PingFederate version and server profile **as background process**
1.  Upgrade profile in container
    1. Backup the files in your profile.
    1. Download the PingFederate software bits for the new version.
    1. Run upgrade utility
    1. diff to view the changes. (optional)
1.  Reconfigure any variablized components.
1.  Export changes to your profile

Here we will walk through an example upgrade.

!!! Info "This Process Requires Container Exec Access"
Your orchestration user will need access to `kubectl exec -it <pod> -- sh` for multiple steps here.

### Deploy PingFederate as a Background Process

Deploy your PingFederate version and server profile as background process with Helm:

!!! Info "Make sure you have a devops-secret"
If you are using this example as is, you will need a [devops-secret](../how-to/devopsUserKey.md#for-kubernetes)

!!! Info "Be sure to change the ingress domain name value to your domain in [01-background.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingfederate-upgrade/01-background.yaml)"

!!! Info "Be sure to change the image tag value in [01-background.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingfederate-upgrade/01-background.yaml)"

```
helm upgrade --install pf-upgrade pingidentity/ping-devops \
   --version 0.9.4 -f 30-helm/pingfederate-upgrade/01-background.yaml
```

The `args` section starts PingFederate as a background process and `tail -f /dev/null` as the foreground process.

### Upgrade Profile in Container

The steps for upgrading can be automated with a script. Example scripts are included at `30-helm/pingfederate-upgrade/hooks`.

To use the scripts:

Copy the hooks folder to your PingFederate container

```
kubectl cp 30-helm/pingfederate-upgrade/hooks pf-upgrade-pingfederate-admin-0:/opt/staging
```

Copy the target PingFederate license to your PingFederate container
See [pingctl license](https://devops.pingidentity.com/tools/commands/license/) documentation to retrieve an evaluation license,
or provide an existing product license here.

```
kubectl cp pingfederate.lic pf-upgrade-pingfederate-admin-0:/tmp
```

Copy the target PingFederate software to your PingFederate container. See [How to download Product Installation Files](#how-to-download-product-installation-files).

```
kubectl cp pingfederate-11.1.1.zip pf-upgrade-pingfederate-admin-0:/tmp
```

#### How to download Product Installation Files

1. Navigate to [Ping Identity's Download webpage](https://www.pingidentity.com/en/resources/downloads.html).

2. Select a Product download page, for example: [PingFederate Download Page](https://www.pingidentity.com/en/resources/downloads/pingfederate.html).

3. Click on the download button for the desired installation method and product version.

   1. If prompted to sign in, please sign in and the download will begin. Alternatively, [Sign In Here](https://www.pingidentity.com/en/account/sign-on.html).

   2. If you do not have a Ping Identity account, you can create one on the [Account Creation Page](https://www.pingidentity.com/en/try-ping.html).

### Run the Upgrade Utility

The pf-upgrade.sh script will:

- Verify both the PingFederate software bits and new license file is on the container
- Backup the current /opt/out folder to /opt/current_bak
- Run the upgrade utility
- Overwrite /opt/out or /opt/out/instance/server/default/data with upgraded files
- Run diff between /opt/staging (server-profile location) and respective upgraded file. Diffs can be found in `/tmp/stagingDiffs`

Exec into the container and run the script.

```
kubectl exec -it pf-upgrade-pingfederate-admin-0 -- sh
cd /opt/staging/hooks
sh pf-upgrade.sh 10.3.4
```

At the conclusion of the script you will have an upgraded `/opt/out/instance/server/default/data` folder.

## Server Profile Upgrade

If your profile is applied on each start of your container, you should keep your profile up to date with the product version you are deploying.

After the previously run script, you can find upgraded profile files in `/opt/new_staging`
These files will be hard-coded and you should follow [Build a PingFederate Profile](./buildPingFederateProfile.md) as needed for templating.

Additionally, If you use the bulk-config data.json import it will not be found here. It should be imported via the standard process on the next container start.

## Migrate Cluster Discovery Settings

To simplify future upgrades, migrate the cluster discovery settings in the `tcp.xml` file to the `jgroups.properties` file.

You can find the default `jgroups.properties` file [here](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingfederate/opt/staging/instance/bin/jgroups.properties.subst.default).

For more information, see [Migrate Cluster Discovery Settings](https://docs.pingidentity.com/access/sources/dita/topic?category=pingfederate&Releasestatus_ce=Current&resourceid=pf_migrate_cluster_discovery_settings) in the PingFederate admin guide.

## Post Upgrade

To enable PingFederate admin as a foreground process, scale it down first.

```
kubectl scale sts pf-upgrade-pingfederate-admin --replicas=0
```

Finally, update PingFederate image version to new target PingFederate version and run as normal.

!!! Info "Be sure to change the ingress domain name value to your domain in [02-upgraded.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingfederate-upgrade/02-upgraded.yaml)"

!!! Info "Be sure to change the image tag value in [02-upgraded.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingfederate-upgrade/02-upgraded.yaml)"

```
helm upgrade --install pf-upgrade pingidentity/ping-devops --version 0.9.4 \
   -f 30-helm/pingfederate-upgrade/02-upgraded.yaml
```
This will restart the admin console, and trigger a rolling update of all the engines.

!!! Info "Old Profile"
The final yaml `30-helm/pingfederate-upgrade/02-upgraded.yaml` still points to the same profile. The steps that should have been completed in [Server Profile Upgrade](#server-profile-upgrade) were not included.

Connecting to the admin console will now show the upgraded version in cluster management.
