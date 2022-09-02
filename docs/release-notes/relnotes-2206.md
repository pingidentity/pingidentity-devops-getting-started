---
title: DevOps Docker Builds, Version 2206 (July 01 2022)
---

# Version 2206 Release Notes

!!! note "Product release notes"
    For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2206 (July 01 2022)


### New Product Releases
- PingData products 9.1.0.0 released and PingData products 8.3.x are no longer built
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))
- PingFederate 11.1.0 released and PF 10.3.x no longer built  ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingAccess 7.1.0 released and PA 6.3.x no longer built  ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingCentral 1.10.0 released  ([Dockerhub](https://hub.docker.com/r/pingidentity/pingcentral))
- PingDelegator 4.10.0 released and PDA 4.9.x no longer built  ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdelegator))

### Documentation
- [How-to documentation for PingIntelligence](https://devops.pingidentity.com/deployment/deployK8sPi/)
- [Added page for Openshift configuration](https://helm.pingidentity.com/config/openshift/)
### Resolved Defects
- (BRASS-464) Fixed PingAuthorize baseline server profile overwriting certain environment variables from the orchestration layer

### Enhancements
- Liberica JDK -> 11.0.15.1+2
- Apache Tomcat in PingDataConsole -> 9.0.64
- Apache JMeter -> 5.5

### Features
- (BRASS-440) Kubernetes deployment script of Ping Intelligence

### Supported Product Releases

This file shows the matrix of Ping Identity product software versions and the Ping Docker release tag in which they are available.  In accordance with our [image support policy](../docker-images/imageSupport.md), only images from the past 12 months are supported:

<object data="../../images/productVersionsAndImageTags.pdf" type="application/pdf" width="100%" height="1000px">
    <embed src="../../images/productVersionsAndImageTags.pdf">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="../../images/productVersionsAndImageTags.pdf">Download PDF</a>.</p>
    </embed>
</object>
