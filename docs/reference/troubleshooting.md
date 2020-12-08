# Troubleshooting

## Get started

### Examples not working

One of the most common errors is due to having stale images. Our development is highly dynamic and Docker images can rapidly change. To avoid issues with stale images, you can have Docker pull the latest images by removing all the local. Enter:

  ```shell
  docker rmi $(docker images "pingidentity/*" -q)
  ```

> Images tagged as "latest" locally does not mean they are the latest in the Docker hub registry.

### Misconfigured `~/.bash_profile` file

If your containers are not able to pull a license based on your DevOps user name and key, or running `dhelp` returns an error, there may be some misconfiguration in your `~/.bash_profile` file.

Possible solutions:

1. If you have *just* run `./setup` for the first time, make sure you are have done so in a fresh terminal, or have run `source ~/.bash_profile`.

2. If running `echo PING_IDENTITY_DEVOPS_USER` returns nothing in a fresh terminal, it's likely your `~/.bash_profile` file is misconfigured. There are two entries that need to be there:

   ```text
   source <path>/pingidentity-devops-getting-started/bash_profile_devops
   ```

   Where &lt;path&gt; is the full path to the `pingidentity-devops-getting-started` directory. This entry sources our DevOps aliases.

   There also needs to be another entry for:

   ```text
   sourcePingIdentityFiles
   ```

   This entry sources the Ping Identity file aliases.

   Make sure there are not old versions or duplicates of these entries.

3. If you are running in Kubernetes, keep in mind that your `PING_IDENTITY_DEVOPS_USER` and key are local variables and need to be [passed as a secret](../how-to/existingLicense.md) in your cluster.

### Products unable to get the evaluation license

If a product instance or instances are unable to get the evaluation license, an error similar to this may be generated:

  ```shell
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
  #     https://pingidentity-devops.gitbook.io/devops/getstarted/devopsregistration
  #
  ##################################################################################
  CONTAINER FAILURE: License File absent
  CONTAINER FAILURE: Error running 17-check-license.sh
  CONTAINER FAILURE: Error running 10-start-sequence.sh
  ```

This can be caused by:

1. An invalid DevOps user name or key (as noted in the error). This is usually caused by some issue with the variables being passed in. To verify the variables are available to the shell running (when running Docker commands), enter:

   ```shell
   echo $PING_IDENTITY_DEVOPS_USER $PING_IDENTITY_DEVOPS_KEY
   ```

2. A bad Docker image. Pull the Docker image again to verify.

3. Network connectivity to the license server is blocked. To test this, from the machine that is running the container, enter:

   ```shell
   curl -k https://license.pingidentity.com/devops/v2/license
   ```

   If the license server isn't accessible, an error similar to this is returned:

   ```shell
   { "error":"missing devops-user header" }%
   ```
