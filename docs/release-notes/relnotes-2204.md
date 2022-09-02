---
title: DevOps Docker Builds, Version 2204 (May 05 2022)
---
# Version 2204 Release Notes

## DevOps Docker Builds, Version 2204 (May 05 2022)

### New Product Releases

- **PingAccess**
    - PingAccess 6.3.4 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess).
- **PingIntelligence**
    - PingIntelligence 5.1.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingintelligence).
- **pingctl**
    - pingctl 1.0.5 released [Release Notes](https://pingidentity.github.io/pingctl/release-notes/)  

### Documentation
- [Environment Considerations](https://devops.pingidentity.com/deployment/environmentConsiderations/) added
    - Workaround for NFS and PingData
- [Getting Started Examples](https://devops.pingidentity.com/get-started/getStartedExample/) updated
    - Getting-started docker-compose examples now use default registry and image tag values
    - docker-compose examples now use pingctl's config file over deprecated ping-devops's config file
- [Pingctl configuration](https://devops.pingidentity.com/tools/pingctlUtil/) updated
    - Instructions to export environment variables if wanted

### Resolved Defects

- (BRASS-389) - Fix an issue with the getSemanticImageVersion function that was causing "bad number" errors during hook scripts.
- (BRASS-397) - Updated PingDirectory and PingFederate server profiles to remove hard-coded instances of dc=example,dc=com and replace them with the USER_BASE_DN environment variable.

### Enhancements
- **Docker Images**
    - Apache Tomcat to Version 9.0.62
    - Alpine to version 3.15.4
    - Liberica JDK to 11.0.15+10

###Features
- (BRASS-393) PingDirectory supports multiple base DNS for replication
    - Updated the PingDirectory image to support enabling and initializing replication for multiple base DNs with the REPLICATION_BASE_DNS variable, in addition to the USER_BASE_DN variable. Multiple DNs can be delimited with a ';' character.  
        - For example:  REPLICATION_BASE_DNS=dc=additional,dc=com;dc=another,dc=com
- (BRASS-394) PingDataSync supports persistent volume for restarts
    - Updated the PingDataSync restart logic to include use of the manage-profile replace-profile command to support running PingDataSync with a persistent volume. This allows for updating the PingDataSync configuration on container restart, without requiring deploying a fresh container or volume.


### Supported Product Releases

This file shows the matrix of Ping Identity product software versions and the Ping Docker release tag in which they are available.  In accordance with our [image support policy](../docker-images/imageSupport.md), only images from the past 12 months are supported:

<object data="../../images/productVersionsAndImageTags.pdf" type="application/pdf" width="100%" height="1000px">
    <embed src="../../images/productVersionsAndImageTags.pdf">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="../../images/productVersionsAndImageTags.pdf">Download PDF</a>.</p>
    </embed>
</object>
