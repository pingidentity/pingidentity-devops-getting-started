---
title: DevOps Docker Builds, Version 2310 (Nov 1 2023)
---

# Version 2310 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each
product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2310 (Nov 1 2023)

### New Product Releases

- PingAccess 7.3.1 -> 7.3.2
- PingIntelligence 5.1.1 -> 5.1.3
- PingData products 9.3.0.1 -> 9.3.0.2
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))

### Enhancements

- Apache Tomcat 9.0.80 -> 9.0.82
- Liberica JDK11 11.0.20.1+1 -> 11.0.21+10
- Liberica JDK17 17.0.8.1+1 -> 17.0.9+11

### Features

- (BRASS-1303) Added support for PingDirectoryProxy joining a multi-region PingDirectory topology.

    - The PingDirectoryProxy servers can also be across multiple regions. The PingDirectoryProxy
      servers should not be started until the PingDirectory topology is up and ready.

    - The same variables used to run PingDirectory in multiple regions
      are used by PingDirectoryProxy. In addition, the following variables
      must be defined:

        ```text
        JOIN_PD_TOPOLOGY: Set to true to join a PingDirectory topology
        PINGDIRECTORY_HOSTNAME: Hostname of a PingDirectory server in the topology
        PINGDIRECTORY_LDAPS_PORT: LDAPS port of the PingDirectory server to join
      
        Added the LOAD_BALANCING_ALGORITHM_NAMES variable to PingDirectory,
        which allows defining what load balancing algorithms to set on the server instance,
        separated by semicolons. This variable is only needed when using PingDirectoryProxy
        automatic server discovery
      
        This change also removes the requirement for PingDirectory to identify
        a topology master server when enabling replication. It will instead
        always join via the seed server.
        ```

### Resolved Defects

- (BRASS-1287) Updated helm chart to support removed batch API endpoint designation in Kubernetes 1.25
- (BRASS-1239) Corrected broken links on Ping DockerHub repositories

### Documentation

- (BRASS-1217) Added demonstration
  for [Archiving and Retrieving Backups from S3](https://devops.pingidentity.com/how-to/s3Archive/)

### Supported Product Releases

- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
