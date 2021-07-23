---
title: Deploying PingDataConsole with PingOne SSO enabled
---
# Deploying PingDataConsole with PingOne SSO enabled

Use Docker Compose to deploy a PingDirectory and PingDataConsole stack. PingDataConsole will have single sign-on (SSO) enabled with PingOne.

Note: Configuring SSO with PingOne requires PingDirectory and PingDataConsole 8.2.0.0 or later.

## Before you begin

You must:

* Complete [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Set up an application in PingOne representing your PingDataConsole instance, with a redirect URL of https://localhost:8443/console/oidc/cb. See the PingDirectory documentation ("Configuring PingOne to use SSO for the PingData Administrative Console") for details. You will need the Issuer, Client ID, and Client Secret values from PingOne.
* Create a user in PingOne corresponding to a root user DN in PingDirectory. This example expects a user named Jane Smith, with username jsmith. This user will need to be given a password.
* Set the variable values from PingOne in your local `devops/pingidentity-devops-getting-started/11-docker-compose/13-pingdataconsole-pingone-sso/docker-compose.yml`.

## About this task

You will:

* Deploy the PingDirectory and PingDataConsole stack.
* Test the deployment.
* Bring down or stop the stack.

## Deploying the PingDirectory and PingDataConsole stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/13-pingdataconsole-pingone-sso` directory and enter:

      ```sh
      docker-compose up -d
      ```

1. To check that PingDirectory and PingDataConsole are healthy and running, enter:

      ```bash
      docker-compose ps
      ```

      * You can also display the startup logs:

      ```sh
      docker-compose logs -f
      ```

      *  To see the logs for a particular product container at any point, enter:

      ```sh
      docker-compose logs <product-container-name>
      ```

## Testing the deployment

1. In a browser, go to `https://localhost:8443/console/login`

      You are redirected to a PingOne sign-on page.

1. Sign on with a PingOne user that corresponds to a configured root user distinguished name (DN), in this example, jsmith.

      You can generate an initial password for the user in PingOne. You should be successfully signed on to the console, where you can manage your PingDirectory instance.

## Cleaning Up

When you no longer want to run this stack, bring the stack down.

* To remove all of the containers and associated Docker networks, enter:

      ```sh
      docker-compose down
      ```

* To stop the running stack without removing any of the containers or associated Docker networks, enter:

      ```sh
      docker-compose stop
      ```

* To remove attached Docker volumes, enter:

      ```sh
      docker volume prune
      ```
