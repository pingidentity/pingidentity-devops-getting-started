# Purpose
This builds on the previous "Docker stand-alone" set of tutorials and shows how we can more simply assemble -or "compose"- containers together into a functioning service.

## Getting started
Create a local directory to use to persist the mutable data from PingDirectory

  `mkdir /tmp/Compose/pingdirectory`

The images are updated very frequently, sometimes multiple times a day. Make sure you get the latest version of the images with:
  `docker-compose pull`
  
Start Compose with:

  `docker-compose up -d`

View container logs with: 

`docker-compose logs`

## Using the containers
At this point you should see docker-compose create the services for a PingFederate instance and a PingDirectory instance. Note that these services are started up in the foreground.  Upon exiting (ctrl-C), the services will be stopped.

Once the PingDirectory instance is up, 

* Go to https://localhost:9031/OAuthPlayground
* Click on ```implicit``` 
* Log in with user.0 / 2FederateM0re

In the PingFederate management console

* Go to https://localhost:9999/pingfederate/app
* Log in with Administrator / 2FederateM0re

PingDirectory exposes LDAP traffic via an LDAPS port 1636. 
* Navigate to https://localhost:1636/dc=example,dc=com

## More exploration
You can look at the files in /tmp/Compose/pingdirectory for details about what the PingDirectory persists to the volume mount.

## Cleaning up
To bring the swarm down and clean up the instance created:

* `docker-compose down`
* `rm -rf /tmp/Compose/pingdirectory`
