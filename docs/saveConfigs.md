# Save your configuration changes

To save any configuration changes you make when using the products in the stack, you need to set up a local Docker volume to persist state and data for the stack. If you don't do this, whenever you bring the stack down your configuration changes will be lost.

You'll bind mount a Docker volume location to the Docker `/opt/out` directory for the container. The location must be to a directory you've not already created. Our Docker containers use the `/opt/out` directory to store application data.

> Make sure the local directory is not already created. Docker needs to create this directory for the bind mount to `/opt/out`.

You can bind mount a Docker volume for containers in a stack or for standalone containers.

## Bind mounting for a stack

1. Add a `volumes` section under the container entry for each product in the `docker-compose.yaml` file you're using for the stack.
2. Under the `volumes` section, add a location to persist your data. For example:

   ```yaml
   pingfederate:
   .
   .
   .
   volumes:
    - /tmp/compose/pingfederate_1:/opt/out
   ```

3. In the `environment` section, comment out the `SERVER_PROFILE_PATH` setting. The container will then use your `volumes` entry to supply the product state and data, including your configuration changes.

   When the container starts, this will bind mount `/tmp/compose/pingfederate_1` to the `/opt/out` directory in the container. You're also able to view the product logs and data in the `/tmp/compose/pingfederate_1` directory.

4. Repeat this process for the remaining container entries in the stack.

## Bind mounting for a standalone container

* Add a `volume` entry to the `docker run` command:

  ```bash
  docker run \
      --name pingfederate \
      --volume <local-path>:/opt/out
      pingidentity/pingfederate:edge
  ```
