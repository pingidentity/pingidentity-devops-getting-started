---
title: Deploying a PingDataSync Failover Server
---
# Deploying a PingDataSync Failover Server

Use Docker Compose to deploy a PingDirectory and PingDataSync stack. PingDataSync will synchronize data from a source tree on a PingDirectory instance to a destination tree on the same PingDirectory instance. The entries from `ou=source,o=sync` to `ou=destination,o=sync` will be synchronized every second.

Then, scale up the PingDataSync service to enable failover so that if an active PingDataSync server goes down, a second server automatically becomes active and picks up where the first left off.

Note: Configuring failover requires a PingDataSync 8.2.0.0 or later.

## Before you begin

You must complete [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## About this task

You will:

* Deploy the PingDirectory and PingDataSync stack.
* Scale up the PingDataSync service
* Test the deployment.
* Bring down or stop the stack.

## Deploy the PingDirectory and PingDataSync Stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/12-sync-failover-pair` directory and enter:

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

1. To scale PingDataSync instances, enter:

      ```sh
      docker-compose up -d --scale pingdatasync=2
      ```

## Testing the deployment

The stack will sync entries from `ou=source,o=sync` to `ou=destination,o=sync` every second. One of the two sync servers is considered active while the other remains on standby.

1. In one terminal window, tail the logs from the PingDataSync servers:

      ```sh
      docker-compose logs -f pingdatasync
      ```

1. In a second window, make a change to the `ou=source,o=sync` tree:

      ```text
      docker container exec -it 12-sync-failover-pair_pingdirectory_1 /opt/out/instance/bin/ldapmodify
      dn: uid=user.0,ou=people,ou=source,o=sync
      changetype: modify
      replace: description
      description: Change to source user.0

      <Ctrl-D>
      ```

      You'll see messages in the PingDataSync log showing `ADD/MODIFY` of the user synced to the `ou=destination,o=sync` tree.

1. To verify these log messages, enter:

      ```text
      docker container exec -it 12-sync-failover-pair-sync_pingdirectory_1 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,ou=destination,o=sync -s base '(&)' description
      ```

      Entries similar to the following will be returned:

      ```text
      # dn: uid=user.0,ou=People,ou=destination,o=sync
      # description: Change to source user.0
      ```

    You'll see that one of the two PingDataSync servers handled the change.

1. To stop the container that handled the change and see future operations handled by the remaining PingDataSync server, enter:

      ```sh
      docker stop 12-sync-failover-pair_pingdatasync_1
      ```

      You can now repeat steps 2 and 3 to verify that the remaining PingDataSync server is now active. It might take a moment to become active and handle the change after the first server is stopped.

## Cleaning up

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
