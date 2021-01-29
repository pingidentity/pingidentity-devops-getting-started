
# Ping Identity DevOps `pingaccess` Hook - `51-add-engine.sh`
 This script is started in the background immediately before
 the server within the container is started
 This is useful to implement any logic that needs to occur after the
 server is up and running
 For example, enabling replication in PingDirectory, initializing Sync
 Pipes in PingDataSync or issuing admin API calls to PingFederate or PingAccess

---
This document auto-generated from _[pingaccess/opt/staging/hooks/51-add-engine.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingaccess/opt/staging/hooks/51-add-engine.sh)_

Copyright (c) 2020 Ping Identity Corporation. All rights reserved.
