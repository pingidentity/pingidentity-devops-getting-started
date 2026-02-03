---
title: Ping Identity DevOps `pingaccess` Hook - `85-import-configuration.sh`
---

# Ping Identity DevOps `pingaccess` Hook - `85-import-configuration.sh`
 This script is started in the background immediately before
 the server within the container is started
 This is useful to implement any logic that needs to occur after the
 server is up and running
 For example, enabling replication in PingDirectory, initializing Sync
 Pipes in PingDataSync or issuing admin API calls to PingFederate or PingAccess

---
This document is auto-generated from _[pingaccess/opt/staging/hooks/85-import-configuration.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingaccess/opt/staging/hooks/85-import-configuration.sh)_

Copyright © 2026 Ping Identity Corporation
