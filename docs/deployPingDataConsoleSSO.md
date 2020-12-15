# Deploy PingDataConsole with PingOne SSO enabled

You'll use Docker Compose to deploy a PingDirectory and PingDataConsole stack. PingDataConsole will have SSO enabled with PingOne.

Note: Configuring SSO with PingOne requires PingDirectory and PingDataConsole versions of at least 8.2.0.0.

## What you'll do

* Deploy the PingDirectory and PingDataConsole stack.
* Test the deployment.
* Bring down or stop the stack.

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've set up an application in PingOne representing your PingDataConsole instance. See the PingDirectory documentation ("Configuring PingOne to use SSO for the PingData Administrative Console") for details. You will need the Issuer, Client ID, and Client Secret values from PingOne.
* You've set the variable values from PingOne in your local `devops/pingidentity-devops-getting-started/11-docker-compose/13-pingdataconsole-pingone-sso/docker-compose.yml`.

## Deploy the PingDirectory and PingDataConsole stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/13-pingdataconsole-pingone-sso` directory. Enter:

   ```bash
   docker-compose up -d
   ```

2. Check that PingDirectory and PingDataConsole are healthy and running:

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

## Test the deployment

1. In a browser, go to `https://localhost:8443/console/login`

2. You should be redirected to a PingOne login page. Login with a PingOne user that corresponds to a configured Root DN. You should be successfully logged in to the console, where you can manage your PingDirectory instance.

3. When you no longer want to run this stack, you can either bring the stack down (recommended), or stop the running stack.

   To stop the running stack without removing any of the containers or associated Docker networks, enter:

   ```bash
   docker-compose stop
   ```

   To remove all of the containers and associated Docker networks, enter:

   ```bash
   docker-compose down
   ```
