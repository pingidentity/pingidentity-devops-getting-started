---
title: Ping Identity DevOps Docker Image - `pingfederate`
---

# Ping Identity DevOps Docker Image - `pingfederate`

This docker image includes the Ping Identity PingFederate product binaries
and associated hook scripts to create and run both PingFederate Admin and
Engine nodes.

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
> This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)
- `pingidentity/pingcommon` - Common Ping files (i.e. hook scripts)

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**,
the following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| BASE  | ${BASE:-/opt}  |  |
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
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| DATE  | ${DATE}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_PRODUCT  | PingFederate  | Ping product name  |
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/server/default/conf  | License directory  |
| LICENSE_FILE_NAME  | pingfederate.lic  | Name of license file  |
| LICENSE_SHORT_NAME  | PF  | Short name used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| PING_IDENTITY_PASSWORD  | 2FederateM0re  | Specify a password for administrator user for interaction with admin API  |
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/log/server.log  | Files tailed once container has started  |
| PF_LOG_SIZE_MAX  | 10000 KB  | Defines the log file size max for ALL appenders  |
| PF_LOG_NUMBER  | 2  | Defines the maximum of log files to retain upon rotation  |
| PF_LOG_LEVEL  | INFO  | General log level -- provide custom log4j2.xml in profile for more detailed control valid values are OFF, ERROR, WARN, INFO, DEBUG NOTE: PF_LOG_LEVEL only applies to PF versions before 11.2.0  |
| PF_ADMIN_PORT  | 9999  | Defines the port on which the PingFederate administrative console and API runs.  |
| PF_ENGINE_PORT  | 9031  | Defines the port on which PingFederate listens for encrypted HTTPS (SSL/TLS) traffic.  |
| PF_ENGINE_DEBUG  | false  | Flag to turn on PingFederate Engine debugging Used in run.sh  |
| PF_ADMIN_DEBUG  | false  | Flag to turn on PingFederate Admin debugging Used in run.sh  |
| PF_DEBUG_PORT  | 9030  | Defines the port on which PingFederate opens up a java debugging port. Used in run.sh  |
| SHOW_LIBS_VER  | true  | Defines a variable to allow showing library versions in the output at startup default to true  |
| SHOW_LIBS_VER_PRE_PATCH  | false  | Defines a variable to allow showing library version prior to patches being applied default to false This is helpful to ensure that the patch process updates all libraries affected  |
| OPERATIONAL_MODE  | STANDALONE  | Operational Mode Indicates the operational mode of the runtime server in run.properties Options include STANDALONE, CLUSTERED_CONSOLE, CLUSTERED_ENGINE.  |
| PF_CONSOLE_AUTHENTICATION  |   | Defines mechanism for console authentication in run.properties. Options include none, native, LDAP, cert, RADIUS, OIDC. If not set, default is native.  |
| PF_ADMIN_API_AUTHENTICATION  |   | Defines mechanism for admin api authentication in run.properties. Options include none, native, LDAP, cert, RADIUS, OIDC. If not set, default is native.  |
| HSM_MODE  | OFF  | Hardware Security Module Mode in run.properties Options include OFF, AWSCLOUDHSM, NCIPHER, LUNA, BCFIPS.  |
| PF_BC_FIPS_APPROVED_ONLY  | false  | Defines a variable that allows instantiating non-FIPS crypto/random  |
| PF_HSM_HYBRID  | false  | Hardware Security Module Hybrid Mode   When PF is in Hybrid mode, certs/keys can be created either on the local trust store or on the HSM.   This can used as a migration strategy towards an HSM setup.  |
| PF_LDAP_USERNAME  |   | This is the username for an account within the LDAP Directory Server that can be used to perform user lookups for authentication and other user level search operations.  Set if PF_CONSOLE_AUTHENTICATION or PF_ADMIN_API_AUTHENTICATION=LDAP  |
| PF_LDAP_PASSWORD  |   | This is the password for the Username specified above. This property should be obfuscated using the 'obfuscate.sh' utility. Set if PF_CONSOLE_AUTHENTICATION or PF_ADMIN_API_AUTHENTICATION=LDAP  |
| CLUSTER_BIND_ADDRESS  | NON_LOOPBACK  | IP address for cluster communication.  Set to NON_LOOPBACK to allow the system to choose an available non-loopback IP address.  |
| PF_PROVISIONER_MODE  | OFF  | Provisioner Mode in run.properties Options include OFF, STANDALONE, FAILOVER.  |
| PF_PROVISIONER_NODE_ID  | 1  | Provisioner Node ID in run.properties Initial active provisioning server node ID is 1  |
| PF_PROVISIONER_GRACE_PERIOD  | 600  | Provisioner Failover Grace Period in run.properties Grace period, in seconds. Default 600 seconds  |
| PF_JETTY_THREADS_MIN  |   | Override the default value for the minimum size of the Jetty thread pool Leave unset to let the container automatically tune the value according to available resources  |
| PF_JETTY_THREADS_MAX  |   | Override the default value for the maximum size of the Jetty thread pool Leave unset to let the container automatically tune the value according to available resources  |
| PF_ACCEPT_QUEUE_SIZE  | 512  | The size of the accept queue. There is generally no reason to tune this but please refer to the performance tuning guide for further tuning guidance.  |
| PF_PINGONE_REGION  |   | The region of the PingOne tenant PingFederate should connect with. Valid values are "com", "eu" and "asia"  |
| PF_PINGONE_ENV_ID  |   | The PingOne environment ID to use  |
| PF_CONSOLE_TITLE  | Docker PingFederate  | The title featured in the administration console -- this is generally used to easily distinguish between environments  |
| PF_NODE_TAGS  |   | This property defines the tags associated with this PingFederate node. Configuration is optional. When configured, PingFederate takes this property into consideration when processing requests. For example, tags may be used to determine the data store location that this PingFederate node communicates with. Administrators may also use tags in conjunction with authentication selectors and policies to define authentication requirements.  Administrators may define one tag or a list of space-separated tags. Each tag cannot contain any spaces. Other characters are allowed.  Example 1: PF_NODE_TAGS=north Example 1 defines one tag: 'north' Example 2: PF_NODE_TAGS=1 123 test Example 2 defines three tags: '1', '123' and 'test'  Example 3: PF_NODE_TAGS= Example 3 is also valid because the PF_NODE_TAGS property is optional.  |
| PF_CONSOLE_ENV  |   | This property defines the name of the PingFederate environment that will be displayed in the administrative console, used to make separate environments easily identifiable.  |
| JAVA_RAM_PERCENTAGE  | 75.0  | Percentage of the container memory to allocate to PingFederate JVM DO NOT set to 100% or your JVM will exit with OutOfMemory errors and the container will terminate  |
| BULK_CONFIG_DIR  | ${OUT_DIR}/instance/bulk-config  |  |
| BULK_CONFIG_FILE  | data.json  |  |
| ADMIN_WAITFOR_TIMEOUT  | 300  | wait-for timeout for 80-post-start.sh hook script How long to wait for the PF Admin console to be available  |

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
This document is auto-generated from _[pingfederate/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingfederate/Dockerfile)_

Copyright © 2023 Ping Identity Corporation. All rights reserved.
