---
title: Ping Identity DevOps Docker Image - `pingauthorizepap`
---

# Ping Identity DevOps Docker Image - `pingauthorizepap`

This docker image includes the Ping Identity PingAuthorize Policy Editor product binaries
and associated hook scripts to create and run a PingAuthorize Policy Editor instance.

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
> This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)
- `pingidentity/pingdatacommon` - Common Ping files (i.e. hook scripts)
- `pingidentity/pingdownloader` - Used to download product bits


## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**,
the following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| PING_PRODUCT  | PingAuthorize-PAP  | Ping product name  |
| LICENSE_FILE_NAME  | PingAuthorize.lic  | Name of license File  |
| LICENSE_SHORT_NAME  | PingAuthorize  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| MAX_HEAP_SIZE  | 384m  | Minimal Heap size required for PingAuthorize Policy Editor  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | --nodetach  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/pingauthorize-pap.log ${SERVER_ROOT_DIR}/logs/setup.log ${SERVER_ROOT_DIR}/logs/start-server.log ${SERVER_ROOT_DIR}/logs/stop-server.log  | Files tailed once container has started  |
| REST_API_HOSTNAME  | localhost  | Hostname used for the REST API (deprecated, use `PING_EXTERNAL_BASE_URL` instead)  |
| DECISION_POINT_SHARED_SECRET  | 2FederateM0re  | Define shared secret between PAZ and the Policy Editor  |

## Ports Exposed

The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container

- ${HTTPS_PORT}

## Running a PingAuthorize Policy Editor container

A PingAuthorize Policy Editor may be set up in one of two modes:

* **Demo mode**: Uses insecure username/password authentication.
* **OIDC mode**: Uses an OpenID Connect provider for authentication.

To run a PingAuthorize Policy Editor container in demo mode:

```
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --publish 8443:443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingauthorizepap:edge
```

Log in with:
* https://my-pap-hostname:8443/
  * Username: admin
  * Password: password123

To run a PingAuthorize Policy Editor container in OpenID Connect mode, specify
the `PING_OIDC_CONFIGURATION_ENDPOINT` and `PING_CLIENT_ID` environment
variables:

```
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pe-hostname:8443 \
           --env PING_OIDC_CONFIGURATION_ENDPOINT=https://my-oidc-provider/.well-known/openid-configuration \
           --env PING_CLIENT_ID=b1929abc-e108-4b4f-83d467059fa1 \
           --publish 8443:1443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingauthorizepap:edge
```

Note: If both `PING_OIDC_CONFIGURATION_ENDPOINT` and `PING_CLIENT_ID` are
not specified, then the PingAuthorize Policy Editor will be set up in demo mode.

Log in with:
* https://my-pap-hostname:8443/
  * Provide credentials as prompted by the OIDC provider

Follow Docker logs with:

```
docker logs -f pingauthorizepap
```


## Specifying the external hostname and port

The Policy Editor consists of a client-side application that runs in the user's web
browser and a backend REST API service that runs within the container. So
that the client-side application can successfully make API calls to the
backend, the Policy Editor must be configured with an externally accessible
hostname:port. If the Policy Editor is configured in OIDC mode, then the external
hostname:port pair is also needed so that the Policy Editor can correctly generate its
OIDC redirect URI.

Use the `PING_EXTERNAL_BASE_URL` environment variable to specify the Policy Editor's
external hostname and port using the form `hostname[:port]`, where `hostname`
is the hostname of the Docker host and `port` is the Policy Editor container's published
port. If the published port is 443, then it should be omitted.

For example:

```
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --publish 8443:443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingauthorizepap:edge
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
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --env PING_BACKUP_SCHEDULE="0 0 12 * * ?" \
           --env PING_H2_BACKUP_DIR=/opt/out/backup \
           --publish 8443:1443 \
           --detach \
           pingidentity/pingauthorizepap:edge
```



## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingauthorizepap/hooks/README.md) for details on all pingauthorizepap hook scripts

---
This document is auto-generated from _[pingauthorizepap/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingauthorizepap/Dockerfile)_

Copyright © 2021 Ping Identity Corporation. All rights reserved.
