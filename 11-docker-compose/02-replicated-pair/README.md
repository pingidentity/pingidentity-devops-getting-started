# Purpose
This is an example of how to start multiple instances of PingDirectory from a single docker-compose file.

## Getting started
To stand up multiple containers with a single command add the `--scale` argument to `docker-compose up`:

`docker-compose up -d --scale pingdirectory=2`

Watch the directories initialize with: 
`docker-compose logs -f`

## The interesting bit
The interesting piece of the puzzle here is the topology.json file.
You should have a look.
This is a mechanism we provide to make joining replication topologies robust.
A very important aspect of this approach is idempotence.

As you can probably tell by now, the fact that the file has harcoded hostnames doesn't bode well for dynamic environments, and you'd be right, we'll see how we can use a template to generate the topology file as we scale an environment in a later tutorial.

## Using the containers
Make a change to a user entry on one of the containers. 
To look at the containers that docker-compose started: 
`docker container ls` 

Then:
```
docker container exec -it 02-replicated-pair_pingdirectory_1 sh
/opt/out/instance/bin/ldapmodify
dn: uid=user.0,ou=people,dc=example,dc=com
changetype: modify
replace: description
description: this modify was effected on the first container

```

Note: the white line is important here, that's how entries are sepearated in LDIF 

On the other container, the matching entry will have the same description:
`docker container exec -it 02-replicated-pair_pingdirectory_2 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,dc=example,dc=com -s base '(&)' description`

## Cleaning up
`docker-compose down`
