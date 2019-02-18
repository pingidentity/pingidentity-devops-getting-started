# Purpose
This build on the previous "docker stand-alone" set of tutorials and shows how we can more simply assemble -or "compose"- containers together into a functioning service.

## Getting started
First off, create a local directory that is going to be used to persist the mutable data from PingDirectory
`mkdir /tmp/Compose/pingdirectory`

Then compose the software stack up with
`docker-compose up`

## Using the containers
At this poing you should see docker-compose create the services for a PingFederate instance and a PingDirectory instance.

Once the PingDirectory instance is up, go to https://localhost:9031/OAuthPlayground
Click on implicit and log in with user.0 / password

The PingFederate management console is avaiable at https://localhost:9999/pingfederate/app

PingDirectory exposes a SCIM API on https://localhost:1443/scim and is available for LDAPS traffic on port 1636

## More exploration
You can take a look at the files in /tmp/Compose/pingdirectory for details about what the PingDirectory persists to the volume mount

## Cleaning up
Simply `docker-compose down`
and `rm -rf /tmp/Compose/pingdirectory`