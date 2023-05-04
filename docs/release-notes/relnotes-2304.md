---
title: DevOps Docker Builds, Version 2304 (May 04 2023)
---

# Version 2304 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2304 (May 04 2023)

### New Product Releases
- PingAccess EOL 7.0.3 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingFederate EOL 11.0.2 and 10.3.6 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingIntelligence EOL 5.1.0 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingintelligence))

### Enhancements
- Liberica JDK11 11.0.18+10 -> 11.0.19+7
- Liberica JDK17 17.0.6+10 -> 17.0.7+7
- Apache Tomcat 9.0.73 -> 9.0.74
- Docker in docker (dind) 18.09 -> 23.0.2

### Resolved Defects
- (BRASS-893) Update Hook Scripts to Work with Curl 8
- (BRASS-979) Prevent PingDirectory container readiness probe from succeeding before replication configuration was complete on restart


### Features
- (BRASS-869) Preserve docker cache when using serial_build.sh to build images locally.

### Documentation
- Added video to [Deploy a robust local Kubernetes Cluster](https://devops.pingidentity.com/deployment/deployFullK8s/)
- Added [Forwarding PingFederate and PingAccess logs to Splunk](https://devops.pingidentity.com/how-to/splunkLogging/)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
