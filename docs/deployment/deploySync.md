---
title: Deploying PingDirectory and PingDataSync
---
# Deploying PingDirectory and PingDataSync

Use Docker compose to deploy a PingDirectory and PingDataSync stack. PingDataSync will synchronize data from a source tree on a PingDirectory instance to a destination tree on the same PingDirectory instance. The entries from `ou=source,o=sync` to `ou=destination,o=sync` will be synchronized every second.

## Before you begin

You must complete [Get started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## About this task

You will:

* Deploy the PingDirectory and PingDataSync stack.
* Test the deployment.
* Bring down or stop the stack.

## Deploying the stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/04-simple-sync` directory and enter:

      ```sh
      docker-compose up -d
      ```

1. To check that PingDirectory and PingDataSync are healthy and running, enter:

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

## Testing the deployment

The stack syncs entries from `ou=source,o=sync` to `ou=destination,o=sync` every second.

1. In one terminal window, tail the logs from the PingDataSync server:

      ```sh
      docker logs 04-simple-sync_pingdatasync_1 -f
      ```

1. In a second window, make a change to the `ou=source,o=sync` tree:

      ```text
      docker container exec -it 04-simple-sync_pingdirectory_1 \
      /opt/out/instance/bin/ldapmodify
      dn: uid=user.0,ou=people,ou=source,o=sync
      changetype: modify
      replace: description
      description: Change to source user.0

      <Ctrl-D>
      ```

   You'll see messages in the PingDataSync log showing `ADD/MODIFY` of the user sync'd to the `ou=destination,o=sync` tree.

1. To verify the messages in the PingDataSync log, enter:

      ```text
      docker container exec -it \
         04-simple-sync_pingdirectory_1 \
         /opt/out/instance/bin/ldapsearch \
         -b uid=user.0,ou=people,ou=destination,o=sync \
         -s base '(&)' description
      ```

      Entries similar to the following are returned:

      ```text
      # dn: uid=user.0,ou=People,ou=destination,o=sync
      # description: Change to source user.0
      ```

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
