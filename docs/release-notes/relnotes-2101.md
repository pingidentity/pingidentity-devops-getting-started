# Release Notes

## Devops Docker Builds, Version 2101 (January 2021)

### Enhancements

- **PingFederate**
      - Versions 10.2.1 and 10.1.4 are now available.

- **PingDirectory**
      - Versions 8.2.0.1 and 8.1.0.3 are now available.
      - PingDirectory now delays its readiness state until replication has completed (Kubernetes).
      - Improved container restart time by regenerating java.properties only when changes are made to JVM or JVM options.

- **PingDataGovernance**
      - Versions 8.2.0.1 and 8.1.0.3 are now available.

- **PingDataSync**
      - Versions 8.2.0.1 and 8.1.0.3 are now available.

- **PingDelegator 4.4.1**
      - Version 4.4.1 is now available.

- **LDAP SDK**
      - Version 5.1.3 is now available.

- **Container Secrets**
      - Sourcing of secret_envs is now recursive.

### Resolved Defects

- (GDO-577) - Resolved issue to suppress environment variables in cn=monitor for PingData products.
- (GDO-658) - Enhanced error messages returned by the evaluation license service.
- (GDO-659) - Resolved issue where evaluation license server used incorrect calculation for checking image expiration.
- (GDO-668) - Resolved issue where remnants of previous server profile remained in place when restarting a container.
- (GDO-674) - Resolved issue where hashing contents of the SECRETS_DIR risked leaving passwords stored insecurely on the container filesystem.

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | <b>6.2.0</b><br/>6.1.3 |  |
| PingCentral |<b>1.6.0</b><br/>1.5.0 |  |
| PingDataConsole | <b>8.2.0.1</b><br/>8.1.0.3 | 8.2.0.0<br/>8.1.0.0 |
| PingDataGovernance | <b>8.2.0.1</b><br/>8.1.0.3 | 8.2.0.0<br/>8.1.0.0 |
| PingDataGovernance PAP |  <b>8.2.0.1</b><br/>8.1.0.3 | 8.2.0.0<br/>8.1.0.0 |
| PingDataSync |  <b>8.2.0.1</b><br/>8.1.0.3 | 8.2.0.0<br/>8.1.0.0 |
| PingDelegator | <b>4.4.0</b> | 4.2.1 |
| PingDirectory |  <b>8.2.0.1</b><br/>8.1.0.3 | 8.2.0.0<br/>8.1.0.0 |
| PingDirectoryProxy |  <b>8.2.0.1</b><br/>8.1.0.3 | 8.2.0.0<br/>8.1.0.0 |
| PingFederate | <b>10.2.1</b><br/>10.1.4 | 10.2.0 <br/>10.1.3|
| PingIntelligence | <b>4.4</b> |  |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
