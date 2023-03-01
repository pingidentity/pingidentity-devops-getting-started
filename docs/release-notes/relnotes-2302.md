---
title: DevOps Docker Builds, Version 2302 (March 01 2023)
---

# Version 2302 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2302 (March 01 2023)

### New Product Releases
- PingFederate 11.2.2 -> 11.2.3 and 11.1.5 -> 11.1.6 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))

### Enhancements
- (BRASS-288) Pin every product to IPv4 for consistent liveness performance in dual-stack settings
- (BRASS-752) Added a check for indeterminate CRLF characters in sourced files in hook scripts

### Resolved Defects
- (BRASS-598) Fix setting custom java.properties for PingData images functionality
- (BRASS-743) Added support for PA clustered admin configuration apart from Ping Helm charts
- (BRASS-744) Hook script update to check if the start-up-deployer was used to configure PA admin and respond accordingly

### Features
- (BRASS-544) Support new logging level settings of PF 11.2
- (BRASS-591) Allow PingDirectoryProxy to join PingDirectory's topology with automatic backend discovery
- (BRASS-767) Updated the example PingDirectory backup script to run only on the master of the topology

### Documentation
- Added [FAQ on removal of direct Docker integration support from Kubernetes](https://devops.pingidentity.com/reference/faqs/)
- Added [Restoring a Multi Region PingDirectory Deployment on Seed Region Failure](https://devops.pingidentity.com/deployment/restorePDMultiRegionSeedFailure/)
- Replaced references to the configuration of the old devops tool(~/.pingidentity/devops), with the configuration for pingctl tool (~/.pingidentity/config)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
