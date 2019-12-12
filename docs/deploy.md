# Managing deployments

You can continue to deploy the full stack of solutions as you did in Getting Started, or you can deploy a single solution or a different set of solutions.

     > If you remove any of the existing configurations for a solution, the solution may no longer interoperate with other solutions in the Docker stack.

You can choose to deploy:

   * [A single solution as a standalone Docker container](#A single solution as a standalone Docker container). See [Docker standalone](../10-docker-standalone/README.md) for the available solutions.
   * [A PingFederate and PingDirectory stack using Docker Compose](#A PingFederate and PingDirectory stack using Docker Compose).
   * [A replicated pair of solutions using Docker Compose](#A replicated pair of solutions using Docker Compose). See also [Docker Compose for replicated pairs](../11-docker-compose/02-replicated-pair/README.md) for general information.
   * A solutions stack using Docker Swarm.
   * PingDirectory using Kubernetes.

## Prerequisites

  * You've already been through [Getting Started](../evaluate.md) to set up your environment and run a test deployment of the solutions.

## Procedures

### To deploy one of our solutions as a standalone Docker container<a id="A single solution as a standalone Docker container"/>:

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

### To deploy a PingFederate and PingDirectory stack using Docker Compose<a id="A PingFederate and PingDirectory stack using Docker Compose"/>:

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/01-simple-stack` directory (where the `docker-compose.yaml` file for the PingFederate and PingDirectory stack is located). To start the stack, enter:

  `docker-compose up -d`

2. Check that the solution pair is healthy and running:

  `docker-compose ps`

  See [Docker Compose](../11-docker-compose) for help using Docker Compose.

3. Log in to the management console for the solution:

* PingDataConsole for PingDirectory
      Console URL: https://localhost:8443/console
      Server: pingdirectory
      User: Administrator
      Password: 2FederateM0re

* PingFederate
      Console URL: https://localhost:9999/pingfederate/app
      User: Administrator
      Password: 2FederateM0re

4. When you no longer want to run this PingFederate and PingDirectory stack, you can either stop the running stack, or bring the stack down. Enter either:

  `docker-compose stop` or `docker-compose down`

### To deploy a replicated pair of solutions using Docker Compose<a id="A replicated pair of solutions using Docker Compose"/>:

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/02-replicated-pair` directory (where the `docker-compose.yaml` file for a replicated pair of solutions is located). Enter:

  `docker-compose up --detach --scale <solution>=2`

  where <solution> is one of the supported solutions for replication (pingfederate, pingdirectory, pingaccess).

2. Check that the solution pair is healthy and running:

  `docker-compose ps`

  See [Docker Compose](../11-docker-compose) for help using Docker Compose.

3. Verify that data is replicating between the pair by adding a description entry for the first container. Enter:

  ```text
  docker container exec -it 02-replicated-pair_pingdirectory_1 /opt/out/instance/bin/ldapmodify
  dn: uid=user.0,ou=people,dc=example,dc=com
  changetype: modify
  replace: description
  description: Made this change on the first container.

  <Ctrl-D>
  ```

  > The blank line followed by the `<Ctrl-D>` is important. It's how entries are separated in the LDAP Data Interchange Format (LDIF).

  Check that the second container in the pair now has a matching entry for the description. Enter:

  ```text
  docker container exec -it 02-replicated-pair_pingdirectory_2 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,dc=example,dc=com -s base '(&)' description
  ```
  The result should show the description that you specified for the first container, similar to this:

  ```text
  # dn: uid=user.0,ou=people,dc=example,dc=com
  # description: Made this change on the first container.
  ```

4. When you no longer want to run this replicated pair stack, you can either stop the running stack, or bring the stack down. Enter either:

  `docker-compose stop` or `docker-compose down`

### To deploy a set of solutions using Docker Swarm:


### To deploy PingDirectory using Kubernetes:
