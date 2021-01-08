# Release Notes

## Devops Docker Builds, Version 2012 (December 2020)

### New Features

- **DevOps Documentation**

      We've moved from GitBook to MKDocs to provide a richer DevOps documentation experience.

### Enhancements

- **PingFederate**
      - Version 10.2 now available.

- **PingAccess**
      - Version 6.2 is now available.

- **PingDirectory**
      - Version 8.2.0 is now available.

- **PingDataGovernance**
      - Version 8.2.0 is now available.

- **PingDataSync**
      - Version 8.2.0 is now available.

- **PingCentral**
      - Version 1.6.0 is now available.

- **LDAP SDK**
      - Version 5.1.3 is now available.
      - Updated to latest Tomcat version.

- **PingData Console SSO Example**
      - We've provided an example of running the Admin Console in Docker with SSO configured.

### Resolved Defects

- (GDO-362) Resolved issue where PingDirectory instances become active prior to being fully synchronized.
- (GDO-544) Resolved issue where PingDataGovernance PAP images' MAX_HEAP_SIZE variable had no effect.
- (GDO-618) Resolved issue where base layer was missing JMX agent.
- (GDO-640) Resolved issue where wait-for command didn't honor timeout when waiting for host:port.
