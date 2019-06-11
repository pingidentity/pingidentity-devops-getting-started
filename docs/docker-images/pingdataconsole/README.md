
# Ping Identity Docker Image - `pingdataconsole`

This docker image provides a tomcat image with the PingDataConsole
deployed to be used in configuration of the PingData products.

## Related Docker Images
- `pingidentity/pingdownloader` - Image used to download ping product
- `tomcat:8-jre8-alpine` - Tomcat engine to serve PingDataConsole .war file

## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- 8080
- 8443

## Run
To run a PingDataConsole container: 

```shell
  docker run \
           --name pingdataconsole \
           --publish 8080:8080 \
           --detach \
           pingidentity/pingdataconsole
```


Follow Docker logs with:

```
docker logs -f pingdataconsole
```

If using the command above with the embedded [server profile](../server-profiles/README.md), log in with: 
* http://localhost:8080/console/login
```
Server: pingdirectory
Username: administrator
Password: 2FederateM0re
```
>make sure you have a PingDirectory running
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdataconsole/hooks/README.md) for details on all pingdataconsole hook scripts

---
This document auto-generated from _[pingdataconsole/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdataconsole/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
