---
title: Devops Docker Builds, Version 2104 (April 2021)
---
# Release Notes

## Devops Docker Builds, Version 2104 (April 2021)

### New Features

- **Early Access and Beta Release Docker Images**
    - PingAccess 6.3.0-Beta
    - PingAuthorize 8.3.0.0-EA
    - PingAuthorize PAP 8.3.0.0-EA
    - PingDataConsole 8.3.0.0-EA
    - PingDataSync 8.3.0.0-EA
    - PingDirectory 8.3.0.0-EA
    - PingDirectoryProxy 8.3.0.0-EA
    - PingFederate 10.3.0-Beta

### Enhancements

- **`watch-fs-changes`**
    - We've updated the `watch-fs-changes` utility to accept command-line parameters to watch additional locations

- **Startup Time Performance**
    - We've updated the start-server.sh script to improve container start up times for all PingData products.

- **Helm Charts for PingDirectoryProxy**
    - PingDirectoryProxy has been integrated into Ping's [Helm Charts](https://helm.pingidentity.com)

### Resolved Defects

- (GDO-649) - Resolved issue where the provided self-signed certificates for PingDataConsole didn't function in Chrome on MacOS
- (GDO-770) - Resolved issue where PingDataConsole didn't log console messages by default
- (GDO-773) - Resolved issue where the collect-support-data tool couldn't find the required JDK

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | <b>6.2.1</b><br/>6.1.4 |  |
| PingCentral | <b>1.7.0</b><br/>1.6.0 |  |
| PingDataConsole | <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDataGovernance | <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDataGovernance PAP |  <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDataSync |  <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDelegator | <b>4.4.0</b> |  |
| PingDirectory |  <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingDirectoryProxy |  <b>8.2.0.3</b><br/>8.1.0.3 |  |
| PingFederate | <b>10.2.2</b><br/>10.1.5 | |
| PingIntelligence | <b>4.4</b> |  |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
