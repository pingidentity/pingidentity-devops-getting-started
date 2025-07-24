---
title: DevOps Docker Builds, Version 2504 (May 1 2025)
---

# Version 2504 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2504 (May 1 2025)

### New Product Releases

- PingAccess 8.2.0 → 8.2.1
- PingAccess 8.1.2 → 8.1.3
- PingCentral 2.3.0 and EOL 2.1.x

### Enhancements

- Apache Tomcat 9.0.102 → 9.0.104
- RedHat UBI9-Minimal 9.5-1739420147 → 9.5-1745855087
- Liberica JDK17 17.0.14+10 → 17.0.15+10

### Features

- (PDI-2196) Updated the PingDirectory docker image to support new FAIL_ON_DISABLED_BASE_DN and FAIL_ON_UNSUCCESSFUL_REMOVE_DEFUNCT environment variables, which can be enabled by being set to "true". The first will fail the container if it is found that replication for the USER_BASE_DN is not enabled after all topology setup is complete. The second will fail the container if it is found that a previous call to remove-defunct-server did not complete successfully, indicating that the topology is in an unknown state. In these cases, manual intervention will be required to correct the topology.

### Documentation

- (PDI-2199) Updated the various examples on devops.pingidentity.com to ensure stability and operations.
- (PDI-2204) Added documentation at https://devops.pingidentity.com/reference/usingCertificates/ for certificate rotation in PingData images when using read-only keystores and truststores.
- (PDI-2207) Updated the example on devops.pingidentity.com for archiving to S3 to be platform-agnostic

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
