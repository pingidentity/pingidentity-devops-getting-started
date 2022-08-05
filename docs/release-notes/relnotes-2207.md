---
title: DevOps Docker Builds, Version 2207 (August 05 2022)
---

# Version 2207 Release Notes

!!! note "Product release notes"
    For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2207 (August 05 2022)

### New Product Releases
- PingFederate 11.1.1 released ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingData products 9.0.0.2 released
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Documentation
- Added [documentation for using extensions with PingData server profiles](https://devops.pingidentity.com/how-to/profilesPingDataExtensions/)
- Split the [Helm example](https://devops.pingidentity.com/deployment/deployHelm/) pingaccess-cluster.yaml to more accurately represent what the file accomplishes, and added a pingaccess-pingfederate-integration.yaml example.
- (BRASS-486) Added clarification for pingtoolkit initContainer security context to the [Openshift documentation in the Helm portal](https://helm.pingidentity.com/config/openshift/)
- (BRASS-497) Added [documentation about container logging](https://devops.pingidentity.com/reference/containerLogging/)
- (BRASS-501) Added new [Helm examples](https://devops.pingidentity.com/deployment/deployHelm/) to replace old docker compose and kustomize examples.
    - pingauthorize-pingdirectory.yaml
    - pingdataconsole-pingone-sso.yaml
    - pingdatasync-failover.yaml
    - pingcentral-external-mysql-db
    - pingdirectory-upgrade-partition
- (BRASS-490) The documentation portal was extensively updated for grammar, examples, and validation

### Enhancements
- (BRASS-508) PingFederate and PingAccess now use the heartbeat from the API for the startup success check (rather than a fixed timeout). Added a new variable $ADMIN_WAITFOR_TIMEOUT (default 300 seconds) as a backstop against a hung startup process in the 80-post-start.sh script.
- Liberica JDK -> 11.0.16+8
- Alpine -> 3.16.1
- Apache Tomcat in PingDataConsole -> 9.0.65

### Product Build Matrix
- See the [Product Version, Image Release Matrix](https://docs.google.com/spreadsheets/d/e/2PACX-1vSvySYHZxK-NOMeOMKSVjZWRr64T4raSNfrkcxdTRUxsftSwKgAN5z_gQarxywjIPJaVG8WJMt7ehXI/pub?output=pdf)
  for currently supported image and product versions.
