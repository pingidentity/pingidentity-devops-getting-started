---
title: Ping Identity DevOps `pingcommon` Hook - `03-build-run-plan.sh`
---

# Ping Identity DevOps `pingcommon` Hook - `03-build-run-plan.sh`
 This script will building a run plan for the server as it starts up
 Options for the RUN_PLAN and the PD_STATE are as follows:
 RUN_PLAN (Initially set to UNKNOWN)
          START   - Instructs the container to start from scratch.  This is primarily
                    because a STARTUP_COMMAND (i.e. /opt/out/instance/bin/run.sh) isn't present.
          RESTART - Instructs the container to restart.  This is primarily because the
                    STARTUP_COMMAND (i.e. /opt/out/instance/bin/run.sh) is present and typically
                    signifies that the server bits have been copied and run before
 > NOTE: It will be common for products to override this hook to provide
 > RUN_PLAN directions based on product specifics.

---
This document is auto-generated from _[pingcommon/opt/staging/hooks/03-build-run-plan.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcommon/opt/staging/hooks/03-build-run-plan.sh)_

Copyright © 2022 Ping Identity Corporation. All rights reserved.
