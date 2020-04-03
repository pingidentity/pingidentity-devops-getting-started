
# Ping Identity Docker Image - `pingbase`

This docker image provides a base image for all Ping Identity DevOps
product images.

## Environment Variables
The following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| IMAGE_VERSION  | ${IMAGE_VERSION}  | Image version, set by build process of the docker build 
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  | Image git revision, set by build process of the docker build 
| ACCEPT_EULA  | NO  | Must be set to 'YES' for the container to start 
| BASE  | ${BASE:-/opt}  | Location of the top level directory where everything is located in image/container 
| IN_DIR  | ${BASE}/in  | Location of a local server-profile volume 
| OUT_DIR  | ${BASE}/out  | Path to the runtime volume 
| SERVER_BITS_DIR  | ${BASE}/server  | Path to the server bits 
| BAK_DIR  | ${BASE}/backup  | Path to a volume generically used to export or backup data 
| LOGS_DIR  | ${BASE}/logs  | Path to a volume generically used for logging 
| SECRETS_DIR  | /usr/local/secrets  | Default path to the secrets 
| PING_IDENTITY_DEVOPS_FILE  | devops-secret  | File name for devops-creds passed as a Docker secret 
| STAGING_DIR  | ${BASE}/staging  | Path to the staging area where the remote and local server profiles can be merged 
| TOPOLOGY_FILE  | ${STAGING_DIR}/topology.json  | Path to the topology file 
| HOOKS_DIR  | ${STAGING_DIR}/hooks  | Path where all the hooks scripts are stored 
| SERVER_PROFILE_DIR  | /tmp/server-profile  | Path where the remote server profile is checked out or cloned before being staged prior to being applied on the runtime 
| SERVER_PROFILE_URL  |   | A valid git HTTPS URL (not ssh) 
| SERVER_PROFILE_URL_REDACT  | true  | 
| SERVER_PROFILE_BRANCH  |   | A valid git branch (optional) 
| SERVER_PROFILE_PATH  |   | The subdirectory in the git repo 
| SERVER_PROFILE_UPDATE  | false  | Whether to update the server profile upon container restart 
| SERVER_ROOT_DIR  | ${OUT_DIR}/instance  | Path from which the runtime executes 
| SECURITY_CHECKS_STRICT  | false  | Requires strict checks on security 
| SECURITY_CHECKS_FILENAME  | *.jwk *.pin  | Perform a check for filenames that may violate security (i.e. secret material) 
| LICENSE_DIR  | ${SERVER_ROOT_DIR}  | License directory and filename 
| STARTUP_COMMAND  |   | The command that the entrypoint will execute in the foreground to instantiate the container 
| STARTUP_FOREGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container 
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container 
| PING_IDENTITY_DEVOPS_KEY_REDACT  | true  | 
| TAIL_LOG_FILES  |   | A whitespace separated list of log files to tail to the container standard output 
| COLORIZE_LOGS  | true  | If 'true', the output logs will be colorized with GREENs and REDs, otherwise, no colorization will be done.  This is good for tools that monitor logs and colorization gets in the way. 
| LOCATION  | Docker  | Location default value 
| LOCATION_VALIDATION  | true|Any string denoting a logical/physical location|Must be a string  | 
| MAX_HEAP_SIZE  | 384m  | Heap size (for java products) 
| JVM_TUNING  | AGGRESSIVE  | 
| VERBOSE  | false  | Triggers verbose messages in scripts using the set -x option. 
| PING_DEBUG  | false  | Set the server in debug mode, with increased output 
| PING_PRODUCT  |   | The name of Ping product.  Should be overridden by child images. 
| PING_PRODUCT_VALIDATION  | true|i.e. PingFederate,PingDirectory|Must be a valid Ping prouduct type  | 
| LDAP_PORT  | 389  | Port over which to communicate for LDAP 
| LDAPS_PORT  | 636  | Port over which to communicate for LDAPS 
| HTTPS_PORT  | 443  | Port over which to communicate for HTTPS 
| JMX_PORT  | 689  | Port for monitoring over JMX protocol 
| ORCHESTRATION_TYPE  |   | The type of orchestration tool used to run the container, normally set in the deployment (.yaml) file.  Expected values include: - compose - swarm - kubernetes Defaults to blank (i.e. No type is set) 
| USER_BASE_DN  | dc=example,dc=com  | 
| DOLLAR  | '$'  | 
| PD_ENGINE_PUBLIC_HOSTNAME  | localhost  | PD (PingDirectory) public hostname that may be used in redirects 
| PD_ENGINE_PRIVATE_HOSTNAME  | pingdirectory  | PD (PingDirectory) private hostname 
| PDP_ENGINE_PUBLIC_HOSTNAME  | localhost  | PDP (PingDirectoryProxy) public hostname that may be used in redirects 
| PDP_ENGINE_PRIVATE_HOSTNAME  | pingdirectoryproxy  | PDP (PingDirectoryProxy) private hostname 
| PDS_ENGINE_PUBLIC_HOSTNAME  | localhost  | PDS (PingDataSync) public hostname that may be used in redirects 
| PDS_ENGINE_PRIVATE_HOSTNAME  | pingdatasync  | PDS (PingDataSync) private hostname 
| PDG_ENGINE_PUBLIC_HOSTNAME  | localhost  | PDG (PingDataGovernance) public hostname that may be used in redirects 
| PDG_ENGINE_PRIVATE_HOSTNAME  | pingdatagovernance  | PDG (PingDataGovernance) private hostname 
| PDGP_ENGINE_PUBLIC_HOSTNAME  | localhost  | PDGP (PingDataGovernance-PAP) public hostname that may be used in redirects 
| PDGP_ENGINE_PRIVATE_HOSTNAME  | pingdatagovernancepap  | PDGP (PingDataGovernance-PAP) private hostname 
| PF_ENGINE_PUBLIC_HOSTNAME  | localhost  | PF (PingFederate) engine public hostname that may be used in redirects 
| PF_ENGINE_PRIVATE_HOSTNAME  | pingfederate  | PF (PingFederate) engine private hostname 
| PF_ADMIN_PUBLIC_HOSTNAME  | localhost  | PF (PingFederate) admin public hostname that may be used in redirects 
| PF_ADMIN_PRIVATE_HOSTNAME  | pingfederate-admin  | PF (PingFederate) admin private hostname 
| PA_ENGINE_PUBLIC_HOSTNAME  | localhost  | PA (PingAccess) engine prublic hostname that may be used in redirects 
| PA_ENGINE_PRIVATE_HOSTNAME  | pingaccess  | PA (PingAccess) engine private hostname 
| PA_ADMIN_PUBLIC_HOSTNAME  | localhost  | PA (PingAccess) admin public hostname that may be used in redirects 
| PA_ADMIN_PRIVATE_HOSTNAME  | pingaccess-admin  | PA (PingAccess) admin private hostname 
| ROOT_USER  | administrator  | the default administrative user for PingData 
| ROOT_USER_DN  | cn=${ROOT_USER}  | 
| ENV  | ${BASE}/.profile  | 
| MOTD_URL  | https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/motd/motd.json  | Instructs the image to pull the MOTD json from the followig URL. If this MOTD_URL variable is empty, then no motd will be downloaded. The format of this MOTD file must match the example provided in the url: https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/motd/motd.json 
| PS1  | \${PING_PRODUCT}:\h:\w\n>   | Default shell prompt (i.e. productName:hostname:workingDir) 
| PING_CONTAINER_PRIVILEGED  | true  | Whether to run the process as Root or not if set to false, user spec can be left to default (uid:9031, gid:9999) or a custom uid can be passed with PING_CONTAINER_UID and PING_CONTAINER_GID 
| PING_CONTAINER_UID  | 9031  | The user ID the product will use if PING_CONTAINER_PRIVILEGED is set to false 
| PING_CONTAINER_GID  | 9999  | The group ID the product will use if PING_CONTAINER_PRIVILEGED is set to false 
| PING_CONTAINER_UNAME  | ping  | The user name the product will use if PING_CONTAINER_PRIVILEGED is set to false and a user with that ID does not exist already 
| PING_CONTAINER_GNAME  | identity  | The group name the product will use if PING_CONTAINER_PRIVILEGED is set to false and a group with that ID does not exist already 
| JAVA_HOME  | /opt/java  | 
| PATH  | ${JAVA_HOME}/bin:${BASE}:${SERVER_ROOT_DIR}/bin:${PATH}  | 
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingbase/hooks/README.md) for details on all pingbase hook scripts

---
This document auto-generated from _[pingbase/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingbase/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
