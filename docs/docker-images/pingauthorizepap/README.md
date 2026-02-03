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
| PING_PRODUCT  | PingAuthorize-PAP  | Ping product name  |
| LICENSE_DIR  | ${PD_LICENSE_DIR}  | PD License directory. This value is set from the pingbase dockerfile  |
| LICENSE_FILE_NAME  | PingAuthorize.lic  | Name of license File  |
| LICENSE_SHORT_NAME  | PingAuthorize  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| MAX_HEAP_SIZE  | 384m  | Minimal Heap size required for PingAuthorize Policy Editor  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | The command that the entrypoint executes in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | --nodetach  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| KEYSTORE_FILE  |   | Location of the keystore file containing the server certificate. If left undefined, the SECRETS_DIR will be checked for a keystore. If that keystore does not exist, the server will generate a self-signed certificate.  |
| KEYSTORE_PIN_FILE  |   | Location of the pin file for the keystore defined in KEYSTORE_FILE. You must specify a KEYSTORE_PIN_FILE when a KEYSTORE_FILE is present. This value does not need to be defined when allowing the server to generate a self-signed certificate.  |
| KEYSTORE_TYPE  |   | Format of the keystore defined in KEYSTORE_FILE. One of "jks" or "pkcs12". If not defined, the keystore format will be inferred based on the file extension of the KEYSTORE_FILE, defaulting to "jks".  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/authorize-pe.log ${SERVER_ROOT_DIR}/logs/management-audit.log ${SERVER_ROOT_DIR}/logs/policy-db.log ${SERVER_ROOT_DIR}/logs/setup.log ${SERVER_ROOT_DIR}/logs/start-server.log ${SERVER_ROOT_DIR}/logs/stop-server.log  | Files tailed once container has started  |
| REST_API_HOSTNAME  | localhost  | Hostname used for the REST API (deprecated, use `PING_EXTERNAL_BASE_URL` instead)  |
| DECISION_POINT_SHARED_SECRET  | 2FederateM0re  | Defines the shared secret between PAZ and the Policy Editor  |
| PING_ENABLE_API_HTTP_CACHE  | true  | When set to `false`, disables the default HTTP API caching in the Policy Manager, Trust Framework, and Test Suite  |
| PING_POLICY_DB_SYNC  |   | When set to `true`, the container uses the provided policy database admin credentials to either create a PostgreSQL policy database or upgrade it if it already exists. You must also provide the `PING_DB_CONNECTION_STRING`, `PING_DB_ADMIN_USERNAME`, `PING_DB_ADMIN_PASSWORD` `PING_DB_APP_USERNAME`, and `PING_DB_APP_PASSWORD` variables for this to work.  |
| PING_DB_CONNECTION_STRING  | jdbc:h2:file:./Symphonic;ALIAS_COLUMN_NAME=TRUE  | The JDBC connection string used to connect to the policy database. Use the format `jdbc:postgresql://<host>:<port>/<database>`. Only H2 embedded files and PostgreSQL are supported.  |
| PING_DB_ADMIN_USERNAME  | sa  | The database administration username to use when creating or upgrading a policy database.  |
| PING_DB_ADMIN_PASSWORD  | Passw0rd  | The database administration password to use when creating or upgrading a policy database.  |
| PING_DB_APP_USERNAME  | pap_user  | The username that the Policy Editor should use when accessing the policy database during server runtime.  |
| PING_DB_APP_PASSWORD  | Symphonic2014!  | The password that the Policy Editor should use when accessing the policy database during server runtime.  |

## Ports Exposed

The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container

- ${HTTPS_PORT}

## Running a PingAuthorize Policy Editor container

A PingAuthorize Policy Editor may be set up in one of two modes:

* **Demo mode**: Uses insecure username/password authentication.
* **OIDC mode**: Uses an OpenID Connect provider for authentication.

To run a PingAuthorize Policy Editor container in demo mode:

```sh
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --publish 8443:1443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingauthorizepap:edge
```

Log in with:

- https://my-pap-hostname:8443/
    - Username: admin
    - Password: password123

To run a PingAuthorize Policy Editor container in OpenID Connect mode, specify
the `PING_OIDC_CONFIGURATION_ENDPOINT` and `PING_CLIENT_ID` environment
variables. To provide scopes other than the default (`oidc email profile`),
specify the `PING_SCOPE` environment variable:

```sh
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pe-hostname:8443 \
           --env PING_OIDC_CONFIGURATION_ENDPOINT=https://my-oidc-provider/.well-known/openid-configuration \
           --env PING_CLIENT_ID=b1929abc-e108-4b4f-83d467059fa1 \
           --env PING_SCOPE="oidc email profile phone" \
           --publish 8443:1443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingauthorizepap:edge
```

Note: If both `PING_OIDC_CONFIGURATION_ENDPOINT` and `PING_CLIENT_ID` are
not specified, then Docker sets up the PingAuthorize Policy Editor container in demo mode.

Log in with:

- https://my-pap-hostname:8443/
    - Provide credentials as prompted by the OIDC provider

Follow Docker logs with:

```sh
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

```sh
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --publish 8443:1443 \
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
The cron expression evaluates against the container timezone,
UTC. Use the `PING_H2_BACKUP_DIR` environment variable to change the
backup output directory.

For example, to perform backups daily at UTC noon and place backups in
`/opt/out/backup`:

```sh
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --env PING_BACKUP_SCHEDULE="0 0 12 * * ?" \
           --env PING_H2_BACKUP_DIR=/opt/out/backup \
           --publish 8443:1443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingauthorizepap:edge
```



## Creating and upgrading a PostgreSQL policy database

Although the Policy Editor uses an embedded H2 file for its policy
database implementation by default, it also has the capability to use
a PostgreSQL database. However, this database must first be initialized
with database objects.

Set the `PING_POLICY_DB_SYNC` environment variable to `true`, provide
the PostgreSQL JDBC connection string in `PING_DB_CONNECTION_STRING`,
the database administration credentials through `PING_DB_ADMIN_USERNAME`
and `PING_DB_ADMIN_PASSWORD`, and the server runtime credentials through
`PING_DB_APP_USERNAME` and `PING_DB_APP_PASSWORD` to indicate that
pingauthorizepap should create the necessary policy database objects.

Similarly, use the same environment variables with the same values
when a new version of the application is released. pingauthorizepap
will use the database administration user to perform any necessary upgrades to the
database objects.

In both scenarios, the database administration user and the server runtime user
must exist and be able to sign into the PostgreSQL server. In the create
scenario, the database administration user must be able to create databases.
In the upgrade scenario, the database administration user must own the database
objects. Therefore, it is advisable to continually provide the same
administration credentials during creation and upgrades to prevent permissions issues.

For example, assume that a system administrator has created a
PostgreSQL username `pap_admin` that can sign into a PostgreSQL server hosted at
example.com and listening on port 5432. They have also created the runtime user
`pap_user`.

To create the database objects under the database named `my_pap_db` and start the Policy Editor,
use the following command:

```sh
  docker run \
           --name pingauthorizepap \
           --env PING_EXTERNAL_BASE_URL=my-pap-hostname:8443 \
           --env PING_POLICY_DB_SYNC=true \
           --env PING_DB_CONNECTION_STRING=jdbc:postgresql://example.com:5432/my_pap_db \
           --env PING_DB_ADMIN_USERNAME=pap_admin \
           --env PING_DB_ADMIN_PASSWORD=2FederateM0re \
           --env PING_DB_APP_USERNAME=pap_user \
           --env PING_DB_APP_PASSWORD=2FederateM0re \
           --publish 8443:1443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingauthorizepap:edge
```

Use the same command when a new pingauthorizepap release requires an upgrade to the policy
database schema.

Note that `PING_DB_ADMIN_PASSWORD` and `PING_DB_APP_PASSWORD` are only provided on the
command line for illustrative purposes and can instead be provided through a Vault or
through a `/run/secrets` `.env` file.


## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingauthorizepap/hooks/README.md) for details on all pingauthorizepap hook scripts

---
This document is auto-generated from _[pingauthorizepap/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingauthorizepap/Dockerfile)_

Copyright © 2026 Ping Identity Corporation
