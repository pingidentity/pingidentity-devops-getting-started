# Building a PingFederate Profile From your Current Deployment.

The term "profile" can vary in many instances. Here we will focus on two types of profiles for PingFederate: configuration archive, and bulk export. We will discuss the similarities and differences between two as well as how to build either from a running PingFederate environment.

## Prerequisite

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
  
* You understand our [product container anatomy](containerAnatomy.md).

* Recommended: You've read through [Customizing Server Profiles](profiles.md)

## Similarities

The two profile methods we are covering are:
- **bulk api export** - the resulting `.json` from the admin api at /bulk/export. typically saved as `data.json`
- **configuration archive** Pulled either from the admin UI - Server > Configuration Archive or from the admin API at `/configArchive`. We'll call the result of this output `data.zip` or the `/data` folder. 

<!-- INSERT LINK ON NEXT LINE FOR PF CONFIG DEPLOYMENTS -->
> Deciding which method you use should be based on how you plan to [deploy configurations updates](LINKNEEDED)

Both of these methods are considered file-based profiles. This means a "complete profile" looks like a **subset** of files that you would typically find in a running pingfederate filesystem. Again, this is a **subset** of files. Specifically, the minimial number of files needed to achieve your PingFederate configuration. All additional files that are not specific to your configuration should be left out as they will be filled in by the PingFederate docker image. (Refer to [container anatomy](containerAnatomy.md) for additional details).

Considering the above, familiarity with the PingFederate filesystem will help you achieve the optimal profile. Some key information can be found in [profile structures](profileStructures.md). But, to put it simply, you want to at least save every file outside of `pingfederate/server/default/data` that you've edited

Additionally, all files that are included in the profile should also be environment agnostic. This typically means turning hostnames and secrets into [variables that can be delivered from the orchestration layer](profileSubstitution.md).

## Bulk API Export Profile Method

A PingFederate Admin/Console will import a `data.json` on startup if it finds it in `instance/bulk-config/data.json`. 

The PF admin api `/bulk/export` endpoint will output a large json blob that is representative of the entire `pingfederate/server/default/data` folder, pingfederate 'core config', or a representation of anything you would configure from the pingfederate UI. You could consider it "the configuration archive in json format". 

So, you could just: 
1. Go to a running pingfederate, run: 
  ```shell
  curl --location --request GET 'https://pingfederate-admin.ping-devops.com/pf-admin-api/v1/bulk/export' \
    --header 'X-XSRF-Header: PingFederate' \
    --user "administrator:${passsword}" > data.json
  ```
2. Save data.json into a profile at `instance/bulk-config/data.json`
3. delete everything except `pf.jwk` in `instance/server/default/data`

And you will have a bulk api export "profile". This is handy because the entire config is on a single file and if you store it in source control you then only have to compare differences on one file. However, there's _much more_ hidden value beyond being on one file.

### Make the Bulk API Export "Profile Worthy"

By default, the resulting `data.json` from the export contains encrypted values, and to import this file, your pingfederate needs to have the corresponding master key (`pf.jwk`) in `pingfederate/server/default/data`. Note, in the devops world, we call this folder `instance/server/default/data`. However, each of the encrypted values also have the option to be replaced with an unencrypted form and, when required, a corresponding password. 

For example the ssl server cert from the [pingfederate baseline profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingfederate) when exported to data.json looks like: 

```json
      {
          "resourceType": "/keyPairs/sslServer",
          "operationType": "SAVE",
          "items": [
              {
                  "id": "sslservercert",
                  "fileData": "MIIRBwIBAzCCEMAGCSqGSIb3DQEHAaCCELEEghCtMIIQqTCCCeUGCSqGSIb3DQEHAaCCCdYEggnSMIIJzjCCCcoGCyqGSIb3DQEMCgECoIIJezCCCXcwKQYKKoZIhvcNAQwBAzAbBBQu6vDERQZX3uujWa7v_q3sYN4Q0gIDAMNQBIIJSFtdWbvLhzYrTqeKKiJqiqROgE0E4mkVvmEC6NwhhPbcH37IDNvVLu0umm--CDZnEmlyPpUucO345-U-6z-cskw4TbsjYIzM10MwS6JdsyYFTC3GwqioqndVgBUzDh8xGnfzx52zEehX8d-ig1F6xYsbEc01gTbh4lF5MA7E7VfoTa4hWqtceV8PQeqzJNarlZyDSaS5BLn1J6G9BYUze-M1xGhATz7F2l-aAt6foi0mwIBlc2fwsdEPuAALZgdG-q_V4gOJW2K0ONnmWhMgMLpCL42cmSb
                  ... more encrypted text ...
                  Yxpzp_srpy4LHNdgHqhVBhqtDrjeKJDRfc1yk21P5PpfEBxn5MD4wITAJBgUrDgMCGgUABBQLBpq8y79Pq1TzG1Xf6OAjZzBZaQQUC4kD4CkcrH-WTQhJHud850ddn08CAwGGoA==",
                  "encryptedPassword": "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2Iiwia2lkIjoiRW1JY1UxOVdueSIsInZlcnNpb24iOiIxMC4xLjEuMCJ9..l6PJ55nSSvKHl0vSWTpkOA.i7hpnnu2yIByhyq_aGBCdaqS3u050yG8eMRGnLRx2Yk.Mo4WSkbbJyLISHq6i4nlVA"
              }
          ]
      }
```

But this master key dependent form can be converted to:

```json

      {
          "operationType": "SAVE",
          "items": [{
              "password": "2FederateM0re",
              "fileData": "MIIRCQIBAzCCEM8GCSqGSIb3DQEHAaCCEMAEghC8MIIQuDCCC28GCSqGSIb3DQEHBqCCC2AwggtcAgEAMIILVQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYwDgQIjXWLRGuGNIQCAggAgIILKOgCQ9onDqBPQsshsaS50OjWtj\/7s47BUYal1YhO70fBup1a82WGHGhAvb\/SY1yOhqQR+TloEBOPI5cExoGN\/Gvw2Mw5\/wkQZZMSHqxjz68KhN4B0hrsOf4rqShB7jsz9ebSml3r2w0sUZWR73GBtBt1Y3wIlXLS2WtqdtHra9VnUqp1eOk+xenjuWM+u2ndDD43GgKB3n8mNBSSVBqx6ne7aSRJRuAUd+HAzLvSeXjTPMObI1Jod2F+7
              ... more base64 encoded exported .p12 ...
              5QJ15OJp2iEoVBWxogKf64s2F0iIYPoo6yjNvlidZCevP564FwknWrHoD7R8cIBrhlCJQbEOpOhPg66r4MK1CeJ2poaKRlMS8HGcMRaTpaqD+pIlgmUS6xFw49vr9Kwfb7KteRsTkNR+I8A7HjUpuCMSUwIwYJKoZIhvcNAQkVMRYEFOb7g1xwDka5fJ4sqngEvzTyuWnpMDEwITAJBgUrDgMCGgUABBRlJ+D+FR\/vQbaTGbKDFiBK\/xDbqQQIAjLc+GgRg44CAggA",
              "id": "sslservercert"
          }],
          "resourceType": "/keyPairs/sslServer"
      }
```

What happened:
1. Exported the private key+cert of the server cert with alias `sslservercert`. Upon export, a password is requested and `2FederateM0re` was used. This results in download of a pssword protected `.p12` file. 
2. on data.json key name `encryptedPassword` converted to just `password`
3. the value for `fileData` is replaced with a base64 encoded version of the exported `.p12` file.

This is a process that can be seen all the way through for all sorts of things:
- Key Pairs (.p12)
- Trusted Certs (x509)
- 












When you deployed the full stack of product containers in [Get started](getStarted.md), you were employing the server profiles associated with each of our products. In the YAML files, you'll see entries such as this for each product instance:

  ```yaml
  environment:
    - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_PATH=baseline/pingaccess
  ```
Our [pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles) repository indicated by the `SERVER_PROFILE_URL` environment variable, contains the server profiles we use for our DevOps deployment examples. The `SERVER_PROFILE_PATH` environment variable indicates the location of the product profile data to use. In the example above, the PingAccess profile data is located in the `baseline/pingaccess` directory.

We use environment variables for certain startup and runtime configuration settings of both standalone and orchestrated deployments. There are environment variables that are common to all product images. You'll find these in the [PingBase image directory](docker-images/pingbase/README.md). There are also product-specific environment variables. You'll find these in the [Docker image reference](dockerImagesRef.md) for each available product.

## Prerequisite

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
  
* You understand the [anatomy of of our product containers](containerAnatomy.md).

## What you'll do

* Add or change the environment variables used for any of our server profiles to better fit your purposes. These environment variables are located in the [server profiles repository](https://github.com/pingidentity/pingidentity-server-profiles) for each product. For example, the location for the env_vars file for PingAccess is located in the [baseline/pingaccess server profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingaccess).
  
* Modify one of our server profiles to reflect an existing Ping Identity product installation in your organization. You can do this by forking our server profiles repository (`https://github.com/pingidentity/pingidentity-server-profiles`) to your Github repository, or by using local directories.

## Add or change environment variables

1. Select any environment variables to add from either the Docker images in the [Docker images reference](dockerImagesRef.md) for the product-specific environment variables, or the [PingBase image directory](docker-images/pingbase/README.md) for the environment variables common to all of our products.
   
2. Select the product whose profile you want to modify from the `baseline`, `getting-started`, or `simple-sync` directories in the [server profiles repository](https://github.com/pingidentity/pingidentity-server-profiles).
   
3. Open the `env_vars` file associated with the product and add any of the environment variables you've selected, or change the existing environment variables to fit your purpose.

## Modify a server profile

You can modify one of our server profiles based on data from your existing Ping Identity product installation. Modify a server profile in either of these ways:

* Using your Github repository
  
* Using local directories

### Modify a server profile using your Github repository

We'll use a PingFederate installation as an example. This method uses a server profile provided through a Github URL and assigned to the `SERVER_PROFILE_PATH` environment variable (such as, `--env SERVER_PROFILE_PATH=getting-started/pingfederate`).

1. Export a [configuration archive](https://support.pingidentity.com/s/document-item?bundleId=pingfederate-84&topicId=adminGuide%2Fpf_c_configurationArchive.html) as a *.zip file from a PingFederate installation to a local directory.

   > Make sure this is *exported* as a .zip rather than compressing it yourself.

2. Log in to Github and fork [https://github.com/pingidentity/pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles) into your own GitHub repository.

3. Open a terminal, create a new directory, and clone your Github repository to a local directory. For example:

   ```bash
     mkdir /tmp/pf_to_docker
     cd /tmp/pf_to_docker
     git clone https://github.com/<github-username>/pingidentity-server-profiles.git
   ```

   Where `<github-username>` is the name you used to log in to the Github account.

4. Go to the location where you cloned your fork of our `pingidentity-server-profiles` repository, and replace the `/data` directory in `getting-started/pingfederate/instance/server/default` with the `data` directory you exported from your existing PingFederate installation. For example:

   ```bash
     cd pingidentity-server-profiles/getting-started/pingfederate/instance/server/default
     rm -rf data
     unzip -qd data <path_to_your_configuration_archive>/data.zip
   ```

   Where `<path_to_your_configuration_archive>` is the location for your exported PingFederate configuration archive.

   You now have a local server profile based on your existing PingFederate installation.

   > We recommend you push to Github only what is necessary for your customizations. Our Docker images create the `/opt/out` directory using a product's base install and layering a profile (set of files) on top.

5. Push your changes (your local server profile) to the Github repository where you forked our server profile repository. You now have a server profile available through a Github URL.

6. Deploy the PingFederate container. The environment variables `SERVER_PROFILE_URL` and `SERVER_PROFILE_PATH` direct Docker to use the server profile you've modified and pushed to Github.

   > To save any changes you make after the container is running, add the entry `--volume <local-path>:/opt/out` to the `docker run` command, where <local-path> is a directory you've not already created. See [Saving your changes](saveConfigs.md) for more information.

   For example:

   ```bash
    docker run \
      --name pingfederate \
      --publish 9999:9999 \
      --publish 9031:9031 \
      --detach \
      --env SERVER_PROFILE_URL=https://github.com/<your_username>/pingidentity-server-profiles.git \
      --env SERVER_PROFILE_PATH=getting-started/pingfederate \
      --env-file ~/.pingidentity/devops \
      pingidentity/pingfederate:edge
   ```

   > If your GitHub server-profile repo is private, use the `username:token` format so the container can access the repository. For example, `https://github.com/<your_username>:<your_access_token>/pingidentity-server-profiles.git`. See [Using private Github repositories](privateRepos.md) for more information.

7. To display the logs as the container starts up, enter:
   
   ```shell
   docker container logs -f pingfederate
   ```

8. In a browser, go to `https://localhost:9999/pingfederate/app` to display the PingFederate console.

### Modify a server profile using local directories

This method is particularly helpful when developing locally and the configuration is not ready to be distributed (using Github, for example). We'll use PingFederate as an example. The local directories used by our containers to persist state and data, `/opt/in` and `/opt/out`, will be bound to another local directory and mounted as Docker volumes. This is our infrastructure for modifying the server profile.

> Docker recommends that you never use bind mounts in a production environment. This method is solely for developing server profiles. See the [Docker documentation](https://docs.docker.com/storage/volumes/) for more information.

* The `/opt/out` directory

  All configurations and changes during our container runtimes (persisted data) are captured here. For example, the PingFederate image `/opt/out/instance` will contain much of the typical PingFederate root directory:
  ```text
  .
  ├── README.md
  ├── SNMP
  ├── bin
  ├── connection_export_examples
  ├── etc
  ├── legal
  ├── lib
  ├── log
  ├── modules
  ├── sbin
  ├── sdk
  ├── server
  ├── tools
  └── work
  ```

* The `/opt/in` directory

  If a mounted `opt/in` directory exists, our containers will reference this directory at startup for any server profile structures or other relevant files. This method is in contrast to a server profile provided using a Github URL assigned to the `SERVER_PROFILE_PATH` environment variable (such as, `--env SERVER_PROFILE_PATH=getting-started/pingfederate`).

  > See [Server profile structures](profileStructures.md) for the data each product writes to a mounted `/opt/in` directory.

  These directories are useful for building and working with local server-profiles. The `/opt/in` directory is particularly valuable if you do not want your containers to access Github for data (the default for our server profiles). Here's an example, again using PingFederate:

1. Deploy PingFederate using our sample [getting-started server profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingfederate), and mount `/opt/out` to a local directory. For example:
   
   ```bash
   docker run \
       --name pingfederate \
       --publish 9999:9999 \
       --detach \
       --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
       --env SERVER_PROFILE_PATH=getting-started/pingfederate \
       --env-file ~/.pingidentity/devops \
       --volume /tmp/docker/pf:/opt/out \
       pingidentity/pingfederate:edge
   ```

   > Make sure the local directory (in this case, `/tmp/docker/pf`) is not already created. Docker needs to create this directory for the mount to `/opt/out`.

2. Go to the mounted local directory (in this case, `/tmp/docker/pf`), then make and save some configuration changes to PingFederate using the management console. As you save the changes, you'll be able to see the files in the mounted directory change. For PingFederate, an `instance` directory is created. This is a PingFederate server profile.
   
3. Stop & remove the container and start a new container, adding another `/tmp/docker/pf` bind mounted volume, this time to `/opt/in`. For example:
   
   ```bash
   docker container rm pingfederate

   docker run \
     --name pingfederate-local \
     --publish 9999:9999 \
     --detach \
     --volume /tmp/docker/pf:/opt/out \
     --volume /tmp/docker/pf:/opt/in \
     pingidentity/pingfederate:edge
   ```

     The new container will now use the changes you made using the PingFederate console. In the logs you can see where `/opt/in` is used:

   ```bash
   docker logs pingfederate-local
   ```

4. Finally, stop and remove the new container.  Remember your `/tmp/docker/pf` directory will stay until you remove it (or your machine is rebooted, as this is in /tmp):
   
   ```bash
   docker container rm pingfederate-local
   ```

   If you also want to remove your work, enter:

   ```shell
   rm -rf /tmp/docker/pf
   ```

