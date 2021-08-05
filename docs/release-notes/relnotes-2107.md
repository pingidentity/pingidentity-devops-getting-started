---
title: DevOps Docker Builds, Version 2107 (August 4 2021)
---
# Release Notes

## DevOps Docker Builds, Version 2107 (August 4 2021)

### New Features

- **PingFederate**
    - Added support for pf.admin.baseurl within baseline [Server Profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline)

- **PingAccess**
    - PingAccess 6.2.2 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess)

- **PingDirectory**
    - PingDirectory 8.3.0.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory)

- **PingDirectoryProxy**
    - PingDirectoryProxy 8.3.0.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy)

- **PingDataSync**
    - PingDirectory 8.3.0.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync)

- **PingAuthorize**
    - PingAuthorize 8.3.0.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize)

### Enhancements

- **PingDelegator**
      - Baseline now works on both local and Kubernetes environments

- **Helm Charts**
      - Release 0.6.7 - Probes & Ingress

### Resolved Defects

- (GDO-860) - Resolved issue where the PingAuthorize Policy Editor  auto-generated documentation uses wrong ports
- (GDO-907) - Restored functionality for prepending the name of the log file to each log line
- (GDO-887) - All Docker images are now signed

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | <b>6.3.0</b><br/>6.2.2 | 6.2.1 |
| PingAuthorize | <b>8.3.0.1</b> | 8.3.0.0 |
| PingAuthorize PAP | <b>8.3.0.1</b> | 8.3.0.0 |
| PingCentral | <b>1.8.0</b><br/>1.7.0 |  |
| PingDataConsole | <b>8.3.0.1</b><br/>8.2.0.5 | 8.3.0.0 |
| PingDataGovernance | <b>8.2.0.5</b> |  |
| PingDataGovernance PAP | <b>8.2.0.5</b> |  |
| PingDataSync | <b>8.3.0.1</b><br/>8.2.0.5 | 8.3.0.0 |
| PingDelegator | <b>4.6.0</b><br/>4.4.1 |   |
| PingDirectory |  <b>8.3.0.1</b><br/>8.2.0.5 | 8.3.0.0 |
| PingDirectoryProxy |  <b>8.3.0.1</b><br/>8.2.0.5 | 8.3.0.0 |
| PingFederate | <b>10.3.0</b><br/>10.2.4  |  |
| PingIntelligence | <b>5.0</b><br/>4.4.1 |  |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
