---
title: DevOps Docker Builds, Version 2205 (June 02 2022)
---
# Version 2205 Release Notes

## DevOps Docker Builds, Version 2205 (June 02 2022)

### New Product Releases

- **PingAccess**
    - PingAccess 7.0.4 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess).
- **PingData products**
    - Updated all PingData products to build 8.3.0.6
- **PingFederate**
    - PingFederate 11.0.3 and 10.3.7 are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate).
- **PingIdentity LDAPSDK**
    - PingIdentity LDAPSDK upgraded to 6.0.5 in Docker image [Dockerhub](https://hub.docker.com/r/pingidentity/pingidentity).

### Documentation
- [Sidecar Example](https://devops.pingidentity.com/deployment/deployK8sUtilitySidecar/) created
    - Page with details and recommendations for using a sidecar, with example
- [Migrating root-based deployment documentation](https://devops.pingidentity.com/how-to/migratingRootToUnprivileged/) updated
    - Refined this page with recommendations of pre-migration steps


### Resolved Defects

- (BRASS-402) - Updates to PingAccess and PingFederate
  -  Updated the PingAccess and PingFederate builds to generate a run.properties.subst.default file based on the product default run.properties file pulled from /opt/server. This ensures that any other defaults in the product are included in the default run.properties. This change allows for setting the PingAccess operational mode through the OPERATIONAL_MODE environment variable, without requiring a server profile.
- (BRASS-428) - PingAccess FIPS mode properties issues
  - Updated the default FIPS properties file for PingAccess to use the correct filename and the correct property name to enable FIPS mode.

### Enhancements
- **Docker Images**
    - Apache Tomcat to Version 9.0.63
    - Alpine to version 3.16.0

###Features
- (BRASS-434) Support Null SecurityContext in Helm Charts for Openshift
    - Enables the helm charts to generate with workload.securityContext as null, permitting the Openshift environment to generate the security context properly.
        

### Product Build Matrix

- See the [Product Version, Image Release Matrix](https://docs.google.com/spreadsheets/d/e/2PACX-1vSvySYHZxK-NOMeOMKSVjZWRr64T4raSNfrkcxdTRUxsftSwKgAN5z_gQarxywjIPJaVG8WJMt7ehXI/pub?output=pdf)
for currently supported image and product versions.
