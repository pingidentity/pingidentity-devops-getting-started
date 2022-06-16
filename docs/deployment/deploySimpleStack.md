---
title: Stack with PingFederate and PingDirectory
---
# Stack with PingFederate and PingDirectory

Use Docker compose to deploy a PingFederate and PingDirectory stack.

## Before you begin

You must complete [Get Started](../get-started/introduction.md) to set up your DevOps environment and run a test deployment of the products.

## About this task

You will:

* Deploy the stack.
* Sign on to the management consoles.
* Bring down or stop the stack.

## Deploying the stack

1. Go to your local `pingidentity-devops-getting-started/11-docker-compose/01-simple-stack` directory and enter:

      ```sh
      docker-compose up -d
      ```

1. To check that the containers are healthy and running, enter:

      ```sh
      docker-compose ps
      ```

      * To display the startup logs, enter:

         ```sh
         docker-compose logs -f
         ```

      * To see the logs for a particular product container at any point, enter:

         ```sh
         docker-compose logs <product-container-name>
         ```

1. Sign on to the management consoles:

      | Product | Connection Details |
    | --- | --- |
    | [PingFederate](https://localhost:9999/pingfederate/app) | <ul> <li>URL: [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDirectory](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingdirectory</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |

## Cleaning Up

When you no longer want to run this stack, you can either stop the running stack or bring the stack down.

* To stop the running stack without removing any of the containers or associated Docker networks, enter:

    ```sh
    docker-compose stop
    ```

* To remove all of the containers and associated Docker networks, enter:

    ```sh
    docker-compose down
    ```

* To remove attached Docker volumes, enter:

    ```sh
    docker volume prune
    ```
