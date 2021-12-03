---
title: DevOps Docker Builds, Version 2110 (November 01 2021)
---
# Release Notes

## DevOps Docker Builds, Version 2110 (November 01 2021)

### New Features

- **PingFederate**
    - PingFederate 10.3.3 and 10.2.7 are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate).


- **PingDirectory**
    - PingDirectory 8.3.0.3 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory).


- **PingAuthorize**
    - PingAuthorize 8.3.0.3 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize).


- **PingCentral**
    - PingCentral 1.9 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingcentral).


- **UnboundID LDAP SDK**
    - UnboundID LDAP SDK tool set 6.0.2 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/ldap-sdk-tools).


### Enhancements

- **Documentation**
    - Improved documenation around certificate rotation for PingDirectory.
    - Update DevOps support policy statement.


- **Docker Images**
    - Images that include Apache Tomcat have been updated to 9.0.54.
    - Startup time for PingDirectory has been improved.
    - PF_LDAP_USERNAME and PF_LDAP_PASSWORD variables are now required with PingFederate to promote best security practices.


- **Helm Charts**
    - View the detailed release notes for Ping's Helm Charts [here](https://helm.pingidentity.com/release-notes)
        - Release 0.7.7 - Update default security context group id to root.
        - Release 0.7.8 - Server profile updates, generate master password for Ping services.



### Resolved Defects

- (BRASS-72) - Resolved issue in which numbers were not rendered correctly in some cases in public docs.
- (BRASS-71) - Resolved issue in which PingDirectory seed name is not rendered
correctly.

### Product Build Matrix

- See the [Product Version, Image Release Matrix](../../reference/productVersionMatrix/)
for currently supported image and product versions.

- The following versions are not longer active maintained:
    - PingFederate 10.3.2, 10.2.6
    - PingDirectory and and PingAuthorize 8.3.0.2
    - PingCentral 1.7
