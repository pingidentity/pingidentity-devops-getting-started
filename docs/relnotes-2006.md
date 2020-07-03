# Release notes

## DevOps Docker builds, version 2006 (June 2020)

### New Features

- **Docker Compose Volumes**

  Applications that create and manage configuration now have mounted volumes in Docker-Compose [examples](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose/), ensuring that your configuration changes are persisted across restarted.

- **PingAccess Image Enhancements**

  We've updated the PingAccess Image to support the new features available in version 6.1.

- **Customer Support Data Collection**

  Included in this release is the Java diagnostic tool to enable embedded customer support data collection. This tool set inculdes [jstat](https://docs.oracle.com/javase/7/docs/technotes/tools/share/jstat.html), [jmap](https://docs.oracle.com/javase/7/docs/technotes/tools/share/jmap.html) and [jhat](https://docs.oracle.com/javase/7/docs/technotes/tools/share/jhat.html)

### New Product Versions

  The following new product versions are available using **edge**, **latest** and **2006** image tags:

- **PingFederate 10.1.0**

- **PingAccess 6.1.0**

- **PingDirectory 8.1.0.0**

- **PingDirectoryProxy 8.1.0.0**

- **PingDataGoverance 8.1.0.0**

- **PingDataGoverance 8.1.0.0 PAP**

- **PingDataSync 8.1.0.0**

- **PingCentral 1.4.0**

### Improvements

- **Liveness Check**

  We've made improvements to PingDirectory's liveness check to better inform dependant services on the status of the Directory service.

- **Docker Build Pipeline**

  - We've published [documentation](https://pingidentity-devops.gitbook.io/devops/deploy/buildlocal) on how to build a Ping Identity Docker Image using a local zip artifact.

  - We have improved our reference pipeline to allow for the build of a single product.

  - We've made several CI/CD enhancements to improve Image qualification (smoke/integration tests).

- **Configuration Substitution**

  We've made enhancements to explicitly send the variables to be substituted.

### Resolved defects

- (GDO-218) Resolved an issue where PingDirectory threw an error on manage-profile during setup

- (GDO-289) Resolved an issue where Alpine based image couldn't install pip3

- (GDO-329) Resolved an issue where PingCentral docs were not syncing to GitHub
