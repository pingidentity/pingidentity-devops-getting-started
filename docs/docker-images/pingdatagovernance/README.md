---
title: Ping Identity DevOps Docker Image - `pingdatagovernance`
---

# Ping Identity DevOps Docker Image - `pingdatagovernance`

This docker image includes the Ping Identity PingDataGovernance product binaries
and associated hook scripts to create and run a PingDataGovernance instance or
instances.

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
| PING_PRODUCT  | PingDataGovernance  | Ping product name  |
| LICENSE_FILE_NAME  | PingDataGovernance.lic  | Name of license file  |
| LICENSE_SHORT_NAME  | PG  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| MAX_HEAP_SIZE  | 1g  | Minimal Heap size required for Ping DataGovernance  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | --nodetach  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| ROOT_USER_PASSWORD_FILE  |   | Location of file with the root user password (i.e. cn=directory manager). Defaults to /SECRETS_DIR/root-user-password  |
| ENCRYPTION_PASSWORD_FILE  |   | Location of file with the passphrase for setting up encryption Defaults to /SECRETS_DIR/encryption-password  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/trace ${SERVER_ROOT_DIR}/logs/policy-decision ${SERVER_ROOT_DIR}/logs/ldap-access  | Files tailed once container has started  |
| PD_PROFILE  | ${STAGING_DIR}/pd.profile  | Directory for the profile used by the PingData manage-profile tool  |

## Ports Exposed

The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container

- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}

## Running a PingDataGovernance container

The easiest way to test test a simple standalone image of PingDataGovernance is to cut/paste the following command into a terminal on a machine with docker.

```
  docker run \
           --name pingdatagovernance \
           --publish 1389:1389 \
           --publish 8443:1443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingdatagovernance \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
          pingidentity/pingdatagovernance:edge
```

You can view the Docker logs with the command:

```
  docker logs -f pingdatagovernance
```

You should see the output from a PingDataGovernance install and configuration, ending with a message the the PingDataGovernance has
started.  After it starts, you will see some typical access logs.  Simply ``Ctrl-C`` after to stop tailing the logs.


## Stopping/Removing the container
To stop the container:

```
  docker container stop pingdatagovernance
```

To remove the container:

```
  docker container rm -f pingdatagovernance
```

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatagovernance/hooks/README.md) for details on all pingdatagovernance hook scripts

---
This document is auto-generated from _[pingdatagovernance/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatagovernance/Dockerfile)_

Copyright © 2021 Ping Identity Corporation. All rights reserved.
