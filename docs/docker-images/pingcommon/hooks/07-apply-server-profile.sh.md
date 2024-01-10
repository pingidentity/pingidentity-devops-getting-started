---
title: Ping Identity DevOps `pingcommon` Hook - `07-apply-server-profile.sh`
---

# Ping Identity DevOps `pingcommon` Hook - `07-apply-server-profile.sh`
 The server-profiles from:
 * remote (i.e. git) and
 * local (i.e. /opt/in)
 have been merged into the ${STAGING_DIR}/instance (ie. /opt/staging/instance).
 This is a candidate to be installed or overwritten into the ${SERVER_ROOT_DIR}
 if one of the following items are true:
 * Start of a new server (i.e. RUN_PLAN=START)
 * Restart of a server with SERVER_PROFILE_UPDATE==true
 To force the overwrite of files on a restart, ensure that the variable:
     SERVER_PROFILE_UPDATE=true
 is passed.

---
This document is auto-generated from _[pingcommon/opt/staging/hooks/07-apply-server-profile.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcommon/opt/staging/hooks/07-apply-server-profile.sh)_

Copyright © 2023 Ping Identity Corporation. All rights reserved.
