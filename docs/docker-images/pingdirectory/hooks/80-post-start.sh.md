
# Ping Identity DevOps `pingdirectory` Hook - `80-post-start.sh`
 This hook runs through the followig phases:
 * Ensures the PingDirectory service has been started an accepts queries.
 * Updates the Server Instance hostname/ldaps-port
 * Check to see if PD_STATE is GENISIS.  If so, no replication will be performed
 * Ensure the Seed Server is accepting queries
 * Check the topology prior to enabling replication
 * If this server is already in prior topology, then replication is already enable
 * If the server being setup is the Seed Instance, then no replication will be performed
 * Get the current Toplogy Master
 * Determine the Master Toplogy server to use to enable with
 * Enabling Replication
 * Get the new current topology
 * Initialize replication

---
This document auto-generated from _[pingdirectory/hooks/80-post-start.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectory/hooks/80-post-start.sh)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
