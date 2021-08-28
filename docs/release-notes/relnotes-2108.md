---
title: DevOps Docker Builds, Version 2108 (August 27 2021)
---
# Release Notes

## DevOps Docker Builds, Version 2108 (August 27 2021)

### New Features

- **PingFederate**
    - PingFederate 10.3.1 and 10.2.5 are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate)

- **PingAccess**
    - PingAccess 6.3.1 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess)

### Enhancements

- **Documentation**
    - Overview of a DevOps [operating pattern](../deployment/managePingFederate.md) that walks through persisting admin console changes while delivering server files from a GitHub profile.
    - Our DevOps documentation now supports both light and dark modes. Toggle between the two by clicking the icon in the top navigation bar.

- **Docker Images**
    - Upgraded the Image OS from Alpine 3.13 to 3.14

- **Helm Charts**
    - View the detailed release notes for Ping's Helm Charts [here](https://helm.pingidentity.com/release-notes)
        - Release 0.7.0 - ServiceAccount/Role/RoleBinding for testFramework
        - Release 0.7.1 - Public hostname/ports
        - Release 0.7.2 - PingFederate PF_ADMIN_PUBLIC_BASEURL variable
        - Release 0.7.3 - Support full definition of initContainers attributes in testSteps and finalStep
        - Release 0.7.4 - Set initContainer settings from values.yaml instead of hard coded templates

### Resolved Defects

- (GDO-945) - Resolved issue where PingCentral was unable to communicate with PingAccess in the docker-compose full-stack [example](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose/03-full-stack).
- (GDO-872) - Resolved issue in tooling when building images locally (`serial_build.sh`).

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | <b>6.3.1</b><br/>6.2.2 | 6.3.0 |
| PingAuthorize | <b>8.3.0.1</b> |  |
| PingAuthorize PAP | <b>8.3.0.1</b> |  |
| PingCentral | <b>1.8.0</b><br/>1.7.0 |  |
| PingDataConsole | <b>8.3.0.1</b><br/>8.2.0.5 | |
| PingDataGovernance | <b>8.2.0.5</b> |  |
| PingDataGovernance PAP | <b>8.2.0.5</b> |  |
| PingDataSync | <b>8.3.0.1</b><br/>8.2.0.5 | |
| PingDelegator | <b>4.6.0</b><br/>4.4.1 |   |
| PingDirectory |  <b>8.3.0.1</b><br/>8.2.0.5 | |
| PingDirectoryProxy |  <b>8.3.0.1</b><br/>8.2.0.5 | |
| PingFederate | <b>10.3.1</b><br/>10.2.5  | 10.3.0<br/>10.2.4 |
| PingIntelligence | <b>5.0</b><br/>4.4.1 |  |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
