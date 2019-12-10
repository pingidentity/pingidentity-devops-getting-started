# Managing configurations and deployment

We use Server Profiles to supply configuration and environment settings, as well as data, to the DevOps images. We also externalize environment settings through additional runtime Hooks (environment variables). You can continue to deploy the full stack of solutions as you did in Getting Started, or you can choose to deploy a single solution or a different set of solutions. You can also try modifying or adding Server Profile settings for the deployment. 

     > If you remove any of the existing configurations for a solution, the solution may no longer interoperate with other solutions in the Docker stack.

What you can choose to do:

   * Deploy a solution as a standalone (single solution) Docker container. See [Docker standalone](../tree/master/10-docker-standalone) for more information.
   * Employ lightweight orchestration to deploy a set of solutions using Docker Compose.
   * Employ enterprise-level orchestration using Docker Swarm to deploy a set of solutions.
   * Employ enterprise-level orchestration using Kubernetes to deploy PingDirectory.

## Prerequisites

  * You've already been through [Getting Started](docs/evaluate.md) to set up your environment and run a test deployment of the solutions.

## Procedures

To deploy one of our solutions as a standalone (single solution) Docker container:

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
  
  See 
  
To configure the deployment of a standalone Docker container:

  1. 

  
  * A set of our solutions as an orchestrated stack using Docker Compose, much as you did in Getting Started. This time, however, choose either to deploy the full stack again, or deploy a different set of solutions. See [Docker Compose](../tree/master/11-docker-compose) for more information.
  
  2. You can add your own configurations through the management consoles for the Ping Identity solutions as needed. However, your configuration changes will not be saved when you bring down or remove the Docker stack, unless you persist your data by [mounting the configuration changes to a local Docker volume](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data).
  
     
