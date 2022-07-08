---
title: Docker Compose
---
# Docker Compose

!!! error "Deprecation"
    Docker Compose has been used by Ping in the past for basic orchestration and examples.  We are no longer maintaining multi-product or clustering docker compose examples.  All of those files have been removed from this repository. The only examples remaining are for deploying individual products.  For orchestration of multiple products, clustering and other use cases, use helm to deploy to Kubernetes.

Example docker compose files to deploy standalone instances of PingAccess, PingCentral, PingDirectory or PingFederate are in the [Github repository](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose/00-standalone). Refer to the comments in the provided file for instructions on accessing the product after running `docker compose up` from the directory of the product in which you are interested.

For more information about the structure of Docker Compose YAML files provided by Ping, see [this page](../reference/yamlFiles.md)
