# Managing configurations and deployment

We use Server Profiles to supply configuration and environment settings, as well as data, to the DevOps images. We also externalize environment settings through additional runtime Hooks (environment variables). You can continue to deploy the full stack of solutions as you did in Getting Started, or you can choose to deploy a single solution or a different set of solutions. You can also try modifying or adding Server Profile settings for the deployment. 

     > If you remove any of the existing configurations for a solution, the solution may no longer interoperate with other solutions in the Docker stack.

What you can choose to do:

   * Deploy a solution as a standalone (single solution) Docker container.
   * Employ lightweight orchestration to deploy a set of solutions using Docker Compose.
   * Employ enterprise-level orchestration to deploy a set of solutions using Docker Swarm.
   * Employ enterprise-level orchestration using Kubernetes to deploy PingDirectory.

## Prerequisites

  * You've already been through [Getting Started](docs/evaluate.md) to set up your environment and run a test deployment of the solutions.

## Procedures

  1. Choose to deploy either:
  
  * One of our solutions as a standalone (single solution) Docker container. See [Docker standalone](../tree/master/10-docker-standalone) for more information.
  * A set of our solutions as an orchestrated stack using Docker Compose, much as you did in Getting Started. This time, however, choose either to deploy the full stack again, or deploy a different set of solutions. See [Docker Compose](../tree/master/11-docker-compose) for more information.
  
  2. You can add your own configurations through the management consoles for the Ping Identity solutions as needed. However, your configuration changes will not be saved when you bring down or remove the Docker stack, unless you persist your data by [mounting the configuration changes to a local Docker volume](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data).
  
     
