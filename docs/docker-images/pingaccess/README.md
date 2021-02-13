
# Ping Identity DevOps Docker Image - `pingaccess`

This docker image includes the Ping Identity PingAccess product binaries
and associated hook scripts to create and run both PingAccess Admin and
Engine nodes.

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
	>**This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**
- `pingidentity/pingcommon` - Common Ping files (i.e. hook scripts)
- `pingidentity/pingdownloader` - Used to download product bits

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**,
the following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  | 
| PING_PRODUCT  | PingAccess  | 
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/conf  | 
| LICENSE_FILE_NAME  | pingaccess.lic  | 
| LICENSE_SHORT_NAME  | PA  | 
| LICENSE_VERSION  | ${LICENSE_VERSION}  | 
| PA_ADMIN_PASSWORD  | ${INITIAL_ADMIN_PASSWORD}  | 
| PING_IDENTITY_PASSWORD  | ${PA_ADMIN_PASSWORD}  | Specify a password for administrator user for interaction with admin API 
| OPERATIONAL_MODE  | STANDALONE  | 
| PA_ADMIN_PASSWORD_INITIAL  | 2Access  | Change **non-default** password at startup by including this and PING_IDENTITY_PASSWORD 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  | 
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/log/pingaccess.log  | 
| PA_ADMIN_PORT  | 9000  | 
| PA_ENGINE_PORT  | 3000  | 
## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- ${PA_ADMIN_PORT}
- ${PA_ENGINE_PORT}
- ${HTTPS_PORT}

## Running a PingAccess container
To run a PingAccess container:

```shell
  docker run \
           --name pingaccess \
           --publish 9000:9000 \
           --publish 443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingaccess \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingaccess:edge
```


Follow Docker logs with:

```
docker logs -f pingaccess
```

If using the command above with the embedded [server profile](https://devops.pingidentity.com/reference/config/), log in with:
* https://localhost:9000
  * Username: Administrator
  * Password: 2FederateM0re
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingaccess/hooks/README.md) for details on all pingaccess hook scripts

---
This document auto-generated from _[pingaccess/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingaccess/Dockerfile)_

Copyright (c) 2020 Ping Identity Corporation. All rights reserved.
