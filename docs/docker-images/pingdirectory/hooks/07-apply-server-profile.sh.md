---
title: Ping Identity DevOps `pingdirectory` Hook - `07-apply-server-profile.sh`
---

# Ping Identity DevOps `pingdirectory` Hook - `07-apply-server-profile.sh`
 The server-profiles from:
 * remote (i.e. git) and
 * local (i.e. /opt/in)
 have been merged into the ${STAGING_DIR}/instance (ie. /opt/staging/instance).
 These files will be installed or overwritten into the ${SERVER_ROOT_DIR}.

---
This document is auto-generated from _[pingdirectory/opt/staging/hooks/07-apply-server-profile.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectory/opt/staging/hooks/07-apply-server-profile.sh)_

Copyright © 2025 Ping Identity Corporation. All rights reserved.
