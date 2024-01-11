---
title: Ping Identity DevOps Docker Image - `pingtoolkit`
---

# Ping Identity DevOps Docker Image - `pingtoolkit`

This docker image includes the Ping Identity PingToolkit
and associated hook scripts to create a container that can pull in a SERVER_PROFILE
run scripts.  The typical use case of this image would be an init container or a pod/container
to perform tasks aside a running set of pods/containers.

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
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| DATE  | ${DATE}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_PRODUCT  | PingToolkit  | Ping product name  |
| STARTUP_COMMAND  | tail  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | -f /dev/null  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingtoolkit/hooks/README.md) for details on all pingtoolkit hook scripts

---
This document is auto-generated from _[pingtoolkit/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingtoolkit/Dockerfile)_

Copyright © 2024 Ping Identity Corporation. All rights reserved.
