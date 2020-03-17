# Deploy a simple stack with PingFederate and PingDirectory

You'll use Docker Compose to deploy a PingFederate and PingDirectory stack.

## What you'll do

* Deploy the stack.
* Log in to the management consoles.
* Bring down or stop the stack.

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## Deploy the PingFederate and PingDirectory stack

1. Go to your local `pingidentity-devops-getting-started/11-docker-compose/01-simple-stack` directory. Enter:

   ```bash
   docker-compose up -d
   ```

2. Check that the containers are healthy and running:

   ```bash
   docker-compose ps
   ```

   You can also display the startup logs:

   ```bash
   docker-compose logs -f
   ```

   To see the logs for a particular product container at any point, enter:

   ```bash
   docker-compose logs <product-container-name>
   ```

3. Log in to the management consoles:

   * Ping Data Console for PingDirectory
     - Console URL: `https://localhost:8443/console`
     - Server: pingdirectory
     - User: Administrator
     - Password: 2FederateM0re

   * PingFederate
     - Console URL: `https://localhost:9999/pingfederate/app`
     - User: Administrator
     - Password: 2FederateM0re

4. When you no longer want to run this stack, you can either stop the running stack, or bring the stack down.

   To stop the running stack without removing any of the containers or associated Docker networks, enter:

   ```bash
   docker-compose stop
   ```

   To remove all of the containers and associated Docker networks, enter:

   ```bash
   docker-compose down
   ```