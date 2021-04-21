---
title: Using Your Devops User and Key
---
# Using Your Devops User and Key

When starting one of our containers, the container will attempt to find the DevOps registration information first in the DevOps property file located in `~/.pingidentity/devops`. This property file was created when you set up the DevOps environment (see [Get Started](../get-started/getStarted.md). If the DevOps registration information isn't found there, the container will check for environment variables assigned in the `docker run` command for standalone containers or in the YAML file for a stack.

## Display Your Devops Information

To display your current DevOps environment information, run the DevOps command:

  `ping-devops info`

## For Standalone Containers

When using the `docker run` command to start a container, you can assign the `--env-file` argument to the file containing your DevOps registration information. For example:

```bash
docker run \
  --name pingdirectory \
  --publish 1389:1389 \
  --publish 8443:1443 \
  --detach \
  --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
  --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
  --env-file ~/.pingidentity/devops \
  pingidentity/pingdirectory
```

## For Stacks

When you're going to deploy a stack, you can use either of these methods to assign the location of the file containing your DevOps registration information:

* The `env_file` configuration option.
* The DevOps environment variables.

### Pass as Env File

Add the `env_file` configuration option to the YAML file for the stack. The `env_file` configuration option passes environment variable definitions into the container.

For example:

```sh
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

### Pass as Env Variables

Add the `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY` DevOps environment variables to the YAML file for the stack.

For example:

```sh
...
  pingdirectory:
    image: pingidentity/pingdirectory
    environment:
      - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_PATH=getting-started/pingdirectory
      - PING_IDENTITY_ACCEPT_EULA=YES
      - PING_IDENTITY_DEVOPS_USER=jsmith@example.com
      - PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
...
```

## For Kubernetes

Our Kubernetes examples default to look for a Kubernetes secret named `devops-secret`.

You need to create a Kubernetes secret that contains the environment variables `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY`.

1. If you don't already know your DevOps credentials, display these using the DevOps command:

    ```sh
    ping-devops info
    ```

2. Generate the Kubernetes secret from your DevOps credentials using either the `ping-devops` utility, or manually:

    ```sh
    ping-devops generate devops-secret | kubectl apply -f -
    ```

    Manually:

    ```sh
    kubectl create secret generic devops-secret \
      --from-literal=PING_IDENTITY_DEVOPS_USER="${PING_IDENTITY_DEVOPS_USER}" \
      --from-literal=PING_IDENTITY_DEVOPS_KEY="${PING_IDENTITY_DEVOPS_KEY}"
    ```
