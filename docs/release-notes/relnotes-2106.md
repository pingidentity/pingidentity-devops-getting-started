---
title: DevOps Docker Builds, Version 2106 (July 6 2021)
---
# Release Notes

## DevOps Docker Builds, Version 2106 (July 6 2021)

### New Features

- **ARM-Based Images**
    - Ping Identity now offers ARM-based Docker images!
    - These images are currently experimental and are **not intended for production deployment**
    - View the available tags on [Dockerhub](https://hub.docker.com/r/pingidentity/)

- **PingFederate**
    - PingFederate 10.3.0 and 10.2.4 are now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate)

- **PingAccess**
    - PingAccess 6.3.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess)

- **PingCentral**
    - PingCentral 1.8 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingcentral)

- **PingDelegator**
    - PingDelegator 4.6.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingdelegator)

- **PingIntelligence (ASE)**
    - PingIntelligence 5.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/pingintelligence)

- **PingData**
    - Version 8.2.5 has been released for all PingData products (Directory, DataSync, Proxy). View on  [Dockerhub](https://hub.docker.com/r/pingidentity)

- **LDAP SDK**
    - LDAP SDK 6.0.0 is now available on [Dockerhub](https://hub.docker.com/r/pingidentity/ldap-sdk-tools)

### Enhancements

- **PingFederate**
      - Allow logging level to be set via an environment variable (PF_LOG_LEVEL)
      - Added property `pf.admin.baseurl` to run.properties configuration file
      - Added ability to generate the run.properties and jvm-memory.options files based on supplied environment variables

- **HEAP Awareness**
      - PingAccess, PingCentral, and JMeter images can now calculate the heap based on the memory allocated to the container

- **Java Tools**
      - Added jcmd, jstat, jinfo, jmap, jps, jstack tools to images

- **Docker-Compose**
      - Added tmpfs secrets directory to all of the docker-compose examples in the [Getting-Started](https://github.com/pingidentity/pingidentity-devops-getting-started) repository

### Resolved Defects

- (GDO-657) - Resolved PingDelegator self-signed certificate issue
- (GDO-834) - Resolved issue where PingDataConsole doesn't build correctly when providing a local product.zip file
- (GDO-836) - Resolved issue where PingDirectory restart failed due to startup hook syntax error
- (GDO-885) - Resolved HTTPS/LDAPS port variables in PingAuthorize profiles to support Helm charts

### Product Build Matrix

The following table includes product versions and their accompanying Image build status for this release.

| Product | Active Build | Build EOL |
|------|------|------|
| PingAccess | <b>6.3.0</b><br/>6.2.1 | 6.3.0-Beta<br/>6.1.4 |
| PingAuthorize | <b>8.3.0.0</b> |  |
| PingAuthorize PAP | <b>8.3.0.0</b> |  |
| PingCentral | <b>1.8.0</b><br/>1.7.0 | 1.6.0 |
| PingDataConsole | <b>8.3.0.0</b><br/>8.2.0.5 | 8.3.0.0-EA<br/>8.2.0.3<br/>8.1.0.3  |
| PingDataGovernance | <b>8.2.0.5</b> | 8.2.0.3<br/>8.1.0.3 |
| PingDataGovernance PAP | <b>8.2.0.5</b> | 8.2.0.3<br/>8.1.0.3 |
| PingDataSync | <b>8.3.0.0</b><br/>8.2.0.5 | 8.3.0.0-EA<br/>8.2.0.3<br/>8.1.0.3 |
| PingDelegator | <b>4.6.0</b><br/>4.4.1 | 4.5.0<br/>4.4.1<br/>4.2.1  |
| PingDirectory |  <b>8.3.0.0</b><br/>8.2.0.5 | 8.3.0.0-EA<br/>8.2.0.3<br/>8.1.0.3 |
| PingDirectoryProxy |  <b>8.3.0.0</b><br/>8.2.0.5 | 8.3.0.0-EA<br/>8.2.0.3<br/>8.1.0.3 |
| PingFederate | <b>10.3.0</b><br/>10.2.4  | 10.3.0-Beta<br/>10.2.3<br/>10.1.5 |
| PingIntelligence | <b>5.0</b><br/>4.4.1 | 4.4 |

!!! info "Build Matrix Info"
    * <b>Bolded</b> product version number is version within 'latest' image tag.
    * Build EOL denotes product versions that are no longer built as of this release.
