---
title: DevOps Docker Builds, Version 2305 (June 01 2023)
---

# Version 2305 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2305 (June 01 2023)

### New Product Releases
- PingFederate 11.2.4 → 11.2.5 and 11.1.6 → 11.1.7 EOL 11.0.2 and 10.3.6 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingAccess EOL 7.0.3 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingData products 9.2.0.0 -> 9.2.0.1 EOL 8.3.0.5
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements
- Apache Tomcat 9.0.74 → 9.0.75
- Alpine 3.17.3 → 3.18.0

### Resolved Defects
- (BRASS-1024) Update PingAccess 51-add-engine.sh hook script to correctly handle engine crashes and restarts
- (BRASS-897) Improve check for the current topology in PingDirectory to fail if the server can't reach itself
- (BRASS-1033) Fix incorrect result code capture in hook scripts


### Features
- (BRASS-833) Update images to include product license at /licenses.

### Documentation
- Added [Ping Identity Support Portal](https://support.pingidentity.com/s/) as a support link for our Ping Identity customers
- Added [PingDevOps Community](https://support.pingidentity.com/s/topic/0TO1W000000IF30WAG/pingdevops) as a support link for our Non-Ping Identity customers
- Fix missing CERTIFICATE_NICKNAME row from product image documentation on devops site

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
