
# Ping Identity DevOps `pingdirectoryproxy` Hook - `03-build-run-plan.sh`
 This script is called to check if there is an existing server
 and if so, it will return a 1, else 0
 Goal of building a run plan is to provide a plan for the server as it starts up
 Options for the RUN_PLAN and the PD_STATE are as follows:
 RUN_PLAN (Initially set to UNKNOWN)
          START   - Instructs the container to start from scratch.  This is primarily
                    because a server.uuid file is not present.
          RESTART - Instructs the container to restart an existing directory.  This is
                    primarily because an existing server.uuid file is prsent.

 PD_STATE (Initially set to UNKNOWN)
          SETUP   - Specifies that the server should be setup
          UPDATE  - Specifies that the server should be updated
          GENISIS - A very special case when the server is determined to be the
                    SEED Server and initial server should be setup and data imported

---
This document auto-generated from _[pingdirectoryproxy/hooks/03-build-run-plan.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectoryproxy/hooks/03-build-run-plan.sh)_

Copyright (c) 2021 Ping Identity Corporation. All rights reserved.
