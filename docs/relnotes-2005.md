# Release notes

## DevOps Docker builds, version 2005 (May 2020)

### New Features

- **PingDelegator Docker Image**

  The PingDelegator Docker image is now available. View on [Docker Hub](https://hub.docker.com/r/pingidentity/pingdelegator) for more information.

  Test drive PingDelegator using the supplied docker-compose file in our [simple-stack](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose/01-simple-stack) example.
  
- **PingAccess Image version 6.0.2**

  We've updated the PingAccess Image to version 6.0.2.
  
- **Docker Builds Pipeline**

  We've made a number of CI/CD enhancements to improve Image qualification (smoke/integration tests).
  
- **Image Enhancements**

  Improved the `wait-for` command to optionally wait for a path or file to become available.
  
- **PingFederate version 9.3.3**

  We've updated the PingFederate 9.3.3 Docker image to include patch 4.

### Resolved defects

- (GDO-187) Resolved issue where MAX_HEAP_SIZE wasn't applied during container restart.

- (GDO-220) Resolved issue where log message didn't contain log file source name.

- (GDO-238) Resolved issue where ping-devops kubernetes start fails if DNS_ZONE variable not set.

- (GDO-245) Resolved issue where PingAccess didn't exit when configuration import failed.

- (GDO-263) Resolved issue within deploy_docs.sh which had resulted in some documentation to not be pushed to GitHub.

- (GDO-278) Resolved issue with PingAccess clustering Server Profile.
