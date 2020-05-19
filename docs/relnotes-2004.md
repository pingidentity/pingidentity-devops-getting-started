# Release notes
## DevOps Docker builds, version 2004

### New Features

- **Hashicorp Vault**

  We've built an integration for Hashicorp Vault. See the [Deploy Hashicorp Vault](deployVault.md).
  
- **PingCentral**

  The PingCentral Docker image is now available. See the [Ping Identity Docker hub](https://hub.docker.com/r/pingidentity/pingcentral).
  
- **Docker Compose**

  We've standardized our Docker Compose references.
  
- **Performance**

  We've built a performance framework.
  
- **PingFederate version 10.0.2**

  We've updated the PingFederate 10 Docker image for the 10.0.2 release.
   
- **The ping-devops utility**

  We've added major enhancements to our ping-devops utility. See [The ping-devops utility](https://pingidentity-devops.gitbook.io/devops/devopsutils/pingdevopsutil).
  
- **PingDirectory replication**

  We've added support for PingDirectory replication using Docker Compose.
  
- **Variables and scope**

  We've added documentation to help with understanding the effective scope of variables. See [Variables and scope](https://pingidentity-devops.gitbook.io/devops/config/variablescoping).

- **Elasticsearch SIEM stack**
    
  We've added documentation for our Elasticsearch SIEM stack. See [Deploy an Elasticsearch SIEM stack](https://pingidentity-devops.gitbook.io/devops/deploy/deploycompose/deploysiemstack). 

### Resolved defects

* (GDO-1) Resolved issue where users were unable to override root and admin user passwords (PingDirectory).

* (GDO-129) Removed the console from Ping Data products when the server profile isn't specified.

* (GDO-54) Resolved PingDataGovernance issues within the baseline server profile.

* (GDO-138) Resolved issue regarding PingDataGovernance Policy Administration Point (PAP) launch.

* (GDO-189) Resolved issue with PingAccess heartbeat check.

* (GDO-196) Replaced nslookup with getent due to issues running in Alpine.

* (GDO-180) Resolved issue where extension signature verification may return a false positive.

* (GDO-169) Resolved issues with Ping Data Console by upgrading to Tomcat 9.0.34.

* (GDO-166) Resolved issue with make-ldif template processing.
  
<!-- ### Changed

- (GDO-97) Removed WebConsole HTTP servlet from the baseline server profile. See [the pingidentity-server-profiles repo](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline).

### Qualified

- (GDO-42) Verified the ability to run our Docker containers as a non-root user. See [Securing the containers](https://pingidentity-devops.gitbook.io/devops/config/securecontainers). -->
