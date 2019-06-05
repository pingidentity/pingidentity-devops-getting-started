
# Ping Identity DevOps `pingcommon` Hook - `14-get-remote-server-profile.sh`
This hook will get bits from a git repo based on SERVER_PROFILE_* variables
passed to the container.  If no SERVER_PROFILES are passed, then nothing will
occur when running this hook.

These bits will be placed into the STAGING_DIR location (defaults to
${BASE_DIR}/staging).

Server Profiles may be layered to copy in profils from a parent/ancestor server
profile.  An example might be a layer of profiles that look like:

- Dev Environment Configs (DEV_CONFIG)
  - Dev Certificates (DEV_CERT)
    - Base Configs (BASE)

This would result in a set of SERVER_PROFILE variables that looks like:
- SERVER_PROFILE_URL=...git url of DEV_CONFIG...
- SERVER_PROFILE_PARENT=DEV_CERT
- SERVER_PROFILE_DEV_CERT_URL=...git url of DEV_CERT...
- SERVER_PROFILE_DEV_CERT_PARENT=BASE
- SERVER_PROFILE_BASE_URL=...git url of BASE...

In this example, the bits for BASE would be pulled, followed by DEV_CERT, followed
by DEV_CONFIG

If other source maintenance repositories are used (i.e. bitbucket, s3, ...)
then this hook could be overridden by a different hook

---
This document auto-generated from _[pingcommon/hooks/14-get-remote-server-profile.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcommon/hooks/14-get-remote-server-profile.sh)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
