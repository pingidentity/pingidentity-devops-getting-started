
# Using your DevOps user and key

When starting one of our containers, the container will attempt to find the DevOps registration information in either the DevOps property file located in `~/.pingidentity/devops` or in environment variables assigned in the `docker run` command for standalone containers or in the YAML file for a stack.

## Display your DevOps information

To display your current DevOps environment information, run the DevOps command `denv` .

## For standalone containers

When using the `docker run` command to start a container, you can assign the `--env-file` argument to the file containing your DevOps registration information. For example:

    ```text
    docker run \
            --name pingdirectory \
            --publish 1389:389 \
            --publish 8443:443 \
            --detach \
            --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
            --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
            --env-file ~/.pingidentity/devops \
            pingidentity/pingdirectory
    ```

## For stacks

When you're going to deploy a stack, you can use either of these methods to assign the location of the file containing your DevOps registration information:

* The `env_file` configuration option. 
* The DevOps environment variables.

### The `env_file` configuration option

Add the `env_file` configuration option to the YAML file for the stack. The `env_file` configuration option passes environment variable definitions into the container.

> This format isn't supported by Docker Swarm.

For example:

    ```text
    ...
    pingdirectory:
        image: pingidentity/pingdirectory
        env_file:
        - ${HOME}/.pingidentity/devops
        environment:
        - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
        - SERVER_PROFILE_PATH=getting-started/pingdirectory
    ...
    ```

### The DevOps environment variables

Add the `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY` DevOps environment variables to the YAML file for the stack.

> Docker Swarm requires this format.

For example:

  ```text
  ...
    pingdirectory:
      image: pingidentity/pingdirectory
      environment:
        - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
        - SERVER_PROFILE_PATH=getting-started/pingdirectory
        - PING_IDENTITY_DEVOPS_USER=jsmith@example.com
        - PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
  ...
  ```
