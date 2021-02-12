
# Ping Identity DevOps Docker Image - `pingfederate`

This docker image includes the Ping Identity PingFederate product binaries
and associated hook scripts to create and run both PingFederate Admin and
Engine nodes.

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
	>**This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**
- `pingidentity/pingcommon` - Common Ping files (i.e. hook scripts)
- `pingidentity/pingdownloader` - Used to download product bits

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**,
the following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |
| PING_PRODUCT  | PingFederate  |
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/server/default/conf  |
| LICENSE_FILE_NAME  | pingfederate.lic  |
| LICENSE_SHORT_NAME  | PF  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/log/server.log  |
| PF_LOG_SIZE_MAX  | 10000 KB  | Defines the log file size max for ALL appenders
| PF_LOG_NUMBER  | 2  | Defines the maximum of log files to retain upon rotation
| PF_ADMIN_PORT  | 9999  | Defines the port on which the PingFederate administrative console and API runs.
| PF_ENGINE_PORT  | 9031  | Defines the port on which PingFederate listens for encrypted HTTPS (SSL/TLS) traffic.
| PF_ENGINE_DEBUG  | false  | Flag to turn on PingFederate Engine debugging Used in run.sh
| PF_ADMIN_DEBUG  | false  | Flag to turn on PingFederate Admin debugging Used in run.sh
| PF_DEBUG_PORT  | 9030  | Defines the port on which PingFederate opens up a java debugging port. Used in run.sh
| OPERATIONAL_MODE  | STANDALONE  | Operational Mode Indicates the operational mode of the runtime server in run.properties Options include STANDALONE, CLUSTERED_CONSOLE, CLUSTERED_ENGINE.
| PF_CONSOLE_AUTHENTICATION  |   | Defines mechamism for console authentication in run.properties. Options include none, native, LDAP, cert, RADIUS, OIDC. If not set, default is native.
| PF_ADMIN_API_AUTHENTICATION  |   | Defines mechamism for admin api authentication in run.properties. Options include none, native, LDAP, cert, RADIUS, OIDC. If not set, default is native.
| HSM_MODE  | OFF  | Hardware Security Module Mode in run.properties Options include OFF, AWSCLOUDHSM, NCIPHER, LUNA, BCFIPS.
| PF_LDAP_USERNAME  | cn=pingfederate  | This is the username for an account within the LDAP Directory Server that can be used to perform user lookups for authentication and other user level search operations.  Set if PF_CONSOLE_AUTHENTICATION or PF_ADMIN_API_AUTHENTICATION=LDAP
| PF_LDAP_PASSWORD  | OBF:JWE:eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2Iiwia2lkIjoiRW1JY1UxOVdueSIsInZlcnNpb24iOiI5LjIuMS4xIn0..euBO0bawJz3XC_plAjxECg.yF7BpnCTPZlpZUo21WQ5IQ.YlLtlJTxXhrp3LsxyQDo5g  | This is the password for the Username specified above. This property should be obfuscated using the 'obfuscate.sh' utility. Set if PF_CONSOLE_AUTHENTICATION or PF_ADMIN_API_AUTHENTICATION=LDAP
| CLUSTER_BIND_ADDRESS  | NON_LOOPBACK  | IP address for cluster communication.  Set to NON_LOOPBACK to allow the system to choose an available non-loopback IP address.
| BULK_CONFIG_DIR  | ${OUT_DIR}/instance/bulk-config  |
| BULK_CONFIG_FILE  | data.json  |
## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- 9031
- 9999

## Running a PingFederate container
To run a PingFederate container:

```shell
  docker run \
           --name pingfederate \
           --publish 9999:9999 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingfederate \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingfederate:edge
```

Follow Docker logs with:

```
docker logs -f pingfederate
```

If using the command above with the embedded [server profile](https://devops.pingidentity.com/reference/config/), log in with:
* https://localhost:9999/pingfederate/app
  * Username: Administrator
  * Password: 2FederateM0re
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingfederate/hooks/README.md) for details on all pingfederate hook scripts

---
This document auto-generated from _[pingfederate/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingfederate/Dockerfile)_

Copyright (c) 2021 Ping Identity Corporation. All rights reserved.
