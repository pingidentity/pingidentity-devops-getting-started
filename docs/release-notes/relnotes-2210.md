---
title: DevOps Docker Builds, Version 2210 (November 02 2022)
---

# Version 2210 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2210 (November 02 2022)

### New Product Releases
- PingFederate 11.1.2 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingAccess 7.1.3, EOL 7.1.2 and 7.2.0-Beta ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))

### Resolved Defects
- (BRASS-392) - Configure baseline server profile pf-connected-identities for DA configuration

### Enhancements
- Added support for the necessary dsreplication commands and arguments to deploy an entry-balanced PingDirectory topology.
- Use the RESTRICTED_BASE_DNS environment variable to define the restricted base DNs for the topology. The multi-region environment variables (such as K8S_CLUSTER and K8S_SEED_CLUSTER) must also be defined when using entry balancing
- com.unboundid.directory.server.MaintainConfigArchive=false has been set in the PingData images

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
