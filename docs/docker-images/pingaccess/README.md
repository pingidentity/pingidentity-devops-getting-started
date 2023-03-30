---
title: Ping Identity DevOps Docker Image - `pingaccess`
---

# Ping Identity DevOps Docker Image - `pingaccess`

This docker image includes the Ping Identity PingAccess product binaries
and associated hook scripts to create and run both PingAccess Admin and
Engine nodes.

## Related Docker Images

- `pingidentity/pingbase` - Parent Image
> This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)
- `pingidentity/pingcommon` - Common Ping files (i.e. hook scripts)

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**,
the following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| DATE  | ${DATE}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_PRODUCT  | PingAccess  | Ping product name  |
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/conf  | License directory  |
| LICENSE_FILE_NAME  | pingaccess.lic  | Name of license file  |
| LICENSE_SHORT_NAME  | PA  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| OPERATIONAL_MODE  | STANDALONE  |  |
| PA_ADMIN_PASSWORD_INITIAL  | 2Access  |  |
| PING_IDENTITY_PASSWORD  | 2FederateM0re  | Specify a password for administrator user for interaction with admin API  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/log/pingaccess.log  | Files tailed once container has started  |
| PA_ADMIN_PORT  | 9000  | Default port for PA Admin API and console Ignored when using PingIdentity Helm charts  |
| PA_ADMIN_CLUSTER_PORT  | 9090  | Default port when clustering PA primary administrative node Ignored when using PingIdentity Helm charts  |
| JAVA_RAM_PERCENTAGE  | 60.0  | Percentage of the container memory to allocate to PingAccess JVM DO NOT set to 100% or your JVM will exit with OutOfMemory errors and the container will terminate  |
| FIPS_MODE_ON  | false  | Turns on FIPS mode (currently with the Bouncy Castle FIPS provider) set to exactly "true" lowercase to turn on set to anything else to turn off  |
| SHOW_LIBS_VER  | true  | Defines a variable to allow showing library versions in the output at startup default to true  |
| SHOW_LIBS_VER_PRE_PATCH  | false  | Defines a variable to allow showing library version prior to patches being applied default to false This is helpful to ensure that the patch process updates all libraries affected  |
| PA_ENGINE_PORT  | 3000  |  |
| ADMIN_WAITFOR_TIMEOUT  | 300  | wait-for timeout for 80-post-start.sh hook script How long to wait for the PA Admin console to be available  |

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
           --publish 443:1443 \
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

- https://localhost:9000
  - Username: Administrator
  - Password: 2FederateM0re

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingaccess/hooks/README.md) for details on all pingaccess hook scripts

---
This document is auto-generated from _[pingaccess/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingaccess/Dockerfile)_

Copyright © 2023 Ping Identity Corporation. All rights reserved.
