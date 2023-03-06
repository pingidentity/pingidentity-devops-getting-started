---
title: Ping Identity DevOps Docker Image - `pingcentral`
---


# Ping Identity DevOps Docker Image - `pingcentral`

This docker image includes the Ping Identity PingCentral product binaries
and associated hook scripts to create and run PingCentral in a container.

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
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_CENTRAL_SERVER_PORT  | 9022  |  |
| PING_PRODUCT  | PingCentral  | Ping product name  |
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/conf  | License directory  |
| LICENSE_FILE_NAME  | pingcentral.lic  | Name of license file  |
| LICENSE_SHORT_NAME  | PC  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/log/application.log  | Files tailed once container has started  |
| PING_CENTRAL_LOG_LEVEL  | INFO  |  |
| PING_CENTRAL_BLIND_TRUST  | false  |  |
| PING_CENTRAL_VERIFY_HOSTNAME  | true  |  |

## Ports Exposed

The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container

- 9022

## Running a PingCentral container
To run a PingCentral container with your devops configuration file:
```shell docker run -Pt \
           --name pingcentral \
           --env-file ~/.pingidentity/config \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingcentral:edge
```
or with long options in the background:
```shell
  docker run \
           --name pingcentral \
           --publish 9022:9022 \
           --detach \
           --env-file ~/.pingidentity/config \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingcentral:edge
```

or if you want to specify everything yourself:
```shell
  docker run \
           --name pingcentral \
           --publish 9022:9022 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingcentral:edge
```

Follow Docker logs with:

``` shell
docker logs -f pingcentral
```

If using the command above with the embedded [server profile](https://devops.pingidentity.com/reference/config/), log in with:
* https://localhost:9022/
  * Username: Administrator
  * Password: 2Federate

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingcentral/hooks/README.md) for details on all pingcentral hook scripts

---
This document is auto-generated from _[pingcentral/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcentral/Dockerfile)_

Copyright © 2023 Ping Identity Corporation. All rights reserved.
