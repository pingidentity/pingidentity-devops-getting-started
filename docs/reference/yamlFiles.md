---
title:  Customizing YAML files
---
# Customizing YAML files

Docker Compose uses YAML files to configure a stack's containers on startup. You can customize our YAML files or use them as the basis for creating your own. For more information, see the Docker [Compose File Reference](https://docs.docker.com/compose/compose-file/).

To customize our YAML files, you can:

* Add or change environment variables to use different server profiles.
* Add references to a file or files containing environment variables to pass to the container on startup.
* Change the `wait-for` times used to control the startup sequence of containers.
* Change the port mappings for a container.
* Change the release tag used for the Docker images (all product containers in the stack must use the same release tag). See [Using Release Tags](../docker-images/releaseTags.md) for more information.

You will find the YAML files for deploying individual Ping product containers in the `${HOME}/projects/devops/pingidentity-devops-getting-started/11-docker-compose` directory.

## YAML file format

This format is used for the YAML files:

```yaml
version: "3.9"

services:
    <ping-product>:
      image: pingidentity/<ping-product>:${PING_IDENTITY_DEVOPS_TAG}
      command: wait-for <another-ping-product>:<startup-port> -t <time-to-wait> -- entrypoint.sh start-server
      environment:
        - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
        - SERVER_PROFILE_PATH=baseline/<ping-product>
        - PING_IDENTITY_ACCEPT_EULA=YES
      env_file:
        - ~/.pingidentity/config
      #volumes:
        # - ${HOME}/projects/devops/volumes/full-stack.<ping-product>:/opt/out
        # - ${HOME}/projects/devops/pingidentity-server-profiles/baseline/<ping-product>:/opt/in
      ports:
        - <host-port>:<container-port>
        - <host-port>:<container-port>
      networks:
        - pingnet-dmz

networks:
    pingnet-internal:
    pingnet-dmz:
```

| Entry | Description                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| :--- |:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `version` | The Docker Compose file specification version used.                                                                                                                                                                                                                                                                                                                                                                                                              |
| `<ping-product>` | The name of the Ping Identity product container.                                                                                                                                                                                                                                                                                                                                                                                              |
| `image` | The build image of the product used for the container and the build tag to use (defaults to value assigned to `PING_IDENTITY_DEVOPS_TAG` in the `~/.pingidentity/config` file.                                                                                                                                                                                                                                                                |
| `command` | We use the `wait-for` script to control the startup order, where `<startup-port>` is the port to check for whether `<another-ping-product>` container has started. The `<time-to-wait>` argument is the number of seconds to wait before executing the `entrypoint.sh` script with the `start-server` command. If you find a container is timing out while waiting for another container to start, try increasing the `<time-to-wait>` value. |
| `environment` | The environment variables being set. See [Customizing Server Profiles](../how-to/profiles.md) for more information. The `PING_IDENTITY_ACCEPT_EULA` environment variable is set to "YES" when you complete the DevOps registration. This variable assignment appears here by default but could also be in your `~/.pingidentity/config` file.                                                                                                 |
| `env_file` | A file or files containing environment variable settings. The DevOps environment settings are stored in your `~/.pingidentity/config` file. You also can specify additional files containing environment settings. For more information, see [Customizing Server Profiles](../how-to/profiles.md).                                                                                                                                            |
| `volumes` | Commented out by default. The location bind mounted to the  `/opt/out` volume is used to persist product container state and data. The location bind mounted to the `/opt/in` volume is used to supply server profile information to the container on startup. For more information, see *Modify a server profile using local directories* in [Customizing Server Profiles](../how-to/profiles.md).                                           |
|`ports` | The port mappings between the host and the product container. For more information, see the *Ports* topic in the Docker [Compose File Reference](https://docs.docker.com/compose/compose-file/).                                                                                                                                                                                                                                              |
| `networks` | One or more of the networks listed under the top-level `networks` key that the product container can use for Docker network communications.                                                                                                                                                                                                                                                                                                   |
| top level `networks` | The Docker networks available for assignment to the containers in the stack. Our stacks are built to use an internal Docker network for communications between product containers (`pingnet-internal`) and an external-facing DMZ for external network communications (`pingnet-dmz`).                                                                                                                                                        |
