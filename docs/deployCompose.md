# Deploy a simple stack with PingFederate and PingDirectory

You'll use Docker Compose to deploy a PingFederate and PingDirectory stack.

## What you'll do

  * Deploy the stack.
  * Log in to the management consoles.
  * Bring down or stop the stack.

## Prerequisites

  * You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## Deploy the PingFederate and PingDirectory stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/01-simple-stack` directory. Enter:

  `docker-compose up -d`

2. At intervals, check to see when the containers are healthy and running:

  `docker-compose ps`

  > Enter `dhelp` for a listing of the DevOps command aliases. See the [Docker Compose command line reference](https://docs.docker.com/compose/reference/overview/) for the Docker Compose commands.

## Log in to the management consoles

The log in information for the consoles is:

   * PingDataConsole for PingDirectory
    - Console URL: https://localhost:8443/console
    - Server: pingdirectory
    - User: Administrator
    - Password: 2FederateM0re

   * PingFederate
    - Console URL: https://localhost:9999/pingfederate/app
    - User: Administrator
    - Password: 2FederateM0re

When you no longer want to run this full stack evaluation, you can either stop the running stack, or bring the stack down.

Entering:

 `docker-compose stop`

will stop the running stack without removing any of the containers or associated Docker networks.

Entering:

 `docker-compose down`

 will remove all of the containers and associated Docker networks.
