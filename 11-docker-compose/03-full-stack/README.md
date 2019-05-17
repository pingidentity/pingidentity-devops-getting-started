# Docker Compose Example - Full Stack
This is an example of a full stack integration between PingAccess,
PingFederate and PingDirectory.

## Getting started
Please refer to the [Docker Compose Overview](../README.md) for details on how to 
start, stop, cleanup stacks. 

To stand up multiple containers with a single command add the `--scale` argument to `docker-compose up`:

  `docker-compose up`

Watch the directories initialize with:

  `docker-compose logs -f`

## Using the containers
At this point you should see docker-compose create the services for a PingFederate instance and a PingDirectory instance. Note that these services are started up in the foreground.  Upon exiting (ctrl-C), the services will be stopped.

Once the PingDirectory instance is up, 

* Go to https://localhost:9031/OAuthPlayground
* Click on `implicit` link
* Click on `Submit` button
* Log in with `user.0 / 2FederateM0re`

To see the PingFederate management console

* Go to https://localhost:9999/pingfederate/app
* Log in with `Administrator / 2FederateM0re`

To see the PingAccess management console

* Go to https://localhost:9000
* Log in with `Administrator / 2Access`
* Note: You will be asked to accept license agreement and change password

To see the PingDirectory management console

* Go to http://localhost:8080/console
* Log in with `Administrator / 2FederateM0re`

PingDirectory exposes LDAP traffic via an LDAPS port 1636. 
* Navigate to https://localhost:1636/dc=example,dc=com


## Cleaning up
To bring the stack down:

`docker-compose down`
