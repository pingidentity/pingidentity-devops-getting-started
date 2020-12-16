# Release Notes

## DevOps Docker Builds, Version 2007 (July 2020)

### New Features

- **Signed Docker Images**

      All DockerHub Images are now signed and conform to the Docker Content Trust [Specification](https://docs.docker.com/engine/security/trust/content_trust/).

- **Variablize PingAccess Ports**

      We've updated the PingAccess start up hooks to allow users to customize application ports.

- **PingAccess Upgrade Utility**

      The PingAccess upgrade utility is now part of Docker Image.

- **Certificate Management**

      Add consistency and flexibility with the injection of certs/pins.

- **Docker Image Startup Flexibility**

      We've added the ability for end users to customize the startup sequence for Docker Images using **pre** and **post** hooks. See our [Documentation](../reference/hooks.md) for implementation details.

### Improvements

- **Docker Build Pipeline**

      We've made several CI/CD enhancements to improve Image qualification (smoke/integration tests).

### Resolved Defects

- (GDO-345) Resolved issue where PingDelegator was using PRIVATE rather than PUBLIC hostnames.
- (GDO-346) Resolved issue regarding the default minimum heap for PingDirectory.
- (GDO-380) Resolved issue within PingAccess Clustering (Admin Console) Kubernetes examples.
- (GDO-371) Resolved issue where PingDelegator wouldn't start using non-privileged user.
