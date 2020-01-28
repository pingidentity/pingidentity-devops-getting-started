# DevOps Docker image: `pingfederate`

The `pingfederate` Docker image includes the PingFederate product binaries and associated hooks (scripts) to create and run both the PingFederate Admin and
Engine nodes. 

## Related Docker images

* `pingbase`

    This is the parent image. This image inherits, and can use, environment variables from the [`pingbase` Docker image](dockerImageRef-pingbase).

* `pingcommon` 

    Contains the common files for our products (such as, hooks).

* `pingdownloader`

    Used to download product build images.

## Ports Exposed

The following ports are exposed by the container.  If a variable is supplied, the exposed port defaults to that for a parent container.

* 9031
* 9999

## Environment variables

In addition to environment variables inherited from the [`pingbase` Docker image](dockerImageRef-pingbase), the following environment variables can be used:

| Environment variable  | Default     | Description |
| ---: | --- | --- |
| PING_PRODUCT  | PingFederate  | ?? |
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/server/default/conf |  ?? |
| LICENSE_FILE_NAME  | pingfederate.lic | ?? | 
| LICENSE_SHORT_NAME  | PF | ?? | 
| LICENSE_VERSION  | ${LICENSE_VERSION} | ?? | 
| OPERATIONAL_MODE  | STANDALONE | ?? | 
| CLUSTER_BIND_ADDRESS  | NON_LOOPBACK | ?? | 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh | ?? | 
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/log/server.log | ?? | 
| PF_ENGINE_DEBUG  | false | ?? | 
| PF_ADMIN_DEBUG  | false | ?? | 
| PF_DEBUG_PORT  | 9030 | ?? |

## Administrator console

If you're using our supplied PingFederate server profile (used by our examples), the console URL and credentials are: 

* Console URL: https://localhost:9999/pingfederate/app
* User: Administrator
* Password: 2FederateM0re

## Hooks

You'll find any available hooks for the `pingfederate` container in the [`pingfederate` Docker image](docker-images/pingfederate) `hooks` subdirectory.

