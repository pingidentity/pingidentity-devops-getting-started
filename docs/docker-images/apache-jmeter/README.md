
## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/apache-jmeter/hooks/README.md) for details on all apache-jmeter hook scripts

---
This document is auto-generated from _[apache-jmeter/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/apache-jmeter/Dockerfile)_

Copyright © 2021 Ping Identity Corporation. All rights reserved.
