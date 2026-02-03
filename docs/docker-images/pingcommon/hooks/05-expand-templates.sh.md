---
title: Ping Identity DevOps `pingcommon` Hook - `05-expand-templates.sh`
---

# Ping Identity DevOps `pingcommon` Hook - `05-expand-templates.sh`
 Using the envsubst command, this will look through any files in the
 STAGING_DIR that end in `.subst` or `.subst.default`
 and substitute any variables the files with the the value of those
 variables, if the variable is set.
 Variables may come from (in order of precedence):
  - The '.env' file from the profiles and intra container env variables
  - The environment variables or env-file passed to container on startup
  - The container's os
 If a .zip file ends with `.zip.subst` (especially useful for pingfederate
 for example with data.zip) then:
  - file will be unzipped
  - any files ending in `.subst` will be processed to substitute variables
  - zipped back up in to the same file without the `.subst` suffix
 If a file ends with `.subst.default` (intended to only be expanded as a
 default if the file is not found) then it will be substituted:
  - If the RUN_PLAN==START and the file is not found in staging
  - If the RUN_PLAN==RESTART and the file is found in staging or the OUT_DIR
 >Note: If a string of $name should be ignored during a substitution, then
 A special variable ${_DOLLAR_} should be used.  This is not required any longer
 and deprecated, but available for any older server-profile versions.
 >Example: ${_DOLLAR_}{username} ==> ${username}

---
This document is auto-generated from _[pingcommon/opt/staging/hooks/05-expand-templates.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcommon/opt/staging/hooks/05-expand-templates.sh)_

Copyright © 2026 Ping Identity Corporation
