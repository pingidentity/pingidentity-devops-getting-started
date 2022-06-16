---
title:  Troubleshooting
---
# Troubleshooting

## Getting started

### Examples Not Working

One of the most common errors is from having stale images. Our development is highly dynamic and Docker images can rapidly change.

To avoid issues with stale images and have Docker pull the latest images by removing all the local, enter:

  ```shell
  docker rmi $(docker images "pingidentity/*" -q)
  ```

> Having images tagged as "latest" locally does not mean they are the latest in the Docker hub registry.

### Misconfigured `pingctl`

If your containers can't pull a license based on your DevOps user name and key, there might be some misconfiguration in your `pingctl config` file.

Possible solutions:

1. If you have *just* run `pingctl config` for the first time. See the [Environment Configuration Documentation](https://devops.pingidentity.com/get-started/prereqs/#configure-the-environment) on how to export configured variables to your environment.

1. Run `pingctl info` and make sure the configured variables in the utility are correct. See the utility's [Documentation](https://devops.pingidentity.com/tools/pingctlUtil/) for more information.

### Unable To Retrieve Evaluation License

If a product instance or instances can't get the evaluation license, you might receive an error similar to this:

  ```text
  ----- Starting hook: /opt/staging/hooks/17-check-license.sh
  Pulling evaluation license from Ping Identity for:
                Prod License: PD - v7.3
                DevOps User: some-devops-user@example.com...
  Unable to download evaluation product.lic (000), most likely due to invalid PING_IDENTITY_DEVOPS_USER/PING_IDENTITY_DEVOPS_KEY

  ##################################################################################
  ############################        ALERT        #################################
  ##################################################################################
  #
  # No Ping Identity License File (PingDirectory.lic) was found in the server profile.
  # No Ping Identity DevOps User or Key was passed.
  #
  #
  # More info on obtaining your DevOps User and Key can be found at:
  #     https://devops.pingidentity.com/get-started/devopsRegistration/
  #
  ##################################################################################
  CONTAINER FAILURE: License File absent
  CONTAINER FAILURE: Error running 17-check-license.sh
  CONTAINER FAILURE: Error running 10-start-sequence.sh
  ```

This can be caused by:

1. An invalid DevOps user name or key (as noted in the error). This is usually caused by some issue with the variables being passed in.

     To verify the variables in pingctl's configuration are correct for running Docker commands, enter the following command and verify your configuration:

      ```shell
      pingctl info
      ```

1. A bad Docker image. Pull the Docker image again to verify.

1. Network connectivity to the license server is blocked. To test this, from the machine that's running the container, enter:

      ```shell
      curl -k https://license.pingidentity.com/devops/license
      ```

      If the license server is accessible, you receive an error similar to this:

      ```shell
      { "error":"missing devops-user header" }
      ```
