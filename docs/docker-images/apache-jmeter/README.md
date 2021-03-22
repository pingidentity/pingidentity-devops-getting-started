
## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  | Image version and git revision, set by build process of the pipeline  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  |  |
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/apache-jmeter/hooks/README.md) for details on all apache-jmeter hook scripts

---
This document is auto-generated from _[apache-jmeter/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/apache-jmeter/Dockerfile)_

Copyright (c) 2021 Ping Identity Corporation. All rights reserved.
