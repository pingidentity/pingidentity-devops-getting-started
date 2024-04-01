---
title: DevOps Docker Builds, Version 2403 (Mar 29 2024)
---

# Version 2403 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2403 (Mar 29 2024)

### New Product Releases

- PingAccess 7.3.2 → 7.3.3
- PingAccess 8.0.0 → 8.0.1
- PingData products 10.0.0.1 -> 10.0.0.2
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements

- Apache Tomcat 9.0.86 → 9.0.87
- LDAPSDK 6.0.11 -> 7.0.0

### Resolved Defects

- (PDI-1505) Fixed an issue where environment variables pulled in from Vault secrets were not available to the server process

### Documentation

- (PDI-1475) Remove example for setting up Prometheus in GitHub server profile

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
