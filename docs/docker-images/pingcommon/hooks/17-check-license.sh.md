---
title: Ping Identity DevOps `pingcommon` Hook - `17-check-license.sh`
---

# Ping Identity DevOps `pingcommon` Hook - `17-check-license.sh`
 Check for license file
 - If LICENSE_FILE found make call to check-license api unless MUTE_LICENSE_VERIFICATION set to true
 - If LICENSE_FILE not found and PING_IDENTITY_DEVOPS_USER and PING_IDENTITY_DEVOPS_KEY defined
   make call to obtain a license from license server

---
This document is auto-generated from _[pingcommon/opt/staging/hooks/17-check-license.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcommon/opt/staging/hooks/17-check-license.sh)_

Copyright © 2023 Ping Identity Corporation. All rights reserved.
