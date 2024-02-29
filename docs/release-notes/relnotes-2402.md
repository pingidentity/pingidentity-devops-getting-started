---
title: DevOps Docker Builds, Version 2402 (Feb 29 2024)
---

# Version 2402 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2402 (Feb 29 2024)

### New Product Releases

- PingFederate 12.0.0 → 12.0.1
- PingFederate 11.3.4 → 11.3.5
- - PingData products 10.0.0.0 → 10.0.0.1
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))
- PingData products 9.3.0.4 → 9.3.0.5
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements

- Apache Tomcat 9.0.85 → 9.0.86

### Resolved Defects

- (PDI-1473) Fixed PingDataSync pods not configuring failover when REMOTE_SERVER_REPLICATION_PORT environment variable was not set. This variable now is not necessary for configuring failover.
- (PDI-1474) Updated PingData restart hook scripts to handle updating the java.properties file. If you need to set any custom values in java.properties, provide the entire file in your server profile at `instance/config/java.properties`. Note that this is outside of the `pd.profile` folder.
- (PDI-1476) Fixed an issue with processing env variable json files in the secrets directory where keys with special characters were not handled.

### Documentation

- (PDI-1477) Updated ingress definitions and how-to examples and guides to latest versions and formatting
- (PDI-1478) Removed stale helm repo files as well as updated helm documentation
- (PDI-1587) Remove extraneous reference to components now in baseline server profile.
- (PDI-1589) Update old link on the server profiles how-to page.

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
