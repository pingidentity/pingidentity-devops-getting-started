---
title: DevOps Docker Builds, Version 2208 (September 01 2022)
---

# Version 2208 Release Notes

!!! note "Product release notes"
    For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2208 (September 01 2022)

### New Product Releases
- PingAccess 7.1.1 and 7.0.5 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingFederate 11.0.4 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))


### Resolved Defects
- (BRASS-346) Added documentation for setting the PingFederate provisioner node ID
- (BRASS-366) Added .default to any .subst files built into the image that did not have the extension. This prevents .subst files from overwriting the equivalent files when defined in a server profile.
- (BRASS-469) PingFederate Upgrade Documentation has been updated
- (BRASS-484) Fixed layered profile documentation page referring to a profile that no longer exists.
- (BRASS-516) Updated documentation with new recommended process for PingData certificate rotation

### Enhancements 
- Liberica JDK 11.0.16+8 -> 11.0.16.1+1
- Liberica JDK 17.0.4+8 -> 17.0.4.1+1
- Alpine 3.16.1 -> 3.16.2

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
