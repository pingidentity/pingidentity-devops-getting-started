
# Ping Identity DevOps Docker Image - `pingdatagovernancepap`

This docker image includes the Ping Identity PingDataGovernance PAP product binaries
and associated hook scripts to create and run a PingDataGovernance PAP instance.

## Related Docker Images
- `tomcat:8-jre8-alpine` - Tomcat engine to serve PingDataConsole .war file

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**,
the following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| PING_PRODUCT  | PingDataGovernance-PAP  | PingIdentity license version Ping product name 
Set License Directory BASE (locaion where we start PAP application)
## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**,
the following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| LICENSE_DIR  | ${BASE}  | 
| LICENSE_FILE_NAME  | PingDataGovernance.lic  | Name of License File 
| LICENSE_SHORT_NAME  | PG  | Shortname used when retrieving license from License Server 
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server 
| MAX_HEAP_SIZE  | 384m  | Minimal Heap size required for Ping DataGovernance 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/admin-point-application/bin/admin-point-application  | 
| STARTUP_FOREGROUND_OPTS  | server ${SERVER_ROOT_DIR}/config/configuration.yml  | Adding lockdown mode so non administrive connections be made until server has been started with replication enabled 
| STARTUP_BACKGROUND_OPTS  |   | Adding lockdown mode so non administrive connections be made until server has been started with replication enabled 
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/datagovernance-pap.log  | Files tailed once container has started 
| REST_API_HOSTNAME  | localhost  | Hostname used for the REST API 
| DECISION_POINT_SHARED_SECRET  | 2FederateM0re  | Define shared secret between PDG and PAP 
## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- ${HTTPS_PORT}

## Running a PingDataGovernance PAP container
To run a PingDataGovernance PAP container: 

```she   ll
  docker run \
           --name pingdatagovernancepap \
           --publish 8443:443 \
           --detach \
           pingidentity/pingdatagovernancepap:edge
```

Follow Docker logs with:

```
docker logs -f pingdatagovernancepap
```

Log in with: 
* https://localhost:8443/
  * Username: admin
  * Password: password123
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatagovernancepap/hooks/README.md) for details on all pingdatagovernancepap hook scripts

---
This document auto-generated from _[pingdatagovernancepap/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatagovernancepap/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
