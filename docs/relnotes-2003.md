# Release notes
## DevOps Docker builds, version 2003

### New Features

- **PingDirectoryProxy**

  The PingDirectoryProxy Docker image is now available. See the [Ping Identity Docker hub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy).
  
- **PingCentral**

  The PingCentral Docker image is now available. See the [Ping Identity Docker hub](https://hub.docker.com/r/pingidentity/pingcentral).
  
- **Docker Compose port mappings**

  We now support the Docker Compose best practice of quoting all port mappings.
  
- **Docker images (Tag: edge)**

  We've built a pipeline to support nightly public builds of all Ping Identity Docker images using the `edge` tag.
  
- **PingDirectory**

  **We've upgraded the PingDirectory Docker image to the current product version 8.0.0.1.**
  
- **PingFederate version 10.1.0**

  We've built a beta PingFederate 10.1.0 Docker image.
  
- **PingAccess version 6.1.0**

  We've built a beta PingAccess 6.1.0 Docker image.
  
- **Ping Tool Kit**

  The Ping Tool Kit Docker image is now available. See the [Ping Identity Docker hub](https://hub.docker.com/r/pingidentity/pingtoolkit). Both `kubectl` and `kustomize` are supported in the image.
  
- **PingFederate version 9.3**

  We've updated the PingFederate 9.3 Docker image to include the latest product patches.
  
- **The ping-devops utility**

  We've added Kubernetes license secret generation, and server profile generation for PingDirectory  to the ping-devops utility. See [The ping-devops utility](https://pingidentity-devops.gitbook.io/devops/devopsutils/pingdevopsutil).
  
- **A new hook**

  We've added a security start-up hook notifying administrators of keys and secrets found in the server profile.
  
- **DevOps evaluation license**

  We've added retry functionality to attempt getting the DevOps evaluation license if the initial request fails.
  
- **Product artifacts and extensions**

  We've created operations to retrieve product artifacts and extensions using the DevOps credentials.
  
- **Java 11**

  We've migrated all Alpine-based Docker images to Java 11 (Azul).
  
- **PingDirectory replication timing**

  We've added a profile and reference example to test PingDirectory replication timing. See [the pingidentity-devops-getting-started repo](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/20-kubernetes/11-pingdirectory-replication-timing).
  
- **Docker base image security**

  We've documented an evaluation of Docker base image security. See [Evaluation of Docker base image security](https://pingidentity-devops.gitbook.io/devops/config/dockerimagesecurity).

### Resolved defects

- (GDO-85) Resolved an issue where PingAccess 6.0 loaded a 5.2 license.
  
- (GDO-87) Resolved an issue where Data Console wasn't allowing users to authenticate (edge tag).
  
- (GDO-124) Resolved an issue in with pipeline where starting containers using Docker-Compose timed out.
  
- (GDO-89) Resolved an issue where `*.subst` template files were able to overwrite the server profile configuration.
  
- (GDO-72) Resolved an issue where `motd.json` did not parse correctly when the product was missing.
  
- (GDO-88) Resolved an issue where PingFederate profile metadata did not expand `hostname`, breaking OAuth flows.
  
### Changed

- (GDO-97) Removed WebConsole HTTP servlet from the baseline server profile. See [the pingidentity-server-profiles repo](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline).

### Qualified

- (GDO-42) Verified the ability to run our Docker containers as a non-root user. See [Securing the containers](https://pingidentity-devops.gitbook.io/devops/config/securecontainers).
