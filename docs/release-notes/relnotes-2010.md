---
title: Devops Docker Builds, Version 2010 (October 2020)
---
# Release Notes

## Devops Docker Builds, Version 2010 (October 2020)

### New Features

- **PingIdentity Helm Charts**

      Looking to deploy the PingDevOps stack into your Kubernetes cluster? We've published our [Helm Charts](https://helm.pingidentity.com) to help streamline deployment.

- **PingIntelligence (ASE) Docker Image**

      PingIntelligence (ASE) is now available on DockerHub! Pull the 4.3 ASE image [Here](https://hub.docker.com/r/pingidentity/pingintelligence).

- **PingFederate Bulk API Configuration Management**

      We've added tooling and documentation for managing PingFederate configuration using the build API export and import. View the latest documentation [Here](../how-to/buildPingFederateProfile.md).

### Enhancements

- **PingFederate**
      - Version 10.0.6 now available.
      - Image now includes tcp.xml.subst for cluster parameterization.
      - Updated image to support easier enablement/use of Bouncy Castle FIPS provider with PingFederate.

- **PingAccess**
      - Version 6.1.3 is now available.

- **LDAP SDK**
      - Updated to version 5.1.1

- **ping-devops CLI**
      - Added functionality to generate K8s license and version secret directly from the evaluation license service.
      - Added ACCEPT_EULA value to K8s devops-secret.

### Resolved Defects

- (GDO-411) Resolved issue where access token was logged when using private Git repository.
- (GDO-444) Resolved PingDirectory issue with keystore exception on restart.
- (GDO-491) Removed GPG from base Docker image.
- (GDO-495) Removed gosu from base Docker image.
- (GDO-513) Resolved issue with replication topology list on PingDirectory restart.
