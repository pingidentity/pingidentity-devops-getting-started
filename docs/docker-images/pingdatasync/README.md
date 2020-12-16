
# Ping Identity DevOps Docker Image - `pingdatasync`

This docker image includes the Ping Identity PingDataSync product binaries
and associated hook scripts to create and run a PingDataSync instance.

## Related Docker Images
- pingidentity/pingbase - Parent Image
	>**This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/dockerimagesref/pingbase)**
- pingidentity/pingdatacommon - Common PingData files (i.e. hook scripts)
- pingidentity/pingdownloader - Used to download product bits

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**,
the following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  | 
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/sync  | PingIdentity license version 
| LICENSE_FILE_NAME  | PingDirectory.lic  | 
| LICENSE_SHORT_NAME  | PD  | 
| LICENSE_VERSION  | ${LICENSE_VERSION}  | 
| PING_PRODUCT  | PingDataSync  | 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | 
| STARTUP_FOREGROUND_OPTS  | --nodetach  | 
| RETRY_TIMEOUT_SECONDS  | 180  | The default retry timeout in seconds for manage-topology and remove-defunct-server 
| ADMIN_USER_NAME  | admin  | Failover administrative user 
| ROOT_USER_PASSWORD_FILE  |   | Location of file with the root user password (i.e. cn=directory manager). Defaults to the /SECRETS_DIR/root-user-password 
| ADMIN_USER_PASSWORD_FILE  |   | 
| PD_PROFILE  | ${STAGING_DIR}/pd.profile  | 
## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}

## Running a PingDataSync container
```
  docker run \
           --name pingdatasync \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=simple-sync/pingdatasync \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdatasync:edge
```
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatasync/hooks/README.md) for details on all pingdatasync hook scripts

---
This document auto-generated from _[pingdatasync/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatasync/Dockerfile)_

Copyright (c) 2020 Ping Identity Corporation. All rights reserved.
