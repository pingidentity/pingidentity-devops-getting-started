---
title: Ping Identity DevOps Docker Image - `pingdatasync`
---

# Ping Identity DevOps Docker Image - `pingdatasync`

This docker image includes the Ping Identity PingDataSync product binaries
and associated hook scripts to create and run a PingDataSync instance.

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
> This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)
- `pingidentity/pingdatacommon` - Common Ping files (i.e. hook scripts)


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
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/sync  | Files tailed once container has started  |
| LICENSE_DIR  | ${PD_LICENSE_DIR}  | PD License directory. This value is set from the pingbase docker file  |
| LICENSE_FILE_NAME  | PingDirectory.lic  | Name of license file  |
| LICENSE_SHORT_NAME  | PD  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| PING_PRODUCT  | PingDataSync  | Ping product name  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | --nodetach  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| RETRY_TIMEOUT_SECONDS  | 180  | The default retry timeout in seconds for manage-topology and remove-defunct-server  |
| ADMIN_USER_NAME  | admin  | Failover administrative user  |
| ROOT_USER_PASSWORD_FILE  |   | Location of file with the root user password (i.e. cn=directory manager). Defaults to /SECRETS_DIR/root-user-password  |
| ADMIN_USER_PASSWORD_FILE  |   | Location of file with the admin password, used as the password replication admin Defaults to /SECRETS_DIR/admin-user-password  |
| KEYSTORE_FILE  |   | Location of the keystore file containing the server certificate. If left undefined, the SECRETS_DIR will be checked for a keystore. If that keystore does not exist, the server will generate a self-signed certificate.  |
| KEYSTORE_PIN_FILE  |   | Location of the pin file for the keystore defined in KEYSTORE_FILE. If left undefined, the SECRETS_DIR will be checked for a pin file. This value does not need to be defined when allowing the server to generate a self-signed certificate.  |
| KEYSTORE_TYPE  |   | Format of the keystore defined in KEYSTORE_FILE. One of "jks", "pkcs12", "pem", or "bcfks" (in FIPS mode). If not defined, the keystore format will be inferred based on the file extension of the KEYSTORE_FILE, defaulting to "jks".  |
| TRUSTSTORE_FILE  |   | Location of the truststore file for the server. If left undefined, the SECRETS_DIR will be checked for a truststore. If that truststore does not exist, the server will generate a truststore, containing its own certificate.  |
| TRUSTSTORE_PIN_FILE  |   | Location of the pin file for the truststore defined in TRUSTSTORE_FILE. If left undefined, the SECRETS_DIR will be checked for a pin file. This value does not need to be defined when allowing the server to generate a truststore.  |
| TRUSTSTORE_TYPE  |   | Format of the truststore defined in TRUSTSTORE_FILE. One of "jks", "pkcs12", "pem", or "bcfks" (in FIPS mode). If not defined, the truststore format will be inferred based on the file extension of the TRUSTSTORE_FILE, defaulting to "jks".  |
| PD_PROFILE  | ${STAGING_DIR}/pd.profile  | Directory for the profile used by the PingData manage-profile tool  |
| UNBOUNDID_SKIP_START_PRECHECK_NODETACH  | true  | Setting this variable to true speeds up server startup time by skipping an unnecessary JVM check.  |
| PARALLEL_POD_MANAGEMENT_POLICY  | false  | Whether this container is running as a Pod in a Kubernetes StatefulSet, and that StatefulSet is using the Parallel podManagementPolicy. This property allows for starting up Pods in parallel to speed up the initial startup of PingDataSync topologies. This variable must be set to true when using the Parallel podManagementPolicy. Note: when using parallel startup, ensure the RETRY_TIMEOUT_SECONDS variable is large enough. The pods will be enabling replication simultaneously, so some pods will have to retry while waiting for others to complete. If the timeout is too low, a Pod may end up restarting unnecessarily.  |
| SKIP_WAIT_FOR_DNS  | false  | Set to true to skip the waiting for DNS step that is normally done just before attempting to join the topology.  |

## Ports Exposed

The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container

- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}

## Running a PingDataSync container
```
  docker run \
           --name pingdatasync \
           --publish 1389:1389 \
           --publish 8443:1443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=simple-sync/pingdatasync \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdatasync:edge
```

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatasync/hooks/README.md) for details on all pingdatasync hook scripts

---
This document is auto-generated from _[pingdatasync/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatasync/Dockerfile)_

Copyright © 2022 Ping Identity Corporation. All rights reserved.
