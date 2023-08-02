---
title: DevOps Docker Builds, Version 2307 (Aug 2 2023)
---

# Version 2307 Release Notes

!!! note "Product release notes"
For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2307 (Aug 2 2023)

### New Product Releases
- PingAccess 7.2.1 → 7.2.2 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingFederate 11.3.0 → 11.3.1 and 11.2.6 → 11.2.7 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))
- [PingDirectory Terraform Provider](https://github.com/pingidentity/terraform-provider-pingdirectory/releases) v0.9.0 released 

### Enhancements
- Apache Tomcat 9.0.76 → 9.0.78 
- Apache JMeter 5.6 → 5.6.2 
- Liberica JDK11 11.0.19+7 → 11.0.20+8 
- Liberica JDK17 17.0.7+7 → 17.0.8+7

### Resolved Defects
- (BRASS-1088) Fix defect in [PingDirectory Backup Script](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/30-helm/pingdirectory-backup/pingdirectory-periodic-backup.yaml)
- (BRASS-1121) Fix helm ingress demo YAML annotation
- (BRASS-1124) Fix MOTD retrieval and notification script.
- (BRASS-1143) Update 85-import PA and PF script to have better error messaging upon import failure.

### Features
- (BRASS-1115 and BRASS-1116) Added new [pingaccess-env-config](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingaccess-env-config) and [pingfederate-env-config](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingfederate-env-config) server profiles that allow managing PingAccess and PingFederate configuration using environment variables in place of certain properties files.

### Documentation
- Updated [VPC Peering Configuration to Support Multi-Region AWS EKS Deployments](https://devops.pingidentity.com/deployment/deployK8s-AWS/) to define VPC peering configuration for Multi-region AWS EKS Deployments.
- Added documentation on [Running product containers with a read-only root filesystem¶](https://devops.pingidentity.com/reference/readOnlyFilesystem/).

### Supported Product Releases
- See the [Product Version, Image Release Matrix](../docker-images/productVersionMatrix.md)
  for currently supported image and product versions.
