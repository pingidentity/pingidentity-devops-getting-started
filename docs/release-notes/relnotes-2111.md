---
title: DevOps Docker Builds, Version 2111 (December 06 2021)
---
# Version 2111 Release Notes

## DevOps Docker Builds, Version 2111 (December 06 2021)

### New Product Releases

- **PingFederate**
    - PingFederate 10.3.4 is available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate).


- **PingAccess**
    - PingAccess 6.3.2 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess).



### Enhancements

- **Tools**
    - The pingctl tool is now POSIX compliant in preparation for the pingdevops tool's deprecation.


- **Docker Images**
    - PingDirectory, PingDirectoryProxy, and PingDataSync will now start without a server profile.
    - Update JDK to 11.0.13+8.
    - Azul JVM has been deprecated in Favor of Liberica JVM.
    - PingData images are now killed with a TERM signal.
    - Update Apache Tomcat to Version 9.0.55.
    - Update Alpine to 3.15 and UBI8 to 8.5.
    - PingFederate PF_LDAP_USERNAME and PF_LDAP_PASSWORD variables are no longer required by default.


- **Helm Charts**
    - View the detailed release notes for Ping's Helm Charts [here](https://helm.pingidentity.com/release-notes).
        - Release 0.7.9
            - Support for HPA Scaling Behavior
            - Support for shareProcessNamespace in pod spec
            - Helm test image pull policy no longer hard-coded in helm-charts/charts/ping-devops/templates/pinglib/_tests/tpl
            - Cluster service for pingaccess-admin






### Resolved Defects

- (BRASS-80) - 07-apply-server-profile hook now handles PingDirectory restart correctly.
- (BRASS-172) - Default values have been added for PF_LDAP_USERNAME and PF_LDAP_PASSWORD to work around startup errors for PingFederate images.

### Supported Product Releases

This file shows the matrix of Ping Identity product software versions and the Ping Docker release tag in which they are available.  In accordance with our [image support policy](../docker-images/imageSupport.md), only images from the past 12 months are supported:

<object data="../../images/productVersionsAndImageTags.pdf" type="application/pdf" width="100%" height="1000px">
    <embed src="../../images/productVersionsAndImageTags.pdf">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="../../images/productVersionsAndImageTags.pdf">Download PDF</a>.</p>
    </embed>
</object>
