# Managing configurations and deployment

We use Server Profiles to configure

     > If you remove any of the existing configurations for a solution, the solution may no longer interoperate with other solutions in the Docker stack.

## Prerequisites

  * You've already been through [Getting Started](docs/evaluate.md) to set up your environment and deploy the solutions.

## Procedures

  1. You can select to deploy either:
  
  * A standalone (single container) Ping Identity solution. See [Docker standalone](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/10-docker-standalone) for more information.
  * An orchestrated stack of our solutions using Docker Compose for lightweight orchestration. See [Docker Compose](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose) for more information. Our Docker images are preconfigured with the basic configurations needed to run and interoperate. 
  
  2. You can add your own configurations through the management consoles for the Ping Identity solutions as needed. However, your configuration changes will not be saved when you bring down or remove the Docker stack, unless you persist your data by [mounting the configuration changes to a local Docker volume](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data).
  
     
