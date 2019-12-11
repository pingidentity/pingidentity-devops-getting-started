# Managing deployments

You can continue to deploy the full stack of solutions as you did in Getting Started, or you can deploy a single solution or a different set of solutions.

     > If you remove any of the existing configurations for a solution, the solution may no longer interoperate with other solutions in the Docker stack.

You can choose to deploy:

   * A single solution as a standalone Docker container. See [Docker standalone](../10-docker-standalone/README.md) for the available solutions.
   * A replicated pair of solutions using Docker Compose. See [Docker Compose for replicated pairs](../11-docker-compose/02-replicated-pair/README.md) for general information.
   * A set of different solutions using Docker Compose. See [Docker Compose](../11-docker-compose/README.md) for the example Docker stacks.
   * A set of solutions using Docker Swarm.
   * PingDirectory using Kubernetes.

## Prerequisites

  * You've already been through [Getting Started](docs/evaluate.md) to set up your environment and run a test deployment of the solutions.

## Procedures

To deploy one of our solutions as a standalone Docker container:

  1. Go to the `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

    `./docker-run.sh <solution>`

   where <solution> is the name of one of our solutions (pingfederate, pingaccess, pingdirectory, pingdataconsole). The container will start up.

  2. To stop the container, enter: `dcsstop`. Enter `dhelp` for a listing of the DevOps command aliases.

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

To deploy a replicated pair of solutions using Docker Compose:

  1. Go to
  2.
 See [Docker Compose](../11-docker-compose) for more information.

 To deploy a set of different solutions using Docker Compose:


To deploy a set of solutions using Docker Swarm:


To deploy PingDirectory using Kubernetes:
