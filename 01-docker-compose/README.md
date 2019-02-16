# Purpose
This folder is intended to demonstrate how docker compose can be used to assemble several images, each with their own role, into a functioning deployed set of containers.
Docker compose can be useful for local development as it does not require an external orchestrator such as docker swarm or kubernetes.

## Getting started

First off, create a local directory that is going to be used to persist the mutable data from PingDirectory
`mkdir /tmp/Compose/pingdirectory`

Then compose the software stack up with
`docker-compose up`

At this poing you should see docker-compose create the services for a PingFederate instance and a PingDirectory instance.

Once the PingDirectory instance is up, go to https://localhost:9031/OAuthPlayground
Click on implicit and log in with user.0 / password

The PingFederate management console is avaiable at https://localhost:9999/pingfederate/app

PingDirectory exposes a SCIM API on https://localhost:1443/scim and is available for LDAPS traffic on port 1636
