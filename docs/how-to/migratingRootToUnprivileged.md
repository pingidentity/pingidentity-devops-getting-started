# Migrating from privileged images to unprivileged-by-default images
In the 2103 release (released April 1, 2021), our product images were updated to run with an unprivileged user by default. Prior to this release, images ran as root by default. This page describes some of the potential issues you may encounter when migrating to these newer images.

## Persistent volumes
Persistent volumes created with our older containers will have files owned by the root user. When the default non-privileged user attempts to use these existing volumes, there may be file permission errors. To avoid this, you can create a fresh deployment that does not use the old volumes, or you can continue to run the containers as root.

## Default ports
In our older images, certain default ports (`LDAP_PORT`, `LDAPS_PORT`, `HTTPS_PORT`, and `JMX_PORT`) were set to privileged values (`389`, `636`, `443`, and `689`, respectively). The newer images do not use these values since they run as a non-privileged user. The updated default ports are `1389`, `1636`, `1443`, and `1689`. If necessary you can maintain the old values by setting the corresponding environment variables and running the container as root.

For our PingDirectory images, port changes are not allowed on restart. If you are using a volume from an older image you may encounter an error due to changing port values. You will need to either create a fresh deployment for PingDirectory with the new images and import your data from the old deployment, or you can set the environment variables to match the original privileged values and continue to run the container as root.

## Running as root with the unprivileged-by-default images
In order to run as root as mentioned in the two above examples, you will need to use your container orchestrator. For pure Docker, the `-u` flag allows specifying the user the container should use. Similarly, for Docker Compose a `user:` can be defined. In Kubernetes, you can set up a security context for the container in order to specify the user. To run as root, a user and group id of `0:0` should be used.
