
# Ping Identity DevOps Docker Image - `pingintelligence-ase`

This docker image includes the Ping Identity PingIntelligence API Security Enforcer product binaries
and associated hook scripts to create and run PingIntelligence ASE instances.

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
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| PING_PRODUCT  | PingIntelligence_ASE  | Ping product name  |
| LICENSE_FILE_NAME  | PingIntelligence.lic  | Name of license File  |
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/config  | License directory  |
| LICENSE_SHORT_NAME  | pingintelligence  | Shortname used when retrieving license from License Server  |
| LICENSE_VERSION  | ${LICENSE_VERSION}  | Version used when retrieving license from License Server  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/start_ase.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  |   | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |
| ROOT_USER_PASSWORD_FILE  |   |  |
| ADMIN_USER_PASSWORD_FILE  |   |  |
| ENCRYPTION_PASSWORD_FILE  |   |  |
| PING_INTELLIGENCE_ADMIN_USER  | admin  | PingIntelligence global variables PingIntelligence default administrative user (this should probably not be changed)  |
| PING_INTELLIGENCE_ADMIN_PASSWORD  | 2FederateM0re  | PingIntelligence default administrative user credentials (this should be changed)  |
| PING_INTELLIGENCE_ASE_HTTP_PORT  | 8000  | The ASE HTTP listener port  |
| PING_INTELLIGENCE_ASE_HTTPS_PORT  | 8443  | The ASE HTTPS listener port  |
| PING_INTELLIGENCE_ASE_MGMT_PORT  | 8010  | the ASE management port  |
| PING_INTELLIGENCE_ASE_TIMEZONE  | local  | The timezone the ASE container is operating in  |
| PING_INTELLIGENCE_ASE_MODE  | inline  | Defines running mode for API Security Enforcer (Allowed values are inline or sideband).  |
| PING_INTELLIGENCE_ASE_ENABLE_SIDEBAND_AUTHENTICATION  | false  | Enable client-side authentication with tokens in sideband mode  |
| PING_INTELLIGENCE_ASE_HOSTNAME_REWRITE  | false  |  |
| PING_INTELLIGENCE_ASE_KEYSTORE_PASSWORD  | OBF:AES:sRNp0W7sSi1zrReXeHodKQ:lXcvbBhKZgDTrjQOfOkzR2mpca4bTUcwPAuerMPwvM4  |  |
| PING_INTELLIGENCE_ASE_ADMIN_LOG_LEVEL  | 4  | For controller.log and balancer.log only 1-5 (FATAL, ERROR, WARNING, INFO, DEBUG)  |
| PING_INTELLIGENCE_ASE_ENABLE_CLUSTER  | false  | enable cluster  |
| PING_INTELLIGENCE_ASE_SYSLOG_SERVER  |   | Syslog server  |
| PING_INTELLIGENCE_ASE_CA_CERT_PATH  |   | Path the to CA certificate  |
| PING_INTELLIGENCE_ASE_ENABLE_HEALTH  | false  | enable the ASE health check service  |
| PING_INTELLIGENCE_ASE_ENABLE_ABS  | false  | Set this value to true, to allow API Security Enforcer to send logs to ABS.  |
| PING_INTELLIGENCE_ASE_ENABLE_ABS_ATTACK_LIST_RETRIEVAL  | false  | Toggle ABS attack list retrieval  |
| PING_INTELLIGENCE_ASE_BLOCK_AUTODETECTED_ATTACKS  | false  | Toggle whether ASE blocks auto-detected attacks  |
| PING_INTELLIGENCE_ASE_ATTACK_LIST_REFRESH_MINUTES  | 10  | ABS attack list retieval frequency in minutes  |
| PING_INTELLIGENCE_ASE_HOSTNAME_REFRESH_SECONDS  | 60  | Hostname refresh interval in seconds  |
| PING_INTELLIGENCE_ASE_DECOY_ALERT_INTERVAL_MINUTES  | 180  | Alert interval for teh decoy services  |
| PING_INTELLIGENCE_ASE_ENABLE_XFOWARDED_FOR  | false  | Toggle X-Forwarded-For  |
| PING_INTELLIGENCE_ASE_ENABLE_FIREWALL  | true  | Toggle ASE Firewall  |
| PING_INTELLIGENCE_ASE_ENABLE_SIDEBAND_KEEPALIVE  | false  | Enable connection keepalive for requests from gateway to ASE in sideband mode When enabled, ASE sends 'Connection: keep-alive' header in response When disabled, ASE sends 'Connection: close' header in response  |
| PING_INTELLIGENCE_ASE_ENABLE_GOOGLE_PUBSUB  | false  | Enable Google Pub/Sub  |
| PING_INTELLIGENCE_ASE_ENABLE_ACCESS_LOG  | true  | Toggle the access log  |
| PING_INTELLIGENCE_ASE_ENABLE_AUDIT  | false  | Toggle audit logging  |
| PING_INTELLIGENCE_ASE_FLUSH_LOG_IMMEDIATELY  | true  | Toggle whether logs are flushed to disk immediately  |
| PING_INTELLIGENCE_ASE_HTTP_PROCESS  | 1  | The number of processes for HTTP requests  |
| PING_INTELLIGENCE_ASE_HTTPS_PROCESS  | 1  | The number of processes for HTTPS requests  |
| PING_INTELLIGENCE_ASE_ENABLE_SSL_V3  | false  | Toggle SSLv3 -- this should absolutely stay disabled  |
| PING_INTELLIGENCE_ASE_GOOGLE_PUBSUB_TOPIC  | /topic/apimetrics  | Google Pub/Sub topic  |
| PING_INTELLIGENCE_ASE_GOOGLE_PUBSUB_CONCURRENCY  | 1000  | Number of concurrent connections to Google Pub/Sub (Min:1, Max:1024, default: 1000)  |
| PING_INTELLIGENCE_ASE_GOOGLE_PUBSUB_QPS  | 1000  | Throttle the number of messages published per second. (Min: 1, Max:10000, default:1000)  |
| PING_INTELLIGENCE_ASE_GOOGLE_PUBSUB_APIKEY  |   | The API key to use to authenticate with Google  |
| PING_INTELLIGENCE_ASE_CACHE_QUEUE_SIZE  | 300  | Maximum number of messages buffered in memory (Min: 1, Max: 10000, Default: 300)  |
| PING_INTELLIGENCE_ASE_GOOGLE_PUBSUB_TIMEOUT_SECONDS  | 30  | Timeout in seconds to publish a message to Google Pub/Sub. (Min: 10, Max: 300, Default: 30)  |
| PING_INTELLIGENCE_TCP_SEND_BUFFER_BYTES  | 212992  | Kernel TCP send buffer size in bytes  |
| PING_INTELLIGENCE_TCP_RECEIVE_BUFFER_BYTES  | 212992  | enrel TCP receive buffer size in bytes  |
| PING_INTELLIGENCE_ASE_ATTACK_LIST_MEMORY  | 128MB  |   |
| PING_INTELLIGENCE_CLUSTER_PEER_NODE_CSV_LIST  |   | a comma-separated list of hostname:cluster_manager_port or IPv4_address:cluster_manager_port the ASE will try to connect to each server peer in the list  |
| PING_INTELLIGENCE_CLUSTER_ID  | ase_cluster  | The ASE cluster ID -- this must be unique  |
| PING_INTELLIGENCE_CLUSTER_MGMT_PORT  | 8020  | The ASE cluster management port  |
| PING_INTELLIGENCE_CLUSTER_SECRET_KEY  | OBF:AES:nPJOh3wXQWK/BOHrtKu3G2SGiAEElOSvOFYEiWfIVSdummoFwSR8rDh2bBnhTDdJ:7LFcqXQlqkW9kldQoFg0nJoLSojnzHDbD3iAy84pT84  | Secret key required to join the cluster  |
| PING_INTELLIGENCE_ABS_ENDPOINT  |   | a comma-separated list of abs nodes having hostname:port or ipv4:port as an address.  |
| PING_INTELLIGENCE_ABS_ACCESS_KEY  |   | access key for ase to authenticate with abs node  |
| PING_INTELLIGENCE_ABS_SECRET_KEY  |   | secret key for ase to authenticate with abs node  |
| PING_INTELLIGENCE_ABS_ENABLE_SSL  | true  | Setting this value to true will enable encrypted communication with ABS.  |
| PING_INTELLIGENCE_ABS_CA_CERT_PATH  |   | Configure the location of ABS's trusted CA certificates.  |
| TAIL_LOG_FILES  |   | Files tailed once container has started  |

## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingintelligence/hooks/README.md) for details on all pingintelligence hook scripts

---
This document is auto-generated from _[pingintelligence/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingintelligence/Dockerfile)_

Copyright © 2021 Ping Identity Corporation. All rights reserved.
