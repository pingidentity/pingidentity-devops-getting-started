# Troubleshooting

## Contents:

* Getting-Started Examples
  * [Most common issue](#issue-getting-started-examples-not-working)
  * [Alias or bash_profile issue](#issue-bad-bash_profile-setup)
  * [License pull Issue](#issue-unable-to-pull-evaluation-license)
* Server Profiles \(coming soon\)
* Docker Builds \(coming soon\)

## Getting-Started Examples

### Issue: Getting-Started Examples Not Working

One of the most common errors that users find when getting started with the provided examples is due to having stale images. As the docker images are currently undergoing development, they are untagged and rapidly change. To avoid issues with stale images, be safe and allow Docker to pull the latest as necessary by removing all local Ping Identity images with:

```text
docker rmi $(docker images "pingidentity/*" -q)
```

> Note: Just because images are tagged "latest" locally, does not mean they are the latest in the docker hub registry.

### Issue: Bad bash_profile setup

If an running `dhelp` returns an error, or your containers are not able to pull a license based on your DevOps user and Key there may be some misconfiguration. 

> Note: if you are unfamiliar with `.bash_profile` here's a [quick intro](https://friendly-101.readthedocs.io/en/latest/bashprofile.html)

Common issues and troubleshooting steps. 
  1. If you have _just_ run `./setup` for the first time, make sure you are in a fresh terminal or have run `source ~/.bash_profile`
  2. If running `echo PING_IDENTITY_DEVOPS_USER` returns nothing in a fresh terminal, it's likely your .bash_profile is misconfigured. There should be a line that "[sources](https://friendly-101.readthedocs.io/en/latest/bashprofile.html#sourcing-your-bash-profile)" your ping-devops aliases and another that runs `sourcePignIdentityFiles`. Make sure there are not old versions or duplicates of these lines.
  3. If you are running in Kubernetes, keep in mind that your `PING_IDENTITY_DEVOPS_USER` and key are local variables and need to be [created as a secret](../../20-kubernetes/README.md#licenses) in your cluster.  


### Issue: Unable to pull evaluation license

If you are seeing an error similar to: 
  ```
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
  #      https://pingidentity-devops.gitbook.io/devops/prod-license
  # 
  ##################################################################################
  CONTAINER FAILURE: License File absent
  CONTAINER FAILURE: Error running 17-check-license.sh
  CONTAINER FAILURE: Error running 10-start-sequence.sh
  ```
This could be caused by: 
  1. An invalid Devops user or key (as noted in the error)
  2. A bad docker-image. **Re-pull the image to verify**
  3. Network connectivity to the license server is blocked

To test option 3. From the machine that is running the container, run:
```
curl -k https://license.pingidentity.com/devops/v2/license

#should return:
{ "error":"missing devops-user header" }%             
```
