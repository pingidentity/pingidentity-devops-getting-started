---
title: Ping Identity DevOps Docker Image - `pingauthorize`
---

# Ping Identity DevOps Docker Image - `pingauthorize`

This docker image includes the Ping Identity PingAuthorize product binaries
and associated hook scripts to create and run a PingAuthorize instance or
instances.

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
| SHIM  | ${SHIM}  |           --shm-size 256m \  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| DATE  | ${DATE}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_PRODUCT  | PingAuthorize  | Ping product name  |
| LICENSE_DIR  | ${PD_LICENSE_DIR}  | PD License directory. This value is set from the pingbase dockerfile  |
| LICENSE_FILE_NAME  | PingAuthorize.lic  | Name of license file  |
| LICENSE_SHORT_NAME  | PingAuthorize  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| MAX_HEAP_SIZE  | 1g  | Minimal Heap size required for PingAuthorize  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | --nodetach  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| ROOT_USER_PASSWORD_FILE  |   | Location of file with the root user password (i.e. cn=directory manager). Defaults to /SECRETS_DIR/root-user-password  |
| ENCRYPTION_PASSWORD_FILE  |   | Location of file with the passphrase for setting up encryption Defaults to /SECRETS_DIR/encryption-password  |
| KEYSTORE_FILE  |   | Location of the keystore file containing the server certificate. If left undefined, the SECRETS_DIR will be checked for a keystore. If that keystore does not exist, the server will generate a self-signed certificate.  |
| KEYSTORE_PIN_FILE  |   | Location of the pin file for the keystore defined in KEYSTORE_FILE. You must specify a KEYSTORE_PIN_FILE when a KEYSTORE_FILE is present. This value does not need to be defined when allowing the server to generate a self-signed certificate.  |
| KEYSTORE_TYPE  |   | Format of the keystore defined in KEYSTORE_FILE. One of "jks", "pkcs12", "pem", or "bcfks" (in FIPS mode). If not defined, the keystore format will be inferred based on the file extension of the KEYSTORE_FILE, defaulting to "jks".  |
| TRUSTSTORE_FILE  |   | Location of the truststore file for the server. If left undefined, the SECRETS_DIR will be checked for a truststore. If that truststore does not exist, the server will generate a truststore, containing its own certificate.  |
| TRUSTSTORE_PIN_FILE  |   | Location of the pin file for the truststore defined in TRUSTSTORE_FILE. You must specify a TRUSTSTORE_PIN_FILE when a TRUSTSTORE_FILE is present. This value does not need to be defined when allowing the server to generate a truststore.  |
| TRUSTSTORE_TYPE  |   | Format of the truststore defined in TRUSTSTORE_FILE. One of "jks", "pkcs12", "pem", or "bcfks" (in FIPS mode). If not defined, the truststore format will be inferred based on the file extension of the TRUSTSTORE_FILE, defaulting to "jks".  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/trace ${SERVER_ROOT_DIR}/logs/policy-decision ${SERVER_ROOT_DIR}/logs/ldap-access  | Files tailed once container has started  |
| PD_PROFILE  | ${STAGING_DIR}/pd.profile  | Directory for the profile used by the PingData manage-profile tool  |
| UNBOUNDID_SKIP_START_PRECHECK_NODETACH  | true  | Setting this variable to true speeds up server startup time by skipping an unnecessary JVM check.  |
| CERTIFICATE_NICKNAME  |   | There is an additional certificate-based variable used to identity the certificate alias used within the `KEYSTORE_FILE`. That variable is called `CERTIFICATE_NICKNAME`, which identifies the certificate to use by the server in the `KEYSTORE_FILE`. If a value is not provided, the container will look at the list certs found in the `KEYSTORE_FILE` and if one - and only one - certificate is found of type `PrivateKeyEntry`, that alias will be used.  |
| COLUMNS  | 120  | Sets the number of columns in PingAuthorize command-line tool output  |

## Ports Exposed

The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container

- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}

## Running a PingAuthorize container

The easiest way to test a simple standalone image of PingAuthorize is to cut/paste the following command into a terminal on a machine with docker.

```sh
  docker run \
           --name pingauthorize \
           --publish 1389:1389 \
           --publish 8443:1443 \
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

```sh
  docker logs -f pingauthorize
```

You should see the ouptut from a PingAuthorize install and configuration, ending with a message the the PingAuthorize has
started.  After it starts, you will see some typical access logs.  Simply ``Ctrl-C`` after to stop tailing the logs.


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

Copyright © 2025 Ping Identity Corporation. All rights reserved.
