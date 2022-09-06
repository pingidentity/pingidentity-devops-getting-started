---
title: DevOps Docker Builds, Version 2111.1 (December 16 2021)
---
# Version 2111.1 Release Notes

## DevOps Docker Builds, Version 2111.1 (December 16 2021)

### New Product Releases

- **PingAccess**
    - PingAccess 7.0.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess).

- **PingCentral**
    - PingCentral 1.8.1 is available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingcentral).

- **PingFederate**
    - PingFederate 11.0.0 is available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate).

### Enhancements

- **Docker Images**
    - Applied the log4j2 patch updated zip files to PingAccess and PingFederate per recommendation of the [Ping Identity CVE knowledge article](https://support.pingidentity.com/s/article/Log4j2-vulnerability-CVE-CVE-2021-44228).
    - The applied patches are available on the Ping Identity CVE knowledge article.
    - All images tagged with the sprint 2111.1 do not contain the Log4j2 vulnerability CVE-2021-44228.
    - Purged all DockerHub images vulnerable to the Log4j2 vulnerability CVE-2021-44228. This is to ensure all PingIdentity images published do not have the Log4j2 vulnerabilities.

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
