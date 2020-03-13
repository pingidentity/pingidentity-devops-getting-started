
# Ping Identity DevOps Docker Image - `pingtoolkit`

This docker image includes the Ping Identity PingToolkit
and associated hook scripts to create a container that can pull in a SERVER_PROFILE
run scripts.  The typical use case of this image would be an init container or a pod/container
to perform tasks aside a running set of pods/containers.

## Related Docker Images
- pingidentity/pingbase - Parent Image
	>**This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**
- pingidentity/pingcommon - Common Ping files (i.e. hook scripts)

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**,
the following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  | 
| PING_PRODUCT  | PingToolkit  | 
| STARTUP_COMMAND  | tail  | 
| STARTUP_FOREGROUND_OPTS  | -f /dev/null  | 
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingtoolkit/hooks/README.md) for details on all pingtoolkit hook scripts

---
This document auto-generated from _[pingtoolkit/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingtoolkit/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
