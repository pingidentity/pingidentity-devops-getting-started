# A single solution as a standalone Docker container

## To deploy one of our solutions as a standalone Docker container:

1. Go to the `pingidentity-devops-getting-started/10-docker-standalone` directory and choose one of the available solutions, then go to the solution directory (where the `docker-compose.yaml` file for the selected solution is located). Enter:

  `./docker-run.sh <solution>`

  where <solution> is the name of one of our solutions (pingfederate, pingaccess, pingdirectory, pingdataconsole). The container will start up.

2. To stop the container, enter: `dcsstop` or `docker-compose stop`. Enter `dhelp` for a full listing of the DevOps command aliases.

  See [Using the Docker Command Line](https://docs.docker.com/engine/reference/commandline/cli/) for a complete listing of the Docker commands.

3. Another way to deploy a standalone solution is by using a server profile. For example:

  ```bash
  docker run -d --publish 1389:389 \
    --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
    --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
    pingidentity/pingdirectory
  ```

  This shell script uses the default DevOps server profile and environment settings to configure the PingDirectory container, runs the container in the background (detached mode, `-d`) and publishes PingDirectory to the default ports (`1389:389`).

  See the [PingDirectory standalone documentation](../10-docker-standalone/01-pingdirectory/README.md) for more information about running a single PingDirectory container. For our other solutions, see [Standalone documentation](../10-docker-standalone/README.md).

4. Log in to the management console for the solution:

  * PingDataConsole for PingDirectory
    Console URL: https://localhost:8443/console
    Server: pingdirectory
    User: Administrator
    Password: 2FederateM0re

  * PingFederate
    Console URL: https://localhost:9999/pingfederate/app
    User: Administrator
    Password: 2FederateM0re

  * PingAccess
    Console URL: https://localhost:9000
    User: Administrator
    Password: 2FederateM0re

  * PingDataConsole for DataGovernance
    Console URL: https://localhost:8443/console
    Server: pingdatagovernance
    User: Administrator
    Password: 2FederateM0re

  * Apache Directory Studio for PingDirectory
    LDAP Port: 1389
    LDAP BaseDN: dc=example,dc=com
    Root Username: cn=administrator
    Root Password: 2FederateM0re

5. When you no longer want to run this standalone container, you can either stop the running container, or bring the container down. Enter either:

  `docker-compose stop` or `docker-compose down`
