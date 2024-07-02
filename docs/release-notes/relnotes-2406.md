---
title: DevOps Docker Builds, Version 2406 (Jul 2 2024)
---

# Version 2406 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2406 (Jul 2 2024)

### New Product Releases

- LDAPSDK 7.0.0 → 7.0.1
- PingFederate 12.1.0
- PingFederate EOL 11.3.X
- PingAccess 8.1.0
- PingAccess EOL 7.3.X
- PingCentral 2.1.0
- PingCentral EOL 1.14.X
- PingData products 10.1.0.0
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))
- PingData EOL 9.3.X.X

### Enhancements

- Apache Tomcat 9.0.89 → 9.0.90
- Redhat UBI9 Minimal 9.4-949.1716471857 → 9.4-1134
- Alpine 3.20.0 → 3.20.1

### Bug Fixes

- (PDI-1843) Fixed issue where '.pre' and '.post' hooks could not be used for the '81-after-start-process' hook for PingAccess and PingFederate
- (PDI-1867) Updated build-jvm.sh script to use curl rather than wget to avoid an IPV6 issue with some OS shims

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.



