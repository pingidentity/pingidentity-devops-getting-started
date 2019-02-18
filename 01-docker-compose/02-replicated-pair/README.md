# Purpose

## Getting started
The command to stand up this stack is a little different from the previous one we saw as it requires the use of `--scale` argument to `docker-compose up`
Do this:
`docker-compose up --scale pingdirectory=2`

## The interesting bit
The interesting piece of the puzzle here is the topology.json file.
You should have a look.
This is a mechanism we provide to make joining replication topologies robust.
A very important aspect of this approach is idem-potency.

## Using the containers
Make a change to a user entry on one of the containers 
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
