
# Ping Identity DevOps `pingcommon` Hook - `16-apply-server-profile.sh`
Once both the remote (i.e. git) and local server-profiles have been merged
then we can push that out to the instance.  This will override any files found
in the ${OUT_DIR}/instance directory.

---
This document auto-generated from _[pingcommon/hooks/16-apply-server-profile.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcommon/hooks/16-apply-server-profile.sh)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
