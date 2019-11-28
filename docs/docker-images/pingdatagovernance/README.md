
# Ping Identity DevOps Docker Image - `pingdatagovernance`

This docker image includes the Ping Identity PingDataGovernance product binaries
and associated hook scripts to create and run a PingDataGovernance instance or 
instances.

## Related Docker Images
- pingidentity/pingbase - Parent Image
	>**This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**
- pingidentity/pingdatacommon - Common PingData files (i.e. hook scripts)
- pingidentity/pingdownloader - Used to download product bits

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**,
the following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| PING_PRODUCT  | PingDataGovernance  | PingIdentity license version Ping product name 
| LICENSE_FILE_NAME  | PingDataGovernance.lic  | Name of License File 
| LICENSE_SHORT_NAME  | PG  | Shortname used when retrieving license from License Server 
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server 
| MAX_HEAP_SIZE  | 1g  | Minimal Heap size required for Ping DataGovernance 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | 
| STARTUP_FOREGROUND_OPTS  | --nodetach  | Adding lockdown mode so non administrive connections be made until server has been started with replication enabled 
| STARTUP_BACKGROUND_OPTS  |   | Adding lockdown mode so non administrive connections be made until server has been started with replication enabled 
| ROOT_USER_PASSWORD_FILE  | ${SECRETS_DIR}/root-user-password  | 
| ENCRYPTION_PASSWORD_FILE  | ${SECRETS_DIR}/encryption-password  | 
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/access  | Files tailed once container has started 
## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}
- 5005

## Running a PingDataGovernance container

The easiest way to test test a simple standalone image of PingDataGovernance is to cut/paste the following command into a terminal on a machine with docker.

```
  docker run \
           --name pingdatagovernance \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingdatagovernance \
          pingidentity/pingdatagovernance:edge
```

You can view the Docker logs with the command:

```
  docker logs -f pingdatagovernance
```

You should see the ouptut from a PingDataGovernance install and configuration, ending with a message the the PingDataGovernance has 
started.  After it starts, you will see some typical access logs.  Simply ``Ctrl-C`` afer to stop tailing the logs.


## Connection with a REST Client
Connection a REST client from Postman or a browser using the default ports and credentials.  The
following url will provie a list of all SCIM2 schemas available.  It will be empty until 
some resoruces are configured.

|                 |                                   |
| --------------: | --------------------------------- |
| URL             | https://localhost:8443/scim/v2/Schemas |
| Username        | cn=administrator                  |
| Password        | 2FederateM0re                     |

## Stopping/Removing the container
To stop the container:

```
  docker container stop pingdatagovernance
```

To remove the container:

```
  docker container rm -f pingdatagovernance
```
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatagovernance/hooks/README.md) for details on all pingdatagovernance hook scripts

---
This document auto-generated from _[pingdatagovernance/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatagovernance/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
