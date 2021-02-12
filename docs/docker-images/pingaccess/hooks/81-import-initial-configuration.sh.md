
# Ping Identity DevOps `pingaccess` Hook - `81-import-initial-configuration.sh`
This script is started in the background immediately before
the server within the container is started

This is useful to implement any logic that needs to occur after the
server is up and running

For example, enabling replication in PingDirectory, initializing Sync
Pipes in PingDataSync or issuing admin API calls to PingFederate or PingAccess

---
This document auto-generated from _[pingaccess/hooks/81-import-initial-configuration.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingaccess/hooks/81-import-initial-configuration.sh)_

Copyright (c) 2021 Ping Identity Corporation. All rights reserved.
