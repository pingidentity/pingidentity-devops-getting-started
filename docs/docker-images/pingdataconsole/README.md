---
title: Ping Identity DevOps Docker Image - `pingdataconsole`
---


# Ping Identity Docker Image - `pingdataconsole`

This docker image provides a tomcat image with the PingDataConsole
deployed to be used in configuration of the PingData products.

## Related Docker Images
- `tomcat:9-jre17` - Tomcat engine to serve PingDataConsole .war file (PingDataConsole 10.2.x and older)
- `tomcat:11-jre17` - Tomcat engine to serve PingDataConsole .war file

## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| DATE  | ${DATE}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_PRODUCT  | PingDataConsole  | Ping product name  |
| HTTP_PORT  | 8080  | PingDataConsole HTTP listen port  |
| HTTPS_PORT  | 8443  | PingDataConsole HTTPS listen port  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/catalina.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | run  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  | start  | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/console.log  | Files tailed once container has started  |
| BRANDING_APP_NAME  | PingDirectory Admin Console  | Sets the name of the application, which appears on the Sign On page and the product banner  |
| SYSTEM_READ_ONLY  | false  | When true, puts the console in read-only mode.  The user will not be able to modify the server's configuration or schema, regardless of which account was used to sign in  |

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
* http://localhost:${HTTPS_PORT}/console/login (for versions prior to 11.0.x)
or
* https://localhost:${HTTPS_PORT}/console (for versions 11.0.x and newer)
```
Server: pingdirectory:1636
Username: administrator
Password: 2FederateM0re
```
> make sure you have an accessible PingDirectory running

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdataconsole/hooks/README.md) for details on all pingdataconsole hook scripts

---
This document is auto-generated from _[pingdataconsole/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdataconsole/Dockerfile)_

Copyright © 2026 Ping Identity Corporation
