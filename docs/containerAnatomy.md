# Anatomy of our product containers

Any configuration that is deployed with one of our product containers can be considered a "profile". A profile typically looks like a set of files. These files can be built into the image, mounted in to the image, or pulled at startup (recommended). We call these collected files a "server profile".

Because you can add profile information to our containers in a variety of ways, it's important to understand the resources and file structure used for our containers.

This is illustrated in two diagrams:

* Resources used at startup.
* How the resources work together.

## Resources used at startup

![generic-ping-container-anatomy](images/ping-container-startup-anatomy.png)

| Resource | Description |
| --- | --- |
| /opt/server | This directory always contains an untouched, uncompressed copy of the product software version. |
|/opt/in | This directory contains any server profile that you want Docker to bind mount to the container. |
| SERVER_PROFILE_URL | The URL referencing a Git clone of a server profile from a repository. The profile is cloned to `/tmp/staging` then moved to `/opt/staging`. |
| opt/staging | The directory where the locations and resources mentioned above are moved to and evaluated (variable settings) before being moved to `/opt/out`. |
| envsubst | The configuration data is passed to containers using environment variables. See [Environment substitution](profilesSubstitution.md) for information. |
| opt/out | This directory contains the final, runtime location for all files. This is the directory to persist if you want to save any configuration changes you make in a running product instance. See [Saving your configuration changes](saveConfigs.md) for more information. |

You can open a shell into a Docker container and view the container structure and resources by:

1. Entering `docker ls` and getting the container ID displayed.

2. Entering `docker exec -it <container-id> /bin/sh`.

## How the resources work together

![profile-file-layering-example](images/profile-file-layering.png)

This is an example of a PingFederate flow illustrating: 

* A common pattern where the PingFederate license is mounted as a file so that it is not stored in a repository. This mount could be a Docker bind mount, or it could be placed in the Docker image directly using a separate Dockerfile. This is also an acceptable approach for custom extensions and *.jar files.

* GitOps. Any additional profile files relevant to customizing the PingFederate configuration are pulled from a Git repository, for tracking, easy update, and maintenance. 

* In `envsubst`, any remaining configurations needed for PingFederate to run are automatically set using the standard PingFederate environment variables.

See [Customizing server profiles](profiles.md) for more information about customizing deployments with profiles.