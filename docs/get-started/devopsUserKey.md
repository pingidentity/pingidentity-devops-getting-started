---
title: Using Your Devops User and Key
---
# Using Your Devops User and Key

When starting one of our containers, the container attempts to find the DevOps registration information first in the DevOps property file located in `~/.pingidentity/devops`. This property file was created when you set up the DevOps environment (see [Get Started](../get-started/getStarted.md). If the DevOps registration information isn't found there, the container checks for environment variables assigned in the `docker run` command for standalone containers or in the YAML file for a stack.

## Display Your Devops Information

To display your current DevOps environment information, run the `pingctl info` command.


## For Kubernetes and Helm

Our Kubernetes and Helm examples by default will look for a Kubernetes secret named `devops-secret`.

You must create a Kubernetes secret that contains the environment variables `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY`.

1. If you don't already know your DevOps credentials, display these using the following DevOps command.

    ```sh
    pingctl info
    ```

2. Generate the Kubernetes secret from your DevOps credentials:

   Choose from:

   * Use the `pingctl` utility.

    ```sh
    pingctl k8s generate devops-secret | kubectl apply -f -
    ```

   * Generate the secret manually.

   ```sh
    kubectl create secret generic devops-secret \
      --from-literal=PING_IDENTITY_DEVOPS_USER="${PING_IDENTITY_DEVOPS_USER}" \
      --from-literal=PING_IDENTITY_DEVOPS_KEY="${PING_IDENTITY_DEVOPS_KEY}"
   ```


## For Standalone Docker Containers

When using the `docker run` command to start a container, you can assign the `--env-file` argument to the file containing your DevOps registration information, as in the following example.

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

When deploying a stack, you can use either of the following methods to assign the location of the file containing your DevOps registration information:

* The `env_file` configuration option
* The DevOps environment variables

### Pass as Env File

Add the `env_file` configuration option to the YAML file for the stack. The `env_file` configuration option passes environment variable definitions into the container, as in the following example.

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

Add the `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY` DevOps environment variables to the YAML file for the stack, as in the following example.

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
