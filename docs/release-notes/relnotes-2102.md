---
title: DevOps Docker Builds, Version 2102 (February 2021)
---
# Release Notes

## DevOps Docker Builds, Version 2102 (February 2021)

### Enhancements

- **PingFederate**
      - Support for creation and loading of certificates for admin.
      - Version 10.2.2 is now available.

- **PingAccess**
      - Baseline now has clustering support.
      - Version 6.1.4 is now available.

- **PingDirectory**
      - Improve speed of replace-profile process during PingDirectory restart.
      - Indexes are automatically rebuilt upon server restart.
      - Version 8.2.0.2 is now available.

- **PingDataGovernance**
      - Helm charts have been added for the PingDataGovernance policy editor.
      - Version 8.2.0.2 is now available.

- **PingDataSync**
      - Version 8.2.0.2 is now available.

### Resolved Defects

- (GDO-382) - Resolved issue where PingDirectory is unable to restart when upgrading 7.3 to 8.1 due to a license error.
- (GDO-543) - Updated "Related Docker Images" documentation in PAP Dockerfile.
- (GDO-672) - Resolved issue with 'manage-profile setup' signaling a dsconfig error.
- (GDO-680) - Resolved issue with PingDirectory set_server_available and set_server_unavailable methods being very.
- (GDO-311) - Updated 05-expand-templates.sh to no longer build data.zip if a _data.zip_ directory is found in the profile.

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | <b>6.2.0</b><br/>6.1.4 | 6.1.3 |
| PingCentral | <b>1.6.0</b><br/>1.5.0 |  |
| PingDataConsole | <b>8.2.0.2</b><br/>8.1.0.3 | 8.2.0.1<br/> |
| PingDataGovernance | <b>8.2.0.2</b><br/>8.1.0.3 | 8.2.0.1<br/> |
| PingDataGovernance PAP |  <b>8.2.0.2</b><br/>8.1.0.3 | 8.2.0.1<br/> |
| PingDataSync |  <b>8.2.0.2</b><br/>8.1.0.3 | 8.2.0.1<br/> |
| PingDelegator | <b>4.4.0</b> | 4.2.1 |
| PingDirectory |  <b>8.2.0.2</b><br/>8.1.0.3 | 8.2.0.1<br/> |
| PingDirectoryProxy |  <b>8.2.0.2</b><br/>8.1.0.3 | 8.2.0.1<br/> |
| PingFederate | <b>10.2.2</b><br/>10.1.4 | 10.2.1 <br/>|
| PingIntelligence | <b>4.4</b> |  |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
