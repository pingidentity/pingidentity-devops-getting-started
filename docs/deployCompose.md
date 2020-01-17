# Deploy a simple stack with PingFederate and PingDirectory

You'll use Docker Compose to deploy a PingFederate and PingDirectory stack. The YAML file is located in the [Docker Compose](../11-docker-compose/01-simple-stack) directory.

## What you'll do

  * Deploy the stack.
  * Log in to the management consoles.
  * Bring down or stop the stack.

## Prerequisites

  * You've already been through [Get started](evaluate.md) to set up your DevOps environment and run a test deployment of the products.

## To deploy a PingFederate and PingDirectory stack using Docker Compose:

1. In the [Docker Compose](../11-docker-compose/01-simple-stack) directory, enter:

  `docker-compose up -d`

2. At intervals, check to see when the containers are healthy and running:

  `docker-compose ps`

  > Enter `dhelp` for a listing of the DevOps command aliases. See the [Docker Compose command line reference](https://docs.docker.com/compose/reference/overview/) for the Docker Compose commands.

3. Log in to the management consoles for the products:

   * PingDataConsole for PingDirectory
    - Console URL: https://localhost:8443/console
    - Server: pingdirectory
    - User: Administrator
    - Password: 2FederateM0re

   * PingFederate
    - Console URL: https://localhost:9999/pingfederate/app
    - User: Administrator
    - Password: 2FederateM0re

4. When you no longer want to run this full stack evaluation, you can either stop the running stack, or bring the stack down.

  Entering:

   `docker-compose stop`

  will stop the running stack without removing any of the containers or associated Docker networks.

  Entering:

   `docker-compose down`

   will remove all of the containers and associated Docker networks.
