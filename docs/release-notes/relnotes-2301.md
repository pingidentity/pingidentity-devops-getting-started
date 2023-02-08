---
title: DevOps Docker Builds, Version 2301 (February 07 2023)
---

# Version 2301 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2301 (February 07 2023)

### New Product Releases
- PingFederate 11.2.0 -> 11.2.2 and 11.1.3 -> 11.1.5 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))

### Enhancements
- Alpine 3.17.0 -> 3.17.1
- Apache Tomcat 9.0.70 -> 9.0.71
- Liberica JDK11 11.0.17+7 -> 11.0.18+10
- Liberica JDK17 17.0.5+8 -> 17.0.6+10

### Resolved Defects
- (BRASS-646) Support PingData multi-region multi-loadbalancer use case
- (BRASS-660) Update helm charts to support K8s 1.25+ in
- (BRASS-674) Fixed error output problem from tags 2211 or 2212 with 2211.1 or 2212.1
- (BRASS-683) Updated PingDataConsole baseline server profile to handle spring.mvc.pathmatch.matching-strategy=ant_path_matcher
- (BRASS-688) Fixed issue where PingDirectoryProxy was unable to start with mounted license
- (BRASS-705) Handle Restarts in PingAccess 81 Hook Script

### Documentation
- Added [Openshift Local Demonstration](https://videos.pingidentity.com/detail/videos/devops/video/6319613511112/openshift-local-demonstration)
- Added [Migrating from privileged images to unprivileged-by-default images](https://devops.pingidentity.com/how-to/migratingRootToUnprivileged/)
- Added [Deploy a local Kubernetes Cluster](https://devops.pingidentity.com/deployment/deployLocalK8sCluster/)
- Added [Deploy a Local Openshift Cluster](https://devops.pingidentity.com/deployment/deployLocalOpenshift/)
- Added [Migrating cluster discovery settings](https://docs.pingidentity.com/r/en-us/pingfederate-110/pf_migrate_cluster_discovery_settings)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
