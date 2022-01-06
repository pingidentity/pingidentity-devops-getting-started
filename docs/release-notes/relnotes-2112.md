---
title: DevOps Docker Builds, Version 2112 (January 05 2022)
---
# Version 2112 Release Notes

## DevOps Docker Builds, Version 2112 (January 05 2022)

### New Product Releases

- **PingFederate**
    - PingFederate 11.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate).


- **PingAccess**
    - PingAccess 7.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess).


- **PingDirectory**
    - PingDirectory 9.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory).


- **PingDelegator**
    - PingDelegator 4.8 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdelegator).


- **PingDirectoryProxy**
    - PingDirectoryProxy 9.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy).


- **PingDataSync**
    - PingDataSync 9.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync).


- **PingAuthorize**
    - PingAuthorize 9.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize).


- **PingIntelligence**
    - PingIntelligence 5.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingintelligence).


### Enhancements
- **Docker Images**
    - Apache Tomcat to Version 9.0.56
    - jmeter image to 5.4.3
    - LDAP SDK to 6.0.3
    - PingAccess to log4j 2.12.2, 2.12.3 patch
    - Set UNBOUNDID_SKIP_START_PRECHECK_NODETACH environment variable to true for PingData


- **Helm Charts**
    #### [Release 0.8.3](https://helm.pingidentity.com/release-notes/#release-083-jan-6-2022) ####
    - Features
        - Document [supported values](https://helm.pingidentity.com/config/supported-values)
    - Issues Resolved
        - [Issue #233](https://github.com/pingidentity/helm-charts/issues/235) Ingress - semverCompare now retrieves correct K8 version for applying the correct apiVersion
        ```
        {{- if semverCompare ">=1.19.x" $top.Capabilities.KubeVersion.Version }}
        ```
        - [Issue #254](https://github.com/pingidentity/helm-charts/issues/254) Update default global.image.tag to 2112


### Resolved Defects

- (BRASS-60) - [Bulk Config Tool Document](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/99-helper-scripts/ping-bulkconfigtool#run-the-export-utility) has been deprecated. [Building a PingFederate profile](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/docs/how-to/buildPingFederateProfile.md) has taken its place.
- (BRASS-181) - Update to PingDirectory liveness and readiness probes to use
    timeoutSeconds 5 and failureThreshold 3. Update to PingDirectory readiness probes to use readiness.sh.

### Product Build Matrix

- See the [Product Version, Image Release Matrix](../../reference/productVersionMatrix/)
for currently supported image and product versions.

- The following versions are no longer actively maintained:
    - PingFederate 10.2.7
    - PingAccess 6.2.2
    - PingCentral 1.8.1
    - PingDirectory 8.2.0.6
    - PingDirectoryProxy 8.2.0.6
    - PingDataSync 8.2.0.6
    - PingIntelligence 4.4.1
    - PingDelegator 4.7, 4.4.1
