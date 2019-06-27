
# Ping Identity DevOps Docker Image - `pingdatasync`

This docker image includes the Ping Identity PingDataSync product binaries
and associated hook scripts to create and run a PingDataSync instance.

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
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/sync  | 
| LICENSE_FILE_NAME  | PingDirectory.lic  | 
| LICENSE_SHORT_NAME  | PD  | 
| LICENSE_VERSION  | 7.3  | 
| PING_PRODUCT  | PingDataSync  | 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | 
| STARTUP_FOREGROUND_OPTS  | --nodetach  | 
| ROOT_USER_PASSWORD_FILE  | ${SECRETS_DIR}/root-user-password  | 
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
           pingidentity/pingdatasync
```
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatasync/hooks/README.md) for details on all pingdatasync hook scripts

---
This document auto-generated from _[pingdatasync/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatasync/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
