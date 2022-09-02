---
title: DevOps Docker Builds, Version 2201 (February 07 2022)
---
# Version 2201 Release Notes

## DevOps Docker Builds, Version 2201 (February 07 2022)

### New Product Releases

- **PingFederate**
    - PingFederate 11.0.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate).

- **PingAccess**
    - PingAccess 6.3.3 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess).

- **PingDirectory**
    - PingDirectory 8.3.0.5 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory).

- **PingDataConsole**
    - PingDataConsole 8.3.0.5 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole).

- **PingDirectoryProxy**
    - PingDirectoryProxy 8.3.0.5 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy).

- **PingDataSync**
    - PingDataSync 8.3.0.5 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync).

- **PingAuthorize**
    - PingAuthorize 8.3.0.5 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize).

- **PingAuthorizePAP**
    - PingAuthorizePAP 8.3.0.5 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorizepap).

### Enhancements
- **Docker Images**
    - Apache Tomcat to Version 9.0.58
    - Liberica JDK to 11.0.14+9

- **Helm Charts**
    #### [Release 0.8.5](https://helm.pingidentity.com/release-notes/#release-085-feb-7-2022) ####
    - Features
      - PingCentral now supported. Example values application found [here](../deployment/deployHelm.md)
    - Issues Resolved
      - [Issue #119](https://github.com/pingidentity/helm-charts/issues/119) Workload template not honoring false values from values.yaml. Previously, false did not overwrite true in the Ping Identity Helm Chart template. This fix in _merge-util.tpl will resolve multiple cases within the Ping Identity Helm Chart.
        ```
        {{- $globalValues := deepCopy $top.Values.global -}}
        {{- $prodValues := deepCopy (index $top.Values $prodName) -}}
        {{- $mergedValues := mergeOverwrite $globalValues $prodValues -}}
        ```
      - [Issue #264](https://github.com/pingidentity/helm-charts/issues/264) Update default global.image.tag to 2201

### Resolved Defects

- (BRASS-315) - PingFederate server profiles in getting-started and baseline no longer contain an invalid runtime certificate

### Supported Product Releases

This file shows the matrix of Ping Identity product software versions and the Ping Docker release tag in which they are available.  In accordance with our [image support policy](../docker-images/imageSupport.md), only images from the past 12 months are supported:

<object data="../../images/productVersionsAndImageTags.pdf" type="application/pdf" width="100%" height="1000px">
    <embed src="../../images/productVersionsAndImageTags.pdf">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="../../images/productVersionsAndImageTags.pdf">Download PDF</a>.</p>
    </embed>
</object>
