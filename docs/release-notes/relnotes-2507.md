---
title: DevOps Docker Builds, Version 2507 (Aug 1 2025)
---

# Version 2507 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2507 (Aug 1 2025)

### Enhancements

- Redhat UBI9 Minimal 9.6-1751286687 → 9.6-1754000177
- Alpine 3.22.0 → 3.22.1
- Liberica JDK17 17.0.15+10 → 17.0.16+12

### Features

- (PDI-2252) Support for correct image tag extension when specified as DOCKER_DEFAULT_PLATFORM environment variable.
- (PDI-2253) Updated pingdataconsole 10.3 to run on tomcat 11. This fixes an issue where the console would return a 404 error when running on tomcat 9.
- (PDI-2255) Image hook script 09-build-motd.sh no longer imports external MOTD content, improving security and reliability.

### Documentation

- (PDI-2246) Migrated content to the new developer experience portal, with redirects, for both https://helm.pingidentity.com and https://devops.pingidentity.com

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
