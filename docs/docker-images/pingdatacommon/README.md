---
title: Ping Identity DevOps Docker Image - `pingdatacommon`
---

# Ping Identity Docker Image - `pingdatacommon`

This docker image provides a busybox image based off of `pingidentity/pingcommon`
to house the base hook scripts used throughout
the Ping Identity DevOps PingData product images.

## Related Docker Images
- `pingidentity/pingcommon` - Parent Image

## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| REGENERATE_JAVA_PROPERTIES  | false  | Flag to force a run of dsjavaproperties --initialize. When this is false, the java.properties file will only be regenerated on a restart when there is a change in JVM or a change in the product-specific java options, such as changing the MAX_HEAP_SIZE value.  |

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatacommon/hooks/README.md) for details on all pingdatacommon hook scripts

---
This document is auto-generated from _[pingdatacommon/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatacommon/Dockerfile)_

Copyright © 2022 Ping Identity Corporation. All rights reserved.
