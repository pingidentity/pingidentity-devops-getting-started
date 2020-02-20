# Deploy PingDirectory and PingDataSync

You'll use Docker Compose to deploy a PingDirectory and PingDataSync stack. PingDataSync will synchronize data from a source tree on a PingDirectory instance to a destination tree on the same PingDirectory instance. The entries from `ou=source,o=sync` to `ou=destination,o=sync` will be synchronized every second.

## What you'll do

* Deploy the PingDirectory and PingDataSync stack.
* Test the deployment.
* Bring down or stop the stack.

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## Deploy the PingDirectory and PingDataSync stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/04-simple-sync` directory. Enter:

   ```bash
   docker-compose up -d
   ```

2. Check that PingDirectory and PingDataSync are healthy and running:

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

The stack will sync entries from `ou=source,o=sync` to `ou=destination,o=sync` every second.

1. In one terminal window, tail the logs from the PingDataSync server:

   ```bash
   docker logs 04-simple-sync_pingdatasync_1 -f
   ```

2. In a second window, make a change to the `ou=source,o=sync` tree:

   ```text
   docker container exec -it 04-simple-sync_pingdirectory_1 /opt/out/instance/bin/ldapmodify
    dn: uid=user.0,ou=people,ou=source,o=sync
    changetype: modify
    replace: description
    description: Change to source user.0

   <Ctrl-D>
   ```

3. You'll see messages in the PingDataSync log showing `ADD/MODIFY` of the user sync'd to the `ou=destination,o=sync` tree.  To verify this, enter:

   ```text
   docker container exec -it 04-simple-sync_pingdirectory_1 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,ou=destination,o=sync -s base '(&)' description
   ```

   Entries similar to this will be returned:

   ```text
   # dn: uid=user.0,ou=People,ou=destination,o=sync
   # description: Change to source user.0
   ```

4. When you no longer want to run this stack, you can either bring the stack down (recommended), or stop the running stack.

   To stop the running stack without removing any of the containers or associated Docker networks, enter:

   ```bash
   docker-compose stop
   ```

   To remove all of the containers and associated Docker networks, enter:

   ```bash
   docker-compose down
   ```
