---
title: Saving Your Configuration Changes
---
# Saving your configuration changes

To save any configuration changes you make when using the products in the stack, you must set up a local Docker volume to persist state and data for the stack. If you don't do this, whenever you bring the stack down, your configuration changes will be lost.

Mount a Docker volume location to the Docker `/opt/out` directory for the container. The location must be to a directory you haven't already created. Our Docker containers use the `/opt/out` directory to store application data.

!!! warning "Mounting to /opt/out"
    Make sure the local directory isn't already created. Docker needs to create this directory for the mount to `/opt/out`.

You can mount a Docker volume for containers in a stack or for standalone containers.

## Bind mounting for a stack

1. Add a `volumes` section under the container entry for each product in the `docker-compose.yaml` file you're using for the stack.
1. Under the `volumes` section, add a location to persist your data. For example:

      ```yaml
      pingfederate:
      .
      .
      .
      volumes:
      - /tmp/compose/pingfederate_1:/opt/out
      ```

1. In the `environment` section, comment out the `SERVER_PROFILE_PATH` setting.

    The container then uses your `volumes` entry to supply the product state and data, including your configuration changes.

    When the container starts, this mounts `/tmp/compose/pingfederate_1` to the `/opt/out` directory in the container. You can also view the product logs and data in the `/tmp/compose/pingfederate_1` directory.

1. Repeat this process for the remaining container entries in the stack.

## Bind mounting for a standalone container

Add a `volume` entry to the `docker run` command:

   ```sh
   docker run \
      --name pingfederate \
      --volume <local-path>:/opt/out \
   pingidentity/pingfederate:edge
   ```

## Getting started with Docker Compose mounts

Within many of the docker-compose.yaml files in the Getting-Started [repository](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose), volume mounts to `opt/out` have been included to persist your configuration across container restarts.

* To view the list of persisted volumes, enter:

    ```sh
    docker volume list
    ```

* To view the contents of the /opt/out/ volume when the container is running, enter:

    ```sh
    docker container exec -it <container id> sh
    cd out
    ```

* To view the contents of the /opt/out/ volume when the container is stopped, enter:

    ```sh
    docker run --rm -i -v=<volume name>:/opt/out alpine ls
    ```

* To remove a volume, enter:

    ```sh
    docker volume rm <volume name>
    ```

* To copy files from the container to your local filesystem, enter:

    ```sh
    docker cp \
       <container id>:<source path> \
       <destination path>
    eg.
    docker cp \
       b867054293a1:/opt/out \
       ~/pingfederate/
    ```

* To copy files from your local filesystem to the container, enter:

    ```sh
    docker cp \
       <source path> \
       <container id>:<destination path>
    eg.
    docker cp \
       myconnector.jar \
       bb867054293a186:/opt/out/instance/server/default/deploy/
    ```
