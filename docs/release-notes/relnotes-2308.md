---
title: DevOps Docker Builds, Version 2308 (Sep 5 2023)
---

# Version 2308 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2308 (Sep 5 2023)

### New Product Releases
- PingFederate EOL 11.0.3
- PingAccess EOL 7.0.4 and 7.1.0
- PingData products 9.2.0.1 → 9.2.0.2 and 9.3.0.0 → 9.3.0.1
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements
- Apache Tomcat 9.0.78 → 9.0.80
- Alpine 3.18.2 → 3.18.3
- Liberica JDK11 11.0.20+8 → 11.0.20.1+1 
- Liberica JDK17 17.0.8+7 → 17.0.8.1+1

### Resolved Defects
- (BRASS-1087) Update PD_FORCE_DATA_REIMPORT variable name to match documentation

### Features
- (BRASS-1122) Added support for imagePullSecrets in Helm charts
- (BRASS-1050) Test image integration on openshift cluster
- (BRASS-853) Add "DEBUG" option for intermediate logging, for now just around curl calls in product containers

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
