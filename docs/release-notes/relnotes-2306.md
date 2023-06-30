---
title: DevOps Docker Builds, Version 2306 (June 30 2023)
---

# Version 2306 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2306 (June 30 2023)

### New Product Releases
- PingFederate 11.3.0 released and PingFederate 11.1.x no longer built 11.2.5 → 11.2.6 EOL 10.3.7 and 11.3.0-Beta ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- PingAccess 7.3.0 released and PingAccess 7.1.x no longer built EOL 6.3.4 and 7.3.0-Beta ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingCentral 1.12.0 released and PingCentral 1.10.x no longer built EOL 1.9.3 and 1.8.2 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingcentral))
- PingData products 9.3.0.0 released and PingData products 9.1.0.x are no longer built EOL 8.3.0.6
    - PingDirectory ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectory))
    - PingDirectory Proxy ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdirectoryproxy))
    - PingDataSync ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdatasync))
    - PingAuthorize ([Dockerhub](https://hub.docker.com/r/pingidentity/pingauthorize))
    - PingDataConsole ([Dockerhub](https://hub.docker.com/r/pingidentity/pingdataconsole))
- PingDelegator EOL 4.6.0

### Enhancements
- Apache JMeter 5.5 → 5.6
- LDAP SDK 6.0.8 → 6.0.9
- Apache Tomcat 9.0.75 → 9.0.76
- Alpine 3.18.0 → 3.18.2

### Documentation
- Updated [Create a simple local Kubernetes Cluster](https://devops.pingidentity.com/deployment/deployLocalK8sCluster/#install-and-configure-minikube) kind and minikube examples to reflect latest releases and supported backends
- Updated [Deploy a robust local Kubernetes Cluster](https://devops.pingidentity.com/deployment/deployFullK8s/#configure-ansible-playbooks-for-your-environment) 3-VM Kubernetes example to use Ansible

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
