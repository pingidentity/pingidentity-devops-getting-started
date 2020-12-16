
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
| SHIM  | ${SHIM}  | 
| PING_PRODUCT  | PingDataGovernance-PAP  | PingIdentity license version Ping product name 
| LICENSE_FILE_NAME  | PingDataGovernance.lic  | Name of License File 
| LICENSE_SHORT_NAME  | PG  | Shortname used when retrieving license from License Server 
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server 
| MAX_HEAP_SIZE  | 384m  | Minimal Heap size required for Ping DataGovernance PAP 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | 
| STARTUP_FOREGROUND_OPTS  | --nodetach  | Adding lockdown mode so non administrive connections be made until server has been started with replication enabled 
| STARTUP_BACKGROUND_OPTS  |   | Adding lockdown mode so non administrive connections be made until server has been started with replication enabled 
| TAIL_LOG_PARALLEL  | y  | 
| TAIL_LOG_FILES  | "${SERVER_ROOT_DIR}/logs/datagovernance-pap.log \  | Files tailed once container has started 
| REST_API_HOSTNAME  | localhost  | Hostname used for the REST API (deprecated, use `PING_EXTERNAL_BASE_URL` instead) 
| DECISION_POINT_SHARED_SECRET  | 2FederateM0re  | Define shared secret between PDG and PAP 
## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- ${HTTPS_PORT}

## Running a PingDataGovernance PAP container

A PingDataGovernance PAP may be set up in one of two modes:

* **Demo mode**: Uses insecure username/password authentication.
* **OIDC mode**: Uses an OpenID Connect provider for authentication.

To run a PingDataGovernance PAP container in demo mode:

```
  docker run \
           --name pingdatagovernancepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --publish 8443:443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdatagovernancepap:edge
```

Log in with:
* https://my-pap-hostname:8443/
  * Username: admin
  * Password: password123

To run a PingDataGovernance PAP container in OpenID Connect mode, specify
the `PING_OIDC_CONFIGURATION_ENDPOINT` and `PING_CLIENT_ID` environment
variables:

```
  docker run \
           --name pingdatagovernancepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --env PING_OIDC_CONFIGURATION_ENDPOINT=https://my-oidc-provider/.well-known/openid-configuration \
           --env PING_CLIENT_ID=b1929abc-e108-4b4f-83d467059fa1 \
           --publish 8443:443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdatagovernancepap:edge
```

Note: If both `PING_OIDC_CONFIGURATION_ENDPOINT` and `PING_CLIENT_ID` are
not specified, then the PAP will be set up in demo mode.

Log in with:
* https://my-pap-hostname:8443/
  * Provide credentials as prompted by the OIDC provider

Follow Docker logs with:

```
docker logs -f pingdatagovernancepap
```


## Specifying the external hostname and port

The PAP consists of a client-side application that runs in the user's web
browser and a backend REST API service that runs within the container. So
that the client-side application can successfully make API calls to the
backend, the PAP must be configured with an externally accessible
hostname:port. If the PAP is configured in OIDC mode, then the external
hostname:port pair is also needed so that the PAP can correctly generate its
OIDC redirect URI.

Use the `PING_EXTERNAL_BASE_URL` environment variable to specify the PAP's
external hostname and port using the form `hostname[:port]`, where `hostname`
is the hostname of the Docker host and `port` is the PAP container's published
port. If the published port is 443, then it should be omitted.

For example:

```
  docker run \
           --name pingdatagovernancepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --publish 8443:443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdatagovernancepap:edge
```


## Changing the default periodic database backup schedule and location

The PAP performs periodic backups of the policy database. The results
are placed in the `policy-backup` directory underneath the instance root.

Use the `PING_BACKUP_SCHEDULE` environment variable to specify the PAP's
periodic database backup schedule in the form of a cron expression.
The cron expression will be evaluated against the container timezone,
UTC. Use the `PING_H2_BACKUP_DIR` environment variable to change the
backup output directory.

For example, to perform backups daily at UTC noon and place backups in
`/opt/out/backup`:

```
  docker run \
           --name pingdatagovernancepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --env PING_BACKUP_SCHEDULE="0 0 12 * * ?" \
           --env PING_H2_BACKUP_DIR=/opt/out/backup \
           --publish 8443:443 \
           --detach \
           pingidentity/pingdatagovernancepap:edge
```


## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatagovernancepap/hooks/README.md) for details on all pingdatagovernancepap hook scripts

---
This document auto-generated from _[pingdatagovernancepap/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatagovernancepap/Dockerfile)_

Copyright (c) 2020 Ping Identity Corporation. All rights reserved.
