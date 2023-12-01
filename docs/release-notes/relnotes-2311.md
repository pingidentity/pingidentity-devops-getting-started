---
title: DevOps Docker Builds, Version 2311 (Dec 1 2023)
---

# Version 2311 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2311 (Dec 1 2023)

### New Product Releases

- PingCentral 1.14.0 → 1.14.1
- PingFederate 11.3.2 → 11.3.3
- UnboundID LDAP SDK 6.0.10 → 6.0.11
- PingData products 9.3.0.2 -> 9.3.0.3
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))
- PingData products 9.2.0.3 -> 9.2.0.4
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements

- Apache Tomcat 9.0.82 → 9.0.83

### Features

- (BRASS-1291) Added PF_LDAP_TYPE environment variable to support ldap.properties new field 'ldap.type' in PF 11.3.
- (BRASS-1354) Our RHEL UBI9-minimal images now come with tar commandline utility installed by default.

### Resolved Defects

- (BRASS-1331) Fixed issue in our Helm charts where the replicas field was being set when autoscaling was enabled.
- (BRASS-1334) Updated the Helm Chart checks for semantic version for apiVersion to use a capability check rather than 
  verifying specific versions. This fixes issues with comparing prerelease versions.
- (BRASS-1345) Update the PingAuthorizePAP readiness check.

### Documentation

- (BRASS-1318) Added FAQ concerning trial licenses versus engaging support.
- (BRASS-1329) Reviewed and updated getting-started examples, creating clusters and using kind or minikube documentation.

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
