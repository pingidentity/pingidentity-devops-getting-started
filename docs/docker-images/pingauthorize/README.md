
# Ping Identity DevOps Docker Image - `pingauthorize`

This docker image includes the Ping Identity PingAuthorize product binaries
and associated hook scripts to create and run a PingAuthorize instance or
instances.

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
	>**This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**
- `pingidentity/pingdatacommon` - Common Ping files (i.e. hook scripts)
- `pingidentity/pingdownloader` - Used to download product bits

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**,
the following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  | Image version and git revision, set by build process of the docker build  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| PING_PRODUCT  | PingAuthorize  | PingIdentity license version Ping product name  |
| LICENSE_FILE_NAME  | PingAuthorize.lic  | Name of License File  |
| LICENSE_SHORT_NAME  | PingAuthorize  | Shortname used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| MAX_HEAP_SIZE  | 1g  | Minimal Heap size required for PingAuthorize  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  |  |
| STARTUP_FOREGROUND_OPTS  | --nodetach  | Prevent the server from running as a background process  |
| STARTUP_BACKGROUND_OPTS  |   |  |
| ROOT_USER_PASSWORD_FILE  |   | Location of file with the root user password (i.e. cn=directory manager). Defaults to the /SECRETS_DIR/root-user-password  |
| ENCRYPTION_PASSWORD_FILE  |   | Location of file with the passphrase for setting up encryption Defaults to the /SECRETS_DIR/encryption-password  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/access  | Files tailed once container has started  |
| PD_PROFILE  | ${STAGING_DIR}/pd.profile  |  |

## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}
- 5005

## Running a PingAuthorize container

The easiest way to test a simple standalone image of PingAuthorize is to cut/paste the following command into a terminal on a machine with docker.

```
  docker run \
           --name pingauthorize \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingauthorize \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
          pingidentity/pingauthorize:edge
```

You can view the Docker logs with the command:

```
  docker logs -f pingauthorize
```

You should see the ouptut from a PingAuthorize install and configuration, ending with a message the the PingAuthorize has
started.  After it starts, you will see some typical access logs.  Simply ``Ctrl-C`` afer to stop tailing the logs.


## Stopping/Removing the container
To stop the container:

```
  docker container stop pingauthorize
```

To remove the container:

```
  docker container rm -f pingauthorize
```

## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingauthorize/hooks/README.md) for details on all pingauthorize hook scripts

---
This document is auto-generated from _[pingauthorize/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingauthorize/Dockerfile)_

Copyright (c) 2021 Ping Identity Corporation. All rights reserved.
