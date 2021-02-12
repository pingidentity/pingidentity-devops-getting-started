
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
| PD_PROFILE  | ${STAGING_DIR}/pd.profile  |
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatacommon/hooks/README.md) for details on all pingdatacommon hook scripts

---
This document auto-generated from _[pingdatacommon/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatacommon/Dockerfile)_

Copyright (c) 2021 Ping Identity Corporation. All rights reserved.
