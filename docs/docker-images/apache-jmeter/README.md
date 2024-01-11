---
title: Ping Identity DevOps Docker Image - `apache-jmeter`
---

## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| DATE  | ${DATE}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PING_PRODUCT  | Apache-JMeter  | Ping product name  |
| JAVA_RAM_PERCENTAGE  | 90.0  | Percentage of the container memory to allocate to PingFederate JVM DO NOT set to 100% or your JVM will exit with OutOfMemory errors and the container will terminate  |
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  | The command that the entrypoint will execute in the foreground to instantiate the container  |

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/apache-jmeter/hooks/README.md) for details on all apache-jmeter hook scripts

---
This document is auto-generated from _[apache-jmeter/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/apache-jmeter/Dockerfile)_

Copyright © 2024 Ping Identity Corporation. All rights reserved.
