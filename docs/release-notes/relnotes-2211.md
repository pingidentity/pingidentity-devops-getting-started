---
title: DevOps Docker Builds, Version 2211 (December 09 2022)
---

# Version 2210 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2210 (November 02 2022)

### New Product Releases
- PingDirectory 9.1.0.1 and EOL 9.1.0.0 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
- PingFederate 11.2.0 and EOL 11.0.5 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingFederate 11.1.2 -> 11.1.3 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))

### Resolved Defects
- (BRASS-615) Remove DevOps User/Key Requirement from PingFederate Upgrade Script.
- (BRASS-570) Updated the 90-shutdown-sequence.sh hook script to not attempt
to remove the seed server from its topology.

### Documentation
- Added [Ping Product Docker Image Exploration](https://videos.pingidentity.com/detail/videos/devops/video/6314748082112/ping-product-docker-image-exploration)
- Added [Hook Script Exploration](https://videos.pingidentity.com/detail/video/6315184605112/hook-script-exploration)
- Added [CICD Demonstration](https://videos.pingidentity.com/detail/videos/devops)

### Enhancements
- Apache Tomcat 9.0.70 and EOL 9.0.69
- LDAPSDK 6.0.7 and EOL 6.0.6
- Alpine 3.16.2 -> 3.17.0
- Apache Tomcat 9.0.68 -> 9.0.69
- OpenSSL 1.1.1 -> 3.0.7
- Added support for creating a [PingAccess cluster using Helm without a server-profile](https://devops.pingidentity.com/deployment/deployPACluster/)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
