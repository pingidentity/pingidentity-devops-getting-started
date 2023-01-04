---
title: DevOps Docker Builds, Version 2212 (January 03 2023)
---

# Version 2212 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2212 (January 03 2023)

### New Product Releases
- PingAccess 7.2.0 releases and PingAccess products 7.0.x are no longer built ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingData products 9.2.0.0 released and PingData products 9.0.0.x are no longer built
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Resolved Defects
- (BRASS-522) Remove PingDataGovernance/PingDataGovernancePAP images and documentation
- (BRASS-657) Disable Old Archive Process to ECR
- (BRASS-655) Cleanup Old edge images from Artifactory
- (BRASS-604) Update our server profiles for PF to not use tcp.xml.subst

### Documentation
- Added [Reference CICD Pipeline Demonstration](https://videos.pingidentity.com/detail/videos/devops/video/6318020361112/reference-cicd-pipeline-demonstration)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
