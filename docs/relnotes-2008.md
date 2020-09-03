# Release notes

## DevOps Docker builds, version 2008 (August 2020)

### New Features

- **Secret Management**

  A number of key enhancements have been made to natively support secret management within our Docker Images. See [documentation](https://pingidentity-devops.gitbook.io/devops/config/usingvault) for implementation details.

- **DevOps Development Mode**

  We've added a 'Continue on Failure' option to all Docker Images. This allows the Container to say alive while any potential issues are being investigated.

- **DevOps Program Registration**

  Signing up for the Ping DevOps program is now self-service! Simply follow the instructions found [here](https://pingidentity-devops.gitbook.io/devops/getstarted/prod-license#obtaining-a-ping-identity-devops-user-and-key)

### Improvements

- **Ping-DevOps Utility**

  We've added secret management commands to ping-devops, allowing you to quickly integrate secrets into your deployments.

- **Image Restart State**

  A number of enhancements have been made to improve the overall restart flow in our Docker Images

### Resolved defects

- (GDO-352) Resolved restart issue in PingDataGovernance PAP

- (GDO-392) Resolved issue within PingDelegator when DS_PORT variable was undefined

- (GDO-395) Resolved issue within PingDirectory restart when Java versions changed

- (GDO-397) Resolved issue where PingFederate failed to start in Kubernetes using the full-stack example

- (GDO-404) Resolved issue where some users were unable to log into the PingAccess console using the Image edge tag and Baseline server profile
