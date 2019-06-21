
# Ping Identity DevOps Docker Image - `pingdirectoryproxy`

This docker image includes the Ping Identity PingDirectoryProxy product binaries
and associated hook scripts to create and run a PingDirectoryProxy instance or 
instances.

## Related Docker Images
- pingidentity/pingbase - Parent Image
- pingidentity/pingdatacommon - Common PingData files (i.e. hook scripts)
- pingidentity/pingdownloader - Used to download product bits

## Environment Variables
The following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| LICENSE_FILE_NAME  | PingDirectory.lic  | 
| LICENSE_SHORT_NAME  | PD  | 
| LICENSE_VERSION  | 7.3  | 
| REPLICATION_PORT  | 8989  | 
| PING_PRODUCT  | PingDirectoryProxy  | 
| ADMIN_USER_NAME  | admin  | 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start-server  | 
| STARTUP_FOREGROUND_OPTS  | --nodetach  | 
| ROOT_USER_PASSWORD_FILE  | ${SECRETS_DIR}/root-user-password  | 
| ADMIN_USER_PASSWORD_FILE  | ${SECRETS_DIR}/admin-user-password  | 
| ENCRYPTION_PASSWORD_FILE  | ${SECRETS_DIR}/encryption-password  | 
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/logs/access  | 
| MAKELDIF_USERS  | 0  | 
## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- ${LDAP_PORT}
- ${LDAPS_PORT}
- ${HTTPS_PORT}
- ${JMX_PORT}
- 5005

## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdirectoryproxy/hooks/README.md) for details on all pingdirectoryproxy hook scripts

---
This document auto-generated from _[pingdirectoryproxy/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectoryproxy/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
