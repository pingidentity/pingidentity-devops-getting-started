# Docker Compose Example - Simple Sync
This is an example of PingDataSync synchronizing data from a source tree
on a PingDirectory instance to a destination tree on the same PingDirectory
instance.

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


## Cleaning up
To bring the stack down:

`docker-compose down`
