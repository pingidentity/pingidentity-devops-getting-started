---
title: DevOps Docker Builds, Version 2412 (Jan 6 2025)
---

# Version 2412 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2412 (Jan 6 2025)

### New Product Releases

- PingAccess 8.2.0 and EOL 8.0.x
- PingCentral 2.2.0 and EOL 2.0.x
- PingData products 10.2.0.0 and EOL 10.0.0.X
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))
- PingFederate 12.2.0 and EOL 12.0.x


### Enhancements

- LDAP SDK 7.0.1 → 7.0.2
- Alpine 3.20.3 → 3.21.0
- RedHat UBI9 Minimal 9.5-1731604394 → 9.5-1734497536
- Apache Tomcat 9.0.97 → 9.0.98

### Features

- (PDI-2154) Ping product images are now built with Liberica JDK17 installed, replacing Liberica JDK11. 
- (PDI-2151) Package managers are no longer removed from Ping product images.

### Resolved Defects

- (PDI-2147) Update PingFederate image default log4j2.xml.subst.default files.

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
