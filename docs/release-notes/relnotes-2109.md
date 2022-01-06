---
title: DevOps Docker Builds, Version 2109 (October 06 2021)
---
# Release Notes

## DevOps Docker Builds, Version 2109 (October 06 2021)

!!! warning "Notice"
    * PingFederate deployments prior to sprint release 2108 (Aug 27th, 2021) may be at risk. Please visit [here](https://support.pingidentity.com/s/article/SECADV028-PingFederate-XML-Processing-Bypass) for details on impacted and patched versions.

### New Features

- **PingFederate**
    - PingFederate 10.3.2 and 11.0 Beta are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate)


- **PingAccess**
    - PingAccess 6.3.1 and 7.0 Beta are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess)


- **PingDirectory**
    - PingDirectory 8.3.0.2, 8.2.0.6, and 9.0 EA are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory)


- **PingAuthorize**
    - PingAuthorize 8.3.0.2, 8.2.0.6, and 9.0 EA are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize)


- **PingIntelligence**
    - PingIntelligence 5.0.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingintelligence)


### Enhancements

- **Documentation**
    - Improved [Introduction to Image/Container anatomy](../../reference/config/)



- **Docker Images**
    - JDK Liberica 11.0.12+7 is now supported
    - Images now include a startup probe script /opt/startup.sh


- **Helm Charts**
    - View the detailed release notes for Ping's Helm Charts [here](https://helm.pingidentity.com/release-notes)
        - Release 0.7.6  - Support for scheduler name on pods


- **Kubernetes**
    - PingDirectory now waits for its pod DNS hostname to match expected K8 pod IP


### Resolved Defects

- (GDO-896) - Resolved issue where PingDirectory failed to pick up the product license during deployment
- (GDO-989) - Resolved issue in which PingDirectory seed failure in multi-region topology causes a replication island

### Product Build Matrix

- See the [Product Version, Image Release Matrix](../../reference/productVersionMatrix/)
for currently supported image and product versions.

- The following versions are no longer actively maintained:
    - PingFederate 10.3.1, 10.2.4
    - PingAccess 6.3.0
    - PingDirectory and and PingAuthorize 8.3.0.1, 8.2.0.5
    - PingIntelligence 5.0.0
