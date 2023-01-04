---
title: DevOps Docker Builds, Version 2212 (January 03 2023)
---

# Version 2212 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2212 (January 03 2023)

### New Product Releases
- PingAccess 7.2.0 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingDirectory 9.2.0.0 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
- PingAuthorize 9.2.0.0 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
- PingDataSync 9.2.0.0 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
- PingDirectoryProxy 9.2.0.0 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))

### Resolved Defects
- (BRASS-522) Remove PingDataGovernance/PingDataGovernancePAP images and documentation
- (BRASS-653) Resolved shellcheck errors causing pipeline to fail
- (BRASS-655) Delete EA and Beta Images from DockerHub
- (BRASS-655) Disable Old Archive Process to ECR
- (BRASS-655) Cleanup Old edge images from Artifactory
- (BRASS-604) Update our server profiles for PF to not use tcp.xml.subst

### Documentation
- Added [Reference CICD Pipeline Demonstration](https://videos.pingidentity.com/detail/videos/devops/video/6318020361112/reference-cicd-pipeline-demonstration)

### Enhancements
- All images tags are now archived in artifactory for internal access (without needing GTE-role)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
