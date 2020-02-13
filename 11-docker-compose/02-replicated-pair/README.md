# 02-replicated-pair

This is an example of multiple PingDirectory instances replicating between one another.

[docker-compose.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/02-replicated-pair/docker-compose.yaml)

## Getting started

Please refer to the [Docker Compose Overview](../README.md) for details on how to start, stop, cleanup stacks.

To stand up multiple containers with a single command add the `--scale` argument to `docker-compose up`:

`docker-compose up --detach --scale pingdirectory=2`

Watch the directories initialize with:

`docker-compose logs -f`

this may (will, actually) take several minutes.

Replication setup will be complete when you see a message like this one:
```
pingdirectory_2    | # [13/Feb/2020:16:22:17.802 +0000]
pingdirectory_2    | # Command Name: manage-topology
pingdirectory_2    | # Invocation ID: 9b122892-3c14-4327-bef4-5a6b00923529
pingdirectory_2    | # Exit Code: 0
pingdirectory_2    |
pingdirectory_2    | Only 1 instance (N/A (single instance topology)) found in current topology.  Adding 1st replica
pingdirectory_2    |
pingdirectory_2    | #############################################
pingdirectory_2    | # Enabling Replication
pingdirectory_2    | #
pingdirectory_2    | # Current Master Topology Instance: N/A (single instance topology)
pingdirectory_2    | #
pingdirectory_2    | #                                         Topology Master Server        POD Server
pingdirectory_2    | #                        02-replicated-pair_pingdirectory_1:8989  <-->  7a5a4161efa1:8989
pingdirectory_2    | #############################################
```

Once you have seen this message in the logs, in terminal, you can check that the replication topology is in a good state with this command
```
$ docker exec -t 02-replicated-pair_pingdirectory_1 out/instance/bin/dsreplication status

Arguments from tool properties file:  --trustAll  --adminUID admin
--adminPasswordFile /opt/staging/pwd --hostname localhost --port 1636 --useSSL


          --- Replication Status for dc=example,dc=com: Enabled ---
Server                           : Location : Entries : Conflict Entries : Backlog (1) : Rate (2)
---------------------------------:----------:---------:------------------:-------------:---------
570342204aa1 (570342204aa1:1636) : Docker   : 36      : 0                : 0           : 0
7a5a4161efa1 (7a5a4161efa1:1636) : Docker   : 36      : 0                : 0           : 0

```

## Using the containers

To see the PingDirectory management console

* Go to [https://localhost:8443/console](https://localhost:8443/console)
* Log in with `Administrator / 2FederateM0re`

> Note: The admin console is running in the pingdataconsole_1 container, not pingdirectory.

Make a change to a user entry on one of the containers. To look at the containers that docker-compose started:

`docker-compose ps`

Then:

```text
docker container exec -it 02-replicated-pair_pingdirectory_1 /opt/out/instance/bin/ldapmodify
dn: uid=user.0,ou=people,dc=example,dc=com
changetype: modify
replace: description
description: this modify was effected on the first container

<Ctrl-D>
```

Note: the white line, followed by the `<Ctrl-D>` are important here; that's how entries are separated in LDIF

On the other container, the matching entry will have the same description:

```text
docker container exec -it 02-replicated-pair_pingdirectory_2 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,dc=example,dc=com -s base '(&)' description

######OUTPUTS######
# dn: uid=user.0,ou=people,dc=example,dc=com
# description: this modify was effected on the first container
###################
```

## Cleaning up

To bring the stack down:

`docker-compose down`

