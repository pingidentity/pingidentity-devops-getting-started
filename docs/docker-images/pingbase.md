
# Ping Identity Docker Image - `pingbase`

This docker image provides a base image for all Ping Identity DevOps
product images.  Primarly, the builder can provide an argument, `SHIM`,
that will be used to determine the base OS used when building.  The options
include:
- alpine (default)
- centos
- ubuntu

## Related Docker Images
- `openjdk:8-jre-alpine` - Parent Image for `SHIM=alpine`
- `centos` - Parent Image for `SHIM=cenots`
- `ubuntu:disco` - Parent Image for `SHIM=ubuntu`

## Environment Variables
The following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | -------
| BASE  | ${BASE:-/opt}  | Location of the top level directory where everything is located in image/container 
| IN_DIR  | ${BASE}/in  | Location of a local server-profile volume 
| OUT_DIR  | ${BASE}/out  | Path to the runtime volume 
| BAK_DIR  | ${BASE}/backup  | Path to a volume generically used to export or backup data 
| SECRETS_DIR  | /usr/local/secrets  | Default path to the secrets 
| STAGING_DIR  | ${BASE}/staging  | Path to the staging area where the remote and local server profiles can be merged 
| TOPOLOGY_FILE  | ${STAGING_DIR}/topology.json  | Path to the topology file 
| HOOKS_DIR  | ${STAGING_DIR}/hooks  | Path where all the hooks scripts are stored 
| SERVER_PROFILE_DIR  | /tmp/server-profile  | Path where the remote server profile is checked out or cloned before being staged prior to being applied on the runtime 
| SERVER_PROFILE_URL  |   | A valid git HTTPS URL (not ssh) 
| SERVER_PROFILE_BRANCH  |   | A valid git branch (optional) 
| SERVER_PROFILE_PATH  |   | The subdirectory in the git repo 
| SERVER_PROFILE_UPDATE  | false  | Whether to update the server profile upon container restart 
| SERVER_ROOT_DIR  | ${OUT_DIR}/instance  | Path from which the runtime executes 
| LICENSE_DIR  | ${SERVER_ROOT_DIR}  | License directory and filename 
| STARTUP_COMMAND  |   | The command that the entrypoint will execute in the foreground to instantiate the container 
| STARTUP_FOREGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container 
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container 
| TAIL_LOG_FILES  |   | A whitespace separated list of log files to tail to the container standard output 
| LOCATION  | Docker  | Location default value 
| MAX_HEAP_SIZE  | 384m  | Heap size (for java products) 
| JVM_TUNING  | AGGRESSIVE  | 
| VERBOSE  | false  | Triggers verbose messages in scripts using the set -x option. 
| PING_DEBUG  | false  | Set the server in debug mode, with increased output 
| PING_PRODUCT  |   | The name of Ping product.  Should be overridden by child images. 
| LDAP_PORT  | 389  | Port over which to communicate for LDAP 
| LDAPS_PORT  | 636  | Port over which to communicate for LDAPS 
| HTTPS_PORT  | 443  | Port over which to communicate for HTTPS 
| JMX_PORT  | 689  | Port for monitoring over JMX protocol 
| TOPOLOGY_SIZE  | 1  | 
| TOPOLOGY_PREFIX  |   | 
| TOPOLOGY_SUFFIX  |   | 
| USER_BASE_DN  | dc=example,dc=com  | 
| DOLLAR  | '$'  | 
| PD_ENGINE_PUBLIC_HOSTNAME  | localhost  | 
| PF_ENGINE_PUBLIC_HOSTNAME  | localhost  | 
| PF_ADMIN_PUBLIC_HOSTNAME  | localhost  | 
| PA_ENGINE_PUBLIC_HOSTNAME  | localhost  | 
| PA_ADMIN_PUBLIC_HOSTNAME  | localhost  | 
| ROOT_USER_DN  | cn=administrator  | the default administrative user for PingData 
| PATH  | ${BASE}:${SERVER_ROOT_DIR}/bin:${PATH}  | 
| PING_IDENTITY_EVAL_USER  | PingIdentityDevOpsEval  | 
| PING_IDENTITY_EVAL_KEY  | e30a780b-481b-46dc-a47e-ac26d9457221  | 

---
This document auto-generated from _[pingidentity/pingbase Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingbase/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
