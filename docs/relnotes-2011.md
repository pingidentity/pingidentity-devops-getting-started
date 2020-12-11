# Release Notes

## Devops Docker Builds, Version 2011 (November 2020)

### New Features

- **Internal XRay Scanning**

      We've automated the process to scan all Sprint Release Docker Images for CVE's

### Enhancements

- **PingFederate**
      - Version 10.1.3 now available.
      - Parameterized run.properties, ldap.properties and tcp.xml now included in Docker Image

- **Helm Charts**
      - We added a number of enhancements to our Helm charts. See the [Helm Release Notes](https://helm.pingidentity.com/release-notes/) for details.

- **Misc.**
      - Updated EULA check to be case insensitive
      - Add Java back into pingtoolkit Image
      - Updated example docker run commands in Dockerfile documentation
      - Info message when Server Profile URLs are not present

### Resolved Defects

- (GDO-549) - Resolved issue where SCIM Swagger test pages don't work in PingDataGovernance Docker Image
- (GDO-567) - Resolved issue where changes made to PingDirectory's java.properties were erased on container restart
- (GDO-599) - Change wait-for localhost to use IP address
- (GDO-604) - Modified simple-sync server profile to work in Kubernetes environment with different service names
- (GDO-606) - Resolved issue where copy of server bits throws errors when running under non-root security context

