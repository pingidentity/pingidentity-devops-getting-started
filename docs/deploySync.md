# Data synchronization for PingDirectory using Docker Compose

This is an example of PingDataSync synchronizing data from a source tree
on a PingDirectory instance to a destination tree on the same PingDirectory
instance.

[docker-compose.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/04-simple-sync/docker-compose.yaml)

## Getting started
Please refer to the [Docker Compose Overview](../README.md) for details on how to
start, stop, cleanup stacks.

Start the services and view the logs with the following commands:

* `docker-compose up --detach`

## Using the containers
At this point you should see docker-compose create the services for a PingDataSync
instance and a PingDirectory instance. Note that these services are started up in the foreground.  Upon exiting (ctrl-C), the services will be stopped.

### Demonstrating a Synchronization of a User Change
This demo will sync entries from `ou=source,o=sync` to
`ou=destination,o=sync` every second.

In one terminal window, tail the logs from the PingDataSync server:

`docker logs 04-simple-sync_pingdatasync_1 -f`

Then in a second window, make a change to the `ou=source,o=sync` tree:

```
docker container exec -it 04-simple-sync_pingdirectory_1 /opt/out/instance/bin/ldapmodify
dn: uid=user.0,ou=people,ou=source,o=sync
changetype: modify
replace: description
description: Change to source user.0

<Ctrl-D>
```

You will see some messages back in the PingDatasync log showing `ADD/MODIFY`
of the user sync'd to the `ou=destination,o=sync` tree.  To
verify this (with example output):

```
docker container exec -it 04-simple-sync_pingdirectory_1 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,ou=destination,o=sync -s base '(&)' description

######OUTPUTS######
# dn: uid=user.0,ou=People,ou=destination,o=sync
# description: Change to source user.0
###################
```





## Deploy the PingDirectory and PingDataSync stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/04-simple-sync` directory (where the `docker-compose.yaml` file for the PingDirectory and PingDataSync stack is located). Enter:

  `docker-compose up -d`

  The containers for PingDirectory and PingDataSync will start up.

2. Check that PingDirectory and PingDataSync are healthy and running:

  `docker-compose ps`

  See [Docker Compose](../11-docker-compose) for help using Docker Compose.

## Test the deployment

The stack will sync entries from `ou=source,o=sync` to `ou=destination,o=sync` every second.

1. In one terminal window, tail the logs from the PingDataSync server:

  `docker logs 04-simple-sync_pingdatasync_1 -f`

2. In a second window, make a change to the `ou=source,o=sync` tree:

  ```text
  docker container exec -it 04-simple-sync_pingdirectory_1 /opt/out/instance/bin/ldapmodify
    dn: uid=user.0,ou=people,ou=source,o=sync
    changetype: modify
    replace: description
    description: Change to source user.0

  <Ctrl-D>
  ```

  You will see messages in the PingDataSync log showing `ADD/MODIFY` of the user sync'd to the `ou=destination,o=sync` tree.  To verify this, enter:

  ```text
  docker container exec -it 04-simple-sync_pingdirectory_1 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,ou=destination,o=sync -s base '(&)' description
  ```

  Entries similar to this are returned:

  ```text
  # dn: uid=user.0,ou=People,ou=destination,o=sync
  # description: Change to source user.0
  ```

When you no longer want to run this stack, you can either bring the stack down (recommended), or stop the running stack. Entering:

  `docker-compose down`

will remove all of the containers and associated Docker networks. Entering:

  `docker-compose stop`

will stop the running stack without removing any of the containers or associated Docker networks.
