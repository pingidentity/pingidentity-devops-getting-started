---
title: Migrating from privileged images to unprivileged-by-default images
---
# Migrating from privileged images to unprivileged-by-default images

In the [2103 release](https://devops.pingidentity.com/release-notes/relnotes-2103/), our product images were updated to run with an unprivileged user by default. Before this release, images ran as root by default. This document describes some important tips when moving from privileged to unprivileged images.

## Checklist before migration
- To ensure that any configuration of the pods is maintained, build and commit a server profile from your current workload into a git repository.
  - See the [Server Profile Structures](https://devops.pingidentity.com/reference/profileStructures/) page, and/or the product-specific guides for [PingFederate](https://devops.pingidentity.com/how-to/buildPingFederateProfile/) and [PingDirectory](https://devops.pingidentity.com/how-to/buildPingDirectoryProfile/).
- For PingDirectory, export your user data that will be imported into the new server(s). You can include the basic DIT structure in the server profile (in the `pd.profile/ldif/userRoot/` directory), but actual user data should be left out; the server profile should store configuration, not data. You can save the actual user data elsewhere and manually import it after the new pods have started.
  - You can use the `export-ldif` command to export user data, or you can schedule a task via LDAP. The exported ldif file will write to the pod filesystem.
  - You can use the `import-ldif` command to import user data, or you can schedule a task via LDAP. For the import to run, the file to be imported must exist on the pod filesystem.

## Potential issues
### Persistent volumes

In Kubernetes, persistent volumes created with our older containers have files owned by the root user. When the default non-privileged user attempts to use these existing volumes, there might be file permission errors.

To avoid this, you can either:

* Create a fresh deployment that doesn't use the old volumes.
* Continue to run the containers as root.

Additionally, the containers using persistent volume claims need to set the securityContext `fsGroup` to a value allowing the container can write to the PVCs.  An example of setting this value in the statefulSet workload needs to include the following fsGroup setting.

This example uses the same default groupId set by the image.  The [Ping Identity Helm Charts](https://helm.pingidentity.com) already provide this setting by default for the containers.

```yaml
spec:
  template:
    spec:
      securityContext:
        fsGroup:9999
```

### Default ports

In our older images, certain default ports (`LDAP_PORT`, `LDAPS_PORT`, `HTTPS_PORT`, and `JMX_PORT`) were set to privileged values (`389`, `636`, `443`, and `689`, respectively). The newer images don't use these values because they run as a non-privileged user. The updated default ports are `1389`, `1636`, `1443`, and `1689`.

If you need, you can maintain the old values by setting the corresponding environment variables and running the container as root.

For our PingDirectory images, port changes aren't allowed on restart. If you're using a volume from an older image you may encounter an error due to changing port values.

You must either:

* Create a fresh deployment for PingDirectory with the new images and import your data from the old deployment.
* Set the environment variables to match the original privileged values and continue to run the container as root.

## Running as root with the unprivileged-by-default images

To run as root as mentioned in the two previous examples, you must use your container orchestrator:

* For pure Docker, the `-u` flag allows specifying the user the container should use.
* For Docker Compose, you can define a `user:`.
* In Kubernetes, you can set up a security context for the container to specify the user. To run as root, a user and group ID of `0:0` should be used.
