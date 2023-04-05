---
title: DevOps Docker Builds, Version 2303 (April 04 2023)
---

# Version 2303 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2303 (April 04 2023)

### New Product Releases
- PingAccess 7.2.0 -> 7.2.1 and build 7.3.0-Beta ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingFederate 11.2.3 -> 11.2.4 and build 11.3.0-beta EOL 11.0.1 and 10.3.5 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingData products 9.1.0.1 -> 9.1.0.2 EOL 9.0.0.0
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))
- PingIdentity LDAPSDK 6.0.7 -> 6.0.8 ([Dockerhub](https://hub.docker.com/r/pingidentity/ldap-sdk-tools))
- Apache Tomcat 9.0.72 -> 9.0.73 ([Dockerhub](https://hub.docker.com/r/pingidentity/apache-jmeter))

### Enhancements
- Alpine 3.17.2 -> 3.17.3

### Resolved Defects
- (BRASS-650) Updated helm template tests to check array values
- (BRASS-735) Added integration-tests for arm pods of pingauthorize and pingauthorizepap
- (BRASS-762) Fixed broken Kubernetes links on the Ping Identity devops site
- (BRASS-808) Set Proxy topology host and port correctly
- (BRASS-835) Fix replication result code not being recorded correctly in VERBOSE mode
- (BRASS-839) Added Splunk log formatting examples for PingFederate and PingDirectory
- (BRASS-842) Update defaultDomain to pingdemo.example across the board


### Features
- (BRASS-806) Add default matchLabels values for topologySpreadConstraints
- (BRASS-645) Enable pf.cluster.bind.address to be set with variable

### Documentation
- Added [Forward PingFederate and PingAccess logs to Splunk](https://devops.pingidentity.com/how-to/splunkLogging/)
- Added [Upgrading PingAccess](https://devops.pingidentity.com/how-to/upgradePingAccess/)
- Added [Multi-node local K8s cluster guide](https://devops.pingidentity.com/deployment/deployFullK8s/)
- Added [Clarification for 3rd party software support](https://devops.pingidentity.com/home/3rdPartySoftware/)
- Added [Deploy a Local Openshift Cluster](https://videos.pingidentity.com/detail/videos/devops/video/6319613511112/openshift-local-demonstration)
- Added [Splunk Logging Example](https://videos.pingidentity.com/detail/videos/devops/video/6323662641112/splunk-logging-demonstration)
- Updated [FAQs page to describe how to get notified of a release](https://devops.pingidentity.com/reference/faqs/)

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
