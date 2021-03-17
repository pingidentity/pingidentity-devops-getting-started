# Migrating from privileged images to unprivileged-by-default images
In the 2103 release, our product images were updated to use an unprivleged user by default. Prior to this release, images ran as root by default. This page describes some of the potential issues you may encounter if you intend to migrate to these newer images.

## Persistent volumes
Persistent volumes created attached to our old containers would have files owned by the root user. If our non-privileged users attempt to use these existing volumes, there may be file permission errors. To avoid this, you may need to create a fresh deployment that does not use the old volumes, or you can run the new images as root.

## Default ports
In our old images, certain default ports (`LDAP_PORT`, `LDAPS_PORT`, `HTTPS_PORT`, and `JMX_PORT`) were set to privileged values (`389`, `636`, `443`, and `689`, respectively). The newer images do not use these values since they are run as a non-privileged users. The updated ports are `1389`, `1636`, `1443`, and `1689`. If necessary you can maintain the old values by setting the corresponding environment variables and running the container as root.

For our PingDirectory images specifically, port changes are not allowed on restart. If you are using a volume from an older image you may encounter an error due to changing port values. You will need to either create a fresh deployment for PingDirectory with the new images and import your data from the old deployment, or set the environment variables to match the original privileged values and run the container as root.

## Running as root with the new images
In order to run as root as mentioned in the two above examples, you will need to use your container orchestrator. For pure Docker, the `-u` flag allows specifying a user and group. Similarly, for Docker Compose a `user:` can be defined. In Kubernetes, you can set up a security context for the container.
