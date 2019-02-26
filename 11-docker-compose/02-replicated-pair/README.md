# Purpose
This is an example of how to start multiple instances of PingDirectory from a single docker-compose file.

## Getting started
The images are updated very frequently, sometimes multiple times a day, make sure you have the latest version of the images with:
  `docker-compose pull`  

To stand up multiple containers with a single command add the `--scale` argument to `docker-compose up`:

`docker-compose up -d --scale pingdirectory=2`

Watch the directories initialize with: 
`docker-compose logs -f`

## The interesting bit
The interesting piece of the puzzle here is the topology.json file located within the server-profile.
Have a look:
```
{
    "serverInstances" : [
        {
            "instanceName" : "02-replicated-pair_pingdirectory_1",
            "hostname" : "02-replicated-pair_pingdirectory_1",
            "location" : "docker",
            "ldapPort" : 389,
            "ldapsPort" : 636,
            "replicationPort" : 989,
            "startTLSEnabled" : true,
            "preferredSecurity" : "SSL",
            "product" : "DIRECTORY"
        },
        {
            "instanceName" : "02-replicated-pair_pingdirectory_2",
            "hostname" : "02-replicated-pair_pingdirectory_2",
            "location" : "docker",
            "ldapPort" : 389,
            "ldapsPort" : 636,
            "replicationPort" : 989,
            "startTLSEnabled" : true,
            "preferredSecurity" : "SSL",
            "product" : "DIRECTORY"
        }
    ]
}
```

This is a mechanism we provide to make joining replication topologies robust.
A very important aspect of this approach is idempotence.

As you can see, the fact that the file has harcoded hostnames doesn't bode well for dynamic environments, as such, in a later tutorial we'll see how we can use a template to generate the topology file while scaling an environment.

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
