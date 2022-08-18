---
title: Ping Identity DevOps Docker Image - `pingdataconsole`
---


# Ping Identity Docker Image - `pingdataconsole`

This docker image provides a tomcat image with the PingDataConsole
deployed to be used in configuration of the PingData products.

## Related Docker Images
- `tomcat:9-jre8` - Tomcat engine to serve PingDataConsole .war file

## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| HTTP_PORT  | 8080  | PingDataConsole HTTP listen port  |
| HTTPS_PORT  | 8443  | PingDataConsole HTTPS listen port  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/catalina.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | run  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  | start  | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/console.log  | Files tailed once container has started  |

## Run
To run a PingDataConsole container:

```shell
  docker run \
           --name pingdataconsole \
           --publish ${HTTPS_PORT}:${HTTPS_PORT} \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdataconsole:edge
```


Follow Docker logs with:

```
docker logs -f pingdataconsole
```

If using the command above with the embedded [server profile](https://devops.pingidentity.com/reference/config/), log in with:
* http://localhost:${HTTPS_PORT}/console/login
```
Server: pingdirectory:1636
Username: administrator
Password: 2FederateM0re
```
> make sure you have a PingDirectory running

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdataconsole/hooks/README.md) for details on all pingdataconsole hook scripts

---
This document is auto-generated from _[pingdataconsole/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdataconsole/Dockerfile)_

Copyright © 2022 Ping Identity Corporation. All rights reserved.
