# PingBase

This docker image provides a base image for all Ping Identity DevOps product images. Primarly, the builder can provide an argument, `SHIM`, that will be used to determine the base OS used when building. The options include:

* alpine \(default\)
* centos
* ubuntu

## Related Docker Images

* `openjdk:8-jre-alpine` - Parent Image for `SHIM=alpine`
* `centos` - Parent Image for `SHIM=cenots`
* `ubuntu:disco` - Parent Image for `SHIM=ubuntu`

## Environment Variables

The following environment `ENV` variables can be used with this image.

| ENV Variable | Default | Description |
| ---: | :--- | :--- |
| BASE | ${BASE:-/opt} | Location of the top level directory where everything is located in  image/container |
| IN\_DIR | ${BASE}/in | Location of a local server-profile volume |
| OUT\_DIR | ${BASE}/out | Path to the runtime volume |
| BAK\_DIR | ${BASE}/backup | Path to a volume generically used to export or backup data |
| SECRETS\_DIR | /usr/local/secrets | Default path to the secrets |
| STAGING\_DIR | ${BASE}/staging | Path to the staging area where the remote and local server profiles can be merged |
| TOPOLOGY\_FILE | ${STAGING\_DIR}/topology.json | Path to the topology file |
| HOOKS\_DIR | ${STAGING\_DIR}/hooks | Path where all the hooks scripts are stored |
| SERVER\_PROFILE\_DIR | /tmp/server-profile | Path where the remote server profile is checked out or cloned before being staged prior to being applied on the runtime |
| SERVER\_PROFILE\_URL |  | A valid git HTTPS URL \(not ssh\) |
| SERVER\_PROFILE\_BRANCH |  | A valid git branch \(optional\) |
| SERVER\_PROFILE\_PATH |  | The subdirectory in the git repo |
| SERVER\_PROFILE\_UPDATE | false | Whether to update the server profile upon container restart |
| SERVER\_ROOT\_DIR | ${OUT\_DIR}/instance | Path from which the runtime executes |
| LICENSE\_DIR | ${SERVER\_ROOT\_DIR} | License directory and filename |
| STARTUP\_COMMAND |  | The command that the entrypoint will execute in the foreground to  instantiate the container |
| STARTUP\_FOREGROUND\_OPTS |  | The command-line options to provide to the the startup command when  the container starts with the server in the foreground. This is the  normal start flow for the container |
| STARTUP\_BACKGROUND\_OPTS |  | The command-line options to provide to the the startup command when  the container starts with the server in the background. This is the  debug start flow for the container |
| TAIL\_LOG\_FILES |  | A whitespace separated list of log files to tail to the container  standard output |
| LOCATION | Docker | Location default value |
| MAX\_HEAP\_SIZE | 384m | Heap size \(for java products\) |
| JVM\_TUNING | AGGRESSIVE |  |
| VERBOSE | false | Triggers verbose messages in scripts using the set -x option. |
| PING\_DEBUG | false | Set the server in debug mode, with increased output |
| PING\_PRODUCT |  | The name of Ping product.  Should be overridden by child images. |
| LDAP\_PORT | 389 | Port over which to communicate for LDAP |
| LDAPS\_PORT | 636 | Port over which to communicate for LDAPS |
| HTTPS\_PORT | 443 | Port over which to communicate for HTTPS |
| JMX\_PORT | 689 | Port for monitoring over JMX protocol |
| TOPOLOGY\_SIZE | 1 |  |
| TOPOLOGY\_PREFIX |  |  |
| TOPOLOGY\_SUFFIX |  |  |
| USER\_BASE\_DN | dc=example,dc=com |  |
| DOLLAR | '$' |  |
| PD\_ENGINE\_PUBLIC\_HOSTNAME | localhost |  |
| PF\_ENGINE\_PUBLIC\_HOSTNAME | localhost |  |
| PF\_ADMIN\_PUBLIC\_HOSTNAME | localhost |  |
| PA\_ENGINE\_PUBLIC\_HOSTNAME | localhost |  |
| PA\_ADMIN\_PUBLIC\_HOSTNAME | localhost |  |
| ROOT\_USER\_DN | cn=administrator | the default administrative user for PingData |
| PATH | ${BASE}:${SERVER\_ROOT\_DIR}/bin:${PATH} |  |
| PING\_IDENTITY\_EVAL\_USER | PingIdentityDevOpsEval |  |
| PING\_IDENTITY\_EVAL\_KEY | e30a780b-481b-46dc-a47e-ac26d9457221 |  |

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingbase/hooks/README.md) for details on all pingbase hook scripts

This document auto-generated from [_pingbase/Dockerfile_](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingbase/Dockerfile)

Copyright \(c\) 2019 Ping Identity Corporation. All rights reserved.

