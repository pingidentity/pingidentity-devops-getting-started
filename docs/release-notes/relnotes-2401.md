---
title: DevOps Docker Builds, Version 2401 (Jan 29 2024)
---

# Version 2401 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2401 (Jan 29 2024)

### New Product Releases

- PingCentral 2.0.0 → 2.0.1
- PingData products 9.3.0.3 → 9.3.0.4
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements

- Apache Tomcat 9.0.84 → 9.0.85
- Apache JMeter 5.6.2 → 5.6.3
- Redhat UBI9-minimal 9.1 → 9.3-1552
- Liberica JDK11 11.0.21+10 → 11.0.22+12
- Liberica JDK17 17.0.9+11 → 17.0.10+13
- Alpine 3.19.0 → 3.19.1

### Features

- (PDI-1358) Add support for environment variables in utility sidecar in helm charts
- (PDI-1367) Add global annotation support for PVC definitions
- (PDI-1461) Add support for secondary port to PF image

### Documentation

- (PDI-1432) Initial documentation for the PingFederate Terraform provider on https://terraform.pingidentity.com/

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
