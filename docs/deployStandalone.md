# Deploy a single Docker container

Our single container examples are located in the [Docker standalone](../10-docker-standalone) directory.

## What you'll do

  * Deploy one of our containers.
  * Log in to the management console.
  * Stop the container.

## Prerequisites

  * You've already been through [Get started](evaluate.md) to set up your DevOps environment and run a test deployment of the products.


## Deploy a single container

1. Select one of the available products in the [Docker standalone](../10-docker-standalone) directory. You can then use either of these methods to deploy the container:

  * Use the supplied `docker-run` script [Docker standalone](../10-docker-standalone) directory.

    > See the [Docker standalone README](../10-docker-standalone/README.md) file for descriptions of the supplied standalone scripts.

    In the [Docker standalone](../10-docker-standalone) directory, enter:

      ```text
      ./docker-run.sh <product-name>
      ```

  * Use a server profile.

    For example:

      ```bash
      docker run -d --publish 1389:389 \
        --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
        --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
        pingidentity/pingdirectory
      ```

    This shell script uses the default DevOps server profile and environment settings to configure the PingDirectory container, runs the container in the background (detached mode, `-d`) and publishes PingDirectory to the ports `1389:389`.

2. Log in to the management console for the product:

  * PingDataConsole for PingDirectory
    - Console URL: https://localhost:8443/console
    - Server: pingdirectory
    - User: Administrator
    - Password: 2FederateM0re

  * PingFederate
    - Console URL: https://localhost:9999/pingfederate/app
    - User: Administrator
    - Password: 2FederateM0re

  * PingAccess
    - Console URL: https://localhost:9000
    - User: Administrator
    - Password: 2FederateM0re

  * PingDataConsole for DataGovernance
    - Console URL: https://localhost:8443/console
    - Server: pingdatagovernance
    - User: Administrator
    - Password: 2FederateM0re

  * Apache Directory Studio for PingDirectory
    - LDAP Port: 1389
    - LDAP BaseDN: dc=example,dc=com
    - Root Username: cn=administrator
    - Root Password: 2FederateM0re

3. To stop the container, use any of:

   * The `dcstop` command alias or `docker container stop`.

    > Enter `dhelp` for a listing of the DevOps command aliases. See the [Docker container command line reference](https://docs.docker.com/engine/reference/commandline/container/) for the Docker container commands.

   * The supplied `docker-stop` script located in the [Docker standalone](../10-docker-standalone) directory.

    In the [Docker standalone](../10-docker-standalone) directory, enter:

     ```text
     ./docker-run.sh <product-name>
     ```
