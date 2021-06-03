---
title: Devops Docker Builds, Version 2105 (June 3 2021)
---
# Release Notes

## Devops Docker Builds, Version 2105 (June 3 2021)

### New Features

- **PingFederate**
    - PingFederate 10.2.3 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate)

- **PingDelegator**
    - PingDelegator 4.5.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdelegator)

### Resolved Defects

- (GDO-813) - Resolved issue where OAuth APIS were broken using baseline server profile and pingfederate:edge
- (GDO-818) - Resolved issue where users were unable to build images locally due to a file permission error
- (GDO-829) - Resolved issue where a `dsconfig` command was unable to run due to a quoting error

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | 6.3.0-Beta<br/><b>6.2.1</b><br/>6.1.4 |  |
| PingCentral | <b>1.7.0</b><br/>1.6.0 |  |
| PingDataConsole | 8.3.0.0-EA<br/><b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDataGovernance | <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDataGovernance PAP |  <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDataSync |  8.3.0.0-EA<br/><b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDelegator | 4.5.0<b>4.4.1</b><br/>4.2.1 |  |
| PingDirectory |  8.3.0.0-EA<br/>8.2.0.4<br/><b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDirectoryProxy |  8.3.0.0-EA<br/><b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingFederate | 10.3.0-Beta<b>10.2.3</b><br/>10.1.5 | 10.2.2 |
| PingIntelligence | <b>4.4</b> |  |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
