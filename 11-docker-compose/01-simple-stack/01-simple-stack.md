# 01-simple-stack

This is an example of a simple integration between PingFederate and PingDirectory, where the logins with PingFederate will authenticate against users in the PingDirectory.

## Getting started

Please refer to the [Docker Compose Overview](./) for details on how to start, stop, cleanup stacks.

Start the services and view the logs with the following commands:

* `docker-compose up --detach`
* `docker-compose logs`

## Using the containers

At this point you should see docker-compose create the services for a PingFederate instance and a PingDirectory instance. Note that these services are started up in the foreground. Upon exiting \(ctrl-C\), the services will be stopped.

Once the PingDirectory instance is up,

* Go to [https://localhost:9031/OAuthPlayground](https://localhost:9031/OAuthPlayground)
* Click on `implicit` 
* Log in with `user.0 / 2FederateM0re`

To see the PingFederate management console

* Go to [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)
* Log in with `Administrator / 2FederateM0re`

To see the PingDirectory management console

* Go to [http://localhost:8080/console](http://localhost:8080/console)
* Log in with `Administrator / 2FederateM0re`

PingDirectory exposes LDAP traffic via an LDAPS port 1636.

* Navigate to [https://localhost:1636/dc=example,dc=com](https://localhost:1636/dc=example,dc=com)

## Cleaning up

To bring the stack down:

`docker-compose down`

