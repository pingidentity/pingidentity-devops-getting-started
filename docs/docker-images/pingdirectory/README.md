---
title: Ping Identity DevOps Docker Image - `pingdirectory`
---

# Ping Identity DevOps Docker Image - `pingdirectory`

This docker image includes the Ping Identity PingDirectory product binaries
and associated hook scripts to create and run a PingDirectory instance or
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
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| DATE  | ${DATE}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_PRODUCT  | PingDirectory  | Ping product name  |
| LICENSE_DIR  | ${PD_LICENSE_DIR}  | PD License directory. This value is set from the pingbase docker file  |
| LICENSE_FILE_NAME  | PingDirectory.lic  | Name of license File  |
| LICENSE_SHORT_NAME  | PD  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| REPLICATION_PORT  | 8989  | Default PingDirectory Replication Port  |
| ADMIN_USER_NAME  | admin  | Replication administrative user  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| PD_DELEGATOR_PUBLIC_HOSTNAME  | localhost  | Public hostname of the DA app  |
| STARTUP_FOREGROUND_OPTS  | --nodetach  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| ROOT_USER_PASSWORD_FILE  |   | Location of file with the root user password (i.e. cn=directory manager). Defaults to /SECRETS_DIR/root-user-password  |
| ADMIN_USER_PASSWORD_FILE  |   | Location of file with the admin password, used as the password replication admin Defaults to /SECRETS_DIR/admin-user-password  |
| ENCRYPTION_PASSWORD_FILE  |   | Location of file with the passphrase for setting up encryption Defaults to /SECRETS_DIR/encryption-password  |
| KEYSTORE_FILE  |   | Location of the keystore file containing the server certificate. If left undefined, the SECRETS_DIR will be checked for a keystore. If that keystore does not exist, the server will generate a self-signed certificate.  |
| KEYSTORE_PIN_FILE  |   | Location of the pin file for the keystore defined in KEYSTORE_FILE. You must specify a KEYSTORE_PIN_FILE when a KEYSTORE_FILE is present. This value does not need to be defined when allowing the server to generate a self-signed certificate.  |
| KEYSTORE_TYPE  |   | Format of the keystore defined in KEYSTORE_FILE. One of "jks", "pkcs12", "pem", or "bcfks" (in FIPS mode). If not defined, the keystore format will be inferred based on the file extension of the KEYSTORE_FILE, defaulting to "jks".  |
| TRUSTSTORE_FILE  |   | Location of the truststore file for the server. If left undefined, the SECRETS_DIR will be checked for a truststore. If that truststore does not exist, the server will generate a truststore, containing its own certificate.  |
| TRUSTSTORE_PIN_FILE  |   | Location of the pin file for the truststore defined in TRUSTSTORE_FILE. You must specify a TRUSTSTORE_PIN_FILE when a TRUSTSTORE_FILE is present. This value does not need to be defined when allowing the server to generate a truststore.  |
| TRUSTSTORE_TYPE  |   | Format of the truststore defined in TRUSTSTORE_FILE. One of "jks", "pkcs12", "pem", or "bcfks" (in FIPS mode). If not defined, the truststore format will be inferred based on the file extension of the TRUSTSTORE_FILE, defaulting to "jks".  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/access ${SERVER_ROOT_DIR}/logs/errors ${SERVER_ROOT_DIR}/logs/failed-ops ${SERVER_ROOT_DIR}/logs/config-audit.log ${SERVER_ROOT_DIR}/logs/debug-trace ${SERVER_ROOT_DIR}/logs/debug-aci ${SERVER_ROOT_DIR}/logs/tools/*.log* ${SERVER_BITS_DIR}/logs/tools/*.log*   | Files tailed once container has started  |
| MAKELDIF_USERS  | 0  | Number of users to auto-populate using make-ldif templates  |
| RETRY_TIMEOUT_SECONDS  | 180  | The default retry timeout in seconds for dsreplication and remove-defunct-server  |
| PD_PROFILE  | ${STAGING_DIR}/pd.profile  | Directory for the profile used by the PingData manage-profile tool  |
| FIPS_MODE_ON  | false  | Turns on FIPS mode (currently with the Bouncy Castle FIPS provider) set to exactly "true" lowercase to turn on set to anything else to turn off  |
| FIPS_PROVIDER  | BCFIPS  | BCFIPS is the only provider currently supported -- do not edit  |
| PD_REBUILD_ON_RESTART  | false  | Force a rebuild (replace-profile) of a PingDirectoy on restart. Used to ensure that the server configuration exactly matches the server profile. This variable will slow down startup times and should only be used when necessary.  |
| UNBOUNDID_SKIP_START_PRECHECK_NODETACH  | true  | Setting this variable to true speeds up server startup time by skipping an unnecessary JVM check.  |
| REPLICATION_BASE_DNS  |   | Base DNs to include when enabling replication, in addition to the always-included USER_BASE_DN. Multiple base DNs can be specified here, separated by a `;` character  |
| RESTRICTED_BASE_DNS  |   | Base DNs to set as --restricted when enabling replication. Multiple base DNs can be specified here, separated by a `;` character. See the product documentation for more information on how to configure entry balancing.  |
| PARALLEL_POD_MANAGEMENT_POLICY  | false  | Whether this container is running as a Pod in a Kubernetes StatefulSet, and that StatefulSet is using the Parallel podManagementPolicy. This property allows for starting up Pods in parallel to speed up the initial startup of PingDirectory topologies. This variable must be set to true when using the Parallel podManagementPolicy. Note: when using parallel startup, ensure the RETRY_TIMEOUT_SECONDS variable is large enough. The pods will be enabling replication simultaneously, so some pods will have to retry while waiting for others to complete. If the timeout is too low, a Pod may end up restarting unnecessarily.  |
| SKIP_WAIT_FOR_DNS  | false  | Set to true to skip the waiting for DNS step that is normally done just before attempting to join the topology.  |
| CERTIFICATE_NICKNAME  |   | There is an additional certificate-based variable used to identity the certificate alias used within the `KEYSTORE_FILE`. That variable is called `CERTIFICATE_NICKNAME`, which identifies the certificate to use by the server in the `KEYSTORE_FILE`. If a value is not provided, the container will look at the list certs found in the `KEYSTORE_FILE` and if one - and only one - certificate is found of type `PrivateKeyEntry`, that alias will be used.  |
| PD_FORCE_DATA_REIMPORT  | false  | Set to true to force PingDirectory to export and re-import its backend data on restart. Note that this process can take a long time for large backends.  |
| LOAD_BALANCING_ALGORITHM_NAMES  |   | The load-balancing algorithm names to set for this server instance. This variable is only needed when enabling automatic server discovery with PingDirectoryProxy. Multiple algorithms can be specified here, separated by a `;` character  |
| COLUMNS  | 120  | Sets the number of columns in PingDirectory command-line tool output  |

## Ports Exposed

The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container

- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}

## Running a PingDirectory container

The easiest way to test test a simple standalone image of PingDirectory is to cut/paste the following command into a terminal on a machine with docker.

```
  docker run \
           --name pingdirectory \
           --publish 1389:1389 \
           --publish 8443:1443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdirectory:edge
```

You can view the Docker logs with the command:

```
  docker logs -f pingdirectory
```

You should see the ouptut from a PingDirectory install and configuration, ending with a message the the PingDirectory has started.  After it starts, you will see some typical access logs.  Simply ``Ctrl-C`` after to stop tailing the logs.

## Running a sample 100/sec search rate test
With the PingDirectory running from the previous section, you can run a ``searchrate`` job that will send load to the directory at a rate if 100/sec using the following command.

```
docker exec -it pingdirectory \
        /opt/out/instance/bin/searchrate \
                -b dc=example,dc=com \
                --scope sub \
                --filter "(uid=user.[1-9])" \
                --attribute mail \
                --numThreads 2 \
                --ratePerSecond 100
```

## Connecting with an LDAP Client
Connect an LDAP Client (such as Apache Directory Studio) to this container using the default ports and credentials

|                 |                                   |
| --------------: | --------------------------------- |
| LDAP Port       | 1389                              |
| LDAP Base DN    | dc=example,dc=com                 |
| Root Username   | cn=administrator                  |
| Root Password   | 2FederateM0re                     |

## Stopping/Removing the container
To stop the container:

```
  docker container stop pingdirectory
```

To remove the container:

```
  docker container rm -f pingdirectory
```

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdirectory/hooks/README.md) for details on all pingdirectory hook scripts

---
This document is auto-generated from _[pingdirectory/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectory/Dockerfile)_

Copyright © 2023 Ping Identity Corporation. All rights reserved.
