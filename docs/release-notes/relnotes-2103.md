---
title: DevOps Docker Builds, Version 2103 (March 2021)
---
# Release Notes

## DevOps Docker Builds, Version 2103 (March 2021)

### New Features

- **Images run as non-privileged user by default**

      _Critical:_ We've greatly improved the security of our images by having them run as a non-privileged user by default.  See [Migrating to Unprivileged Images](https://devops.pingidentity.com/how-to/migratingRootToUnprivileged/) for information about migrating existing deployments.

- **Layer simplification**

      We've consolidated layers in our images where possible.

### Enhancements

- **PingFederate**
      - The baseline image now uses data.json instead of the former use of the /data folder.
      - New variables have been added to run.properties for controlling provisioning failover and grace period.
      - Versions 10.1.5 and 10.3-Beta are now available.

- **PingAccess**
      - Versions 6.2.1 and 6.3-Beta are now available.

- **PingCentral**
      - Versions 1.7.0 is now available.

- **PingDirectory**
      - The number of layers present in the image has been reduced and simplified.
      - Version 8.2.0.3 is now available.

- **PingDataGovernance**
      - Version 8.2.0.3 is now available.

- **PingDataSync**
      - Version 8.2.0.3 is now available.

### Resolved Defects

- (GDO-742) - Resolved issue which may cause permissions errors creating files under /run/secrets during PingDirectory setup
- (GDO-746) - Resolved issue in which PingDirectory cannot rejoin its replication topology after restart
- (GDO-749) - Addressed documentation issue in which bulleted lists are not printed correctly

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | <b>6.2.1</b><br/>6.1.4 | 6.2.0 |
| PingCentral | <b>1.7.0</b><br/>1.6.0 | 1.5.0  |
| PingDataConsole | <b>8.2.0.3</b><br/>8.1.0.3 | 8.2.0.2<br/> |
| PingDataGovernance | <b>8.2.0.3</b><br/>8.1.0.3 | 8.2.0.2<br/> |
| PingDataGovernance PAP |  <b>8.2.0.3</b><br/>8.1.0.3 | 8.2.0.2<br/> |
| PingDataSync |  <b>8.2.0.3</b><br/>8.1.0.3 | 8.2.0.2<br/> |
| PingDelegator | <b>4.4.0</b> | 4.2.1 |
| PingDirectory |  <b>8.2.0.3</b><br/>8.1.0.3 | 8.2.0.2<br/> |
| PingDirectoryProxy |  <b>8.2.0.3</b><br/>8.1.0.3 | 8.2.0.2<br/> |
| PingFederate | <b>10.2.2</b><br/>10.1.5 | 10.1.4 <br/>|
| PingIntelligence | <b>4.4</b> |  |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
