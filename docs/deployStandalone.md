# Deploy standalone containers

Our single container examples are located in the your local `${HOME}/projects/devops/pingidentity-devops-getting-started/10-docker-standalone` directory.

You can use the list of [getting-started server-profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started)

## What you'll do

  * Deploy one of our containers.
  * Log in to the management console.
  * Stop the container.

## Prerequisites

  * You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.


## Deploy a single container

1. Use the `docker run` command to deploy a container. For example:

    ```shell
    docker run -d --publish 9876:9999 \
      --name pingfederate \
      --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
      --env SERVER_PROFILE_PATH=getting-started/pingfederate \
      --detach \
      --env-file ~/.pingidentity/devops \
      pingidentity/pingfederate:edge
    ```

2. Log in to the management console for the product:

  * Ping Data Console for PingDirectory
    - Console URL: `https://localhost:8443/console`
    - Server: pingdirectory
    - User: Administrator
    - Password: 2FederateM0re

  * PingFederate
    - Console URL: `https://localhost:9999/pingfederate/app`
    - User: Administrator
    - Password: 2FederateM0re

  * PingAccess
    - Console URL: `https://localhost:9000`
    - User: Administrator
    - Password: 2FederateM0re

  * Ping Data Console for DataGovernance
    - Console URL: `https://localhost:8443/console`
    - Server: pingdatagovernance
    - User: Administrator
    - Password: 2FederateM0re

  * PingCentral
    - Console URL: `https://localhost:9022`
    - User: Administrator
    - Password: 2Federate

  * Apache Directory Studio for PingDirectory
    - LDAP Port: 1389
    - LDAP BaseDN: dc=example,dc=com
    - Root Username: cn=administrator
    - Root Password: 2FederateM0re

3. To stop the container, use any of:

   * The `dcstop <container_name>` command alias or `docker container stop <container_name>`.

   * Stop all containers: `dsa` command alias.
   * Remove all containers: `dra` command alias.
