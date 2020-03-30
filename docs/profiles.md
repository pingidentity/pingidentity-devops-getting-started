# Customizing server profiles

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
3. Open an OS shell, create a new directory, and clone your Github repository to a local directory. For example:
```bash
  mkdir /tmp/pf_to_docker
  cd /tmp/pf_to_docker
  git clone https://github.com/<github-username>/pingidentity-server-profiles.git
```

Where `<github-username>` is the name you used to log in to the Github account.

4. Go to location where you cloned your fork of our `pingidentity-server-profiles` repository, and replace the `/data` directory in `getting-started/pingfederate/instance/server/default` with the `data` directory you exported from your existing PingFederate installation. For example:
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

7. Enter `docker container logs -f pingfederate` to display the logs as the container starts up.

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

  1. Deploy PingFederate using our sample standalone server profile located in your local `pingidentity-devops-getting-started/10-docker-standalone/02-pingfederate` directory, and bind mount `/opt/out` to a local directory. For example:
     ```bash
      docker run \
          --name pingfederate \
          --publish 9999:9999 \
          --detach \
          --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
          --env SERVER_PROFILE_PATH=getting-started/pingfederate \
          --volume /tmp/docker/pf:/opt/out \
          pingidentity/pingfederate:edge
     ```

     > Make sure the local directory (in this case, `/tmp/docker/pf`) is not already created. Docker needs to create this directory for the bind mount to `/opt/out`.

  2. Go to the mounted local directory (in this case, `/tmp/docker/pf`), then make and save some configuration changes to PingFederate using the management console. As you save the changes, you'll be able to see the files in the mounted directory change. For PingFederate, an `instance` directory is created. This is a PingFederate server profile.
  3. Stop the container and start a new container, adding another `/tmp/docker/pf` bind mounted volume, this time to `/opt/in`. For example:
     ```bash
     docker container stop pingfederate

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
     # Output:
     # ----- Starting hook: /opt/entrypoint.sh
     # copying local IN_DIR files (/opt/in) to STAGING_DIR (/opt/staging)
     # ----- Starting hook: /opt/staging/hooks/01-start-server.sh
     ```
