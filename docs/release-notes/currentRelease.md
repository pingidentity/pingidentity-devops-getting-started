---
title: DevOps Docker Builds, Version 2309 (Oct 3 2023)
---

# Version 2309 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2309 (Oct 3 2023)

### New Product Releases
- PingFederate 11.3.1 → 11.3.2
- PingAccess 7.3.0 → 7.3.1. EOL 7.1.1 and 7.0.5
- PingCentral 1.14.0 Release and PingCentral 1.11.0 no longer built. EOL 1.10.0 and 1.9.4
- PingData products 9.2.0.2 → 9.2.0.3
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements
- Alpine 3.18.3 → 3.18.4
- LDAP SDK 6.0.9 → 6.0.10

### Resolved Defects
- (BRASS-1087) Update PD_FORCE_DATA_REIMPORT variable name to match documentation
- (BRASS-286) PingAccess Cluster - handle orphaned engines

### Features
- (BRASS-1123) Publish images to openshift certified registry

### Documentation
- Added [Upgrading PingCentral](https://devops.pingidentity.com/how-to/upgradePingCentral/)
- Added helm examples for imagePullSecrets to [Deploy Ping DevOps Charts using Helm](https://devops.pingidentity.com/deployment/deployHelm/#helm-chart-example-configurations)
- Provided clarity on EFS/EBS support with Ping products running on AWS in [Recent portal updates](https://devops.pingidentity.com/home/portalUpdates/#a-statement-on-aws-efsebs)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
