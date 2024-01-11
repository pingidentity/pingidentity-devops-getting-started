---
title: Ping Identity DevOps Docker Image - `pingbase`
---

# Ping Identity Docker Image - `pingbase`

This docker image provides a base image for all Ping Identity DevOps
product images.

## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| BASE  | ${BASE:-/opt}  | Location of the top level directory where everything is located in image/container  |
| ROOT_USER  | administrator  | the default administrative user for PingData  |
| JAVA_HOME  | /opt/java  |  |
| STAGING_DIR  | ${BASE}/staging  | Path to the staging area where the remote and local server profiles can be merged  |
| OUT_DIR  | ${BASE}/out  | Path to the runtime volume  |
| SERVER_ROOT_DIR  | ${OUT_DIR}/instance  | Path from which the runtime executes  |
| IN_DIR  | ${BASE}/in  | Location of a local server-profile volume  |
| SERVER_BITS_DIR  | ${BASE}/server  | Path to the server bits  |
| BAK_DIR  | ${BASE}/backup  | Path to a volume generically used to export or backup data  |
| LOGS_DIR  | ${BASE}/logs  | Path to a volume generically used for logging  |
| PING_IDENTITY_ACCEPT_EULA  | NO  | Must be set to 'YES' for the container to start  |
| PING_IDENTITY_DEVOPS_FILE  | devops-secret  | File name for devops-creds passed as a Docker secret  |
| STAGING_MANIFEST  | ${BASE}/staging-manifest.txt  | Path to a manifest of files expected in the staging dir on first image startup  |
| CLEAN_STAGING_DIR  | false  | Whether to clean the staging dir when the image starts  |
| SECRETS_DIR  | /run/secrets  | Default path to the secrets  |
| TOPOLOGY_FILE  | ${STAGING_DIR}/topology.json  | Path to the topology file  |
| HOOKS_DIR  | ${STAGING_DIR}/hooks  | Path where all the hooks scripts are stored  |
| CONTAINER_ENV  | ${STAGING_DIR}/.env  | Environment Property file use to share variables between scripts in container  |
| SERVER_PROFILE_DIR  | /tmp/server-profile  | Path where the remote server profile is checked out or cloned before being staged prior to being applied on the runtime  |
| SERVER_PROFILE_URL  |   | A valid git HTTPS URL (not ssh)  |
| SERVER_PROFILE_URL_REDACT  | true  | When set to "true", the server profile git URL will not be printed to container output.  |
| SERVER_PROFILE_BRANCH  |   | A valid git branch (optional)  |
| SERVER_PROFILE_PATH  |   | The subdirectory in the git repo  |
| SERVER_PROFILE_UPDATE  | false  | Whether to update the server profile upon container restart  |
| SECURITY_CHECKS_STRICT  | false  | Requires strict checks on security  |
| SECURITY_CHECKS_FILENAME  | *.jwk *.pin  | Perform a check for filenames that may violate security (i.e. secret material)  |
| UNSAFE_CONTINUE_ON_ERROR  |   | If this is set to true, then the container will provide a hard warning and continue.  |
| LICENSE_DIR  | ${SERVER_ROOT_DIR}  | License directory  |
| PD_LICENSE_DIR  | ${STAGING_DIR}/pd.profile/server-root/pre-setup  | PD License directory. Separating from above LICENSE_DIR to differentiate for different products  |
| STARTUP_COMMAND  |   | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| PING_IDENTITY_DEVOPS_KEY_REDACT  | true  |  |
| TAIL_LOG_FILES  |   | A whitespace separated list of log files to tail to the container standard output - DO NOT USE WILDCARDS like /path/to/logs/*.log  |
| COLORIZE_LOGS  | true  | If 'true', the output logs will be colorized with GREENs and REDs, otherwise, no colorization will be done.  This is good for tools that monitor logs and colorization gets in the way.  |
| LOCATION  | Docker  | Location default value If PingDirectory is deployed in multi cluster mode, that is, K8S_CLUSTER, K8S_CLUSTERS and K8S_SEED_CLUSTER are defined, LOCATION is ignored and K8S_CLUSTER is used as the location  |
| LOCATION_VALIDATION  | true|Any string denoting a logical/physical location|Must be a string  |  |
| MAX_HEAP_SIZE  | 384m  | Heap size (for java products)  |
| JVM_TUNING  | AGGRESSIVE  |  |
| JAVA_RAM_PERCENTAGE  | 75.0  | Percentage of the container memory to allocate to PingFederate JVM DO NOT set to 100% or your JVM will exit with OutOfMemory errors and the container will terminate  |
| VERBOSE  | false  | Triggers verbose messages in scripts using the set -x option.  |
| PING_DEBUG  | false  | Set the server in debug mode, with increased output  |
| PING_PRODUCT  |   | The name of Ping product, i.e. PingFederate, PingDirectory - must be a valid Ping product type. This variable should be overridden by child images.  |
| PING_PRODUCT_VALIDATION  | true|i.e. PingFederate,PingDirectory|Must be a valid Ping product type  |  |
| ADDITIONAL_SETUP_ARGS  |   | List of setup arguments passed to Ping Data setup-arguments.txt file  |
| LDAP_PORT  | 1389  | Port over which to communicate for LDAP  |
| LDAPS_PORT  | 1636  | Port over which to communicate for LDAPS  |
| HTTPS_PORT  | 1443  | Port over which to communicate for HTTPS  |
| JMX_PORT  | 1689  | Port for monitoring over JMX protocol  |
| ORCHESTRATION_TYPE  |   | The type of orchestration tool used to run the container, normally set in the deployment (.yaml) file.  Expected values include: - compose - swarm - kubernetes Defaults to blank (i.e. No type is set)  |
| USER_BASE_DN  | dc=example,dc=com  | Base DN for user data  |
| DOLLAR  | '$'  | Variable with a literal value of '$', to avoid unwanted variable substitution  |
| PD_ENGINE_PUBLIC_HOSTNAME  | localhost  | PD (PingDirectory) public hostname that may be used in redirects  |
| PD_ENGINE_PRIVATE_HOSTNAME  | pingdirectory  | PD (PingDirectory) private hostname  |
| PDP_ENGINE_PUBLIC_HOSTNAME  | localhost  | PDP (PingDirectoryProxy) public hostname that may be used in redirects  |
| PDP_ENGINE_PRIVATE_HOSTNAME  | pingdirectoryproxy  | PDP (PingDirectoryProxy) private hostname  |
| PDS_ENGINE_PUBLIC_HOSTNAME  | localhost  | PDS (PingDataSync) public hostname that may be used in redirects  |
| PDS_ENGINE_PRIVATE_HOSTNAME  | pingdatasync  | PDS (PingDataSync) private hostname  |
| PAZ_ENGINE_PUBLIC_HOSTNAME  | localhost  | PAZ (PingAuthorize) public hostname that may be used in redirects  |
| PAZ_ENGINE_PRIVATE_HOSTNAME  | pingauthorize  | PAZ (PingAuthorize) private hostname  |
| PAZP_ENGINE_PUBLIC_HOSTNAME  | localhost  | PAZP (PingAuthorize-PAP) public hostname that may be used in redirects  |
| PAZP_ENGINE_PRIVATE_HOSTNAME  | pingauthorizepap  | PAZP (PingAuthorize-PAP) private hostname  |
| PF_ENGINE_PUBLIC_HOSTNAME  | localhost  | PF (PingFederate) engine public hostname that may be used in redirects  |
| PF_ENGINE_PRIVATE_HOSTNAME  | pingfederate  | PF (PingFederate) engine private hostname  |
| PF_ADMIN_PUBLIC_BASEURL  | https://localhost:9999  | PF (PingFederate) admin public baseurl that may be used in redirects  |
| PF_ADMIN_PUBLIC_HOSTNAME  | localhost  | PF (PingFederate) admin public hostname that may be used in redirects  |
| PF_ADMIN_PRIVATE_HOSTNAME  | pingfederate-admin  | PF (PingFederate) admin private hostname  |
| PA_ENGINE_PUBLIC_HOSTNAME  | localhost  | PA (PingAccess) engine public hostname that may be used in redirects  |
| PA_ENGINE_PRIVATE_HOSTNAME  | pingaccess  | PA (PingAccess) engine private hostname  |
| PA_ADMIN_PUBLIC_HOSTNAME  | localhost  | PA (PingAccess) admin public hostname that may be used in redirects  |
| PA_ADMIN_PRIVATE_HOSTNAME  | pingaccess-admin  | PA (PingAccess) admin private hostname  |
| ROOT_USER_DN  | cn=${ROOT_USER}  | DN of the server root user  |
| ENV  | ${BASE}/.profile  |  |
| MOTD_URL  | https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/motd/motd.json  | Instructs the image to pull the MOTD json from the following URL. If this MOTD_URL variable is empty, then no motd will be downloaded. The format of this MOTD file must match the example provided in the url: https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/motd/motd.json  |
| PS1  | \${PING_PRODUCT}:\h:\w\n>   | Default shell prompt (i.e. productName:hostname:workingDir)  |
| PATH  | ${JAVA_HOME}/bin:${BASE}:${SERVER_ROOT_DIR}/bin:${PATH}  | PATH used by the container  |

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingbase/hooks/README.md) for details on all pingbase hook scripts

---
This document is auto-generated from _[pingbase/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingbase/Dockerfile)_

Copyright © 2024 Ping Identity Corporation. All rights reserved.
