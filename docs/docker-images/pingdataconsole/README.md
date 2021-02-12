
# Ping Identity Docker Image - `pingdataconsole`

This docker image provides a tomcat image with the PingDataConsole
deployed to be used in configuration of the PingData products.

## Related Docker Images
- `pingidentity/pingdownloader` - Image used to download ping product
- `tomcat:8-jre8-alpine` - Tomcat engine to serve PingDataConsole .war file

## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  | Flag to force a run of dsjavaproperties --initialize. When this is false, the java.properties file will only be regenerated on a restart when there is a change in JVM or a change in the product-specific java options, such as changing the MAX_HEAP_SIZE value.
| HTTP_PORT  | 8080  |
| HTTPS_PORT  | 8443  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/catalina.sh  |
| STARTUP_FOREGROUND_OPTS  | run  |
| STARTUP_BACKGROUND_OPTS  | start  |
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
Server: pingdirectory:636
Username: administrator
Password: 2FederateM0re
```
> make sure you have a PingDirectory running
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdataconsole/hooks/README.md) for details on all pingdataconsole hook scripts

---
This document auto-generated from _[pingdataconsole/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdataconsole/Dockerfile)_

Copyright (c) 2021 Ping Identity Corporation. All rights reserved.
