---
title: Customizing Server Profiles
---
# Customizing Server Profiles

When you deployed the full stack of product containers in [Getting Started](../get-started/getStarted.md), you used the server profiles associated with each of our products. In the YAML files, you'll see entries like the following for each product instance:

```yaml
environment:
  - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
  - SERVER_PROFILE_PATH=baseline/pingaccess
```

Our [pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles) repository, indicated by the `SERVER_PROFILE_URL` environment variable, contains the server profiles we use for our DevOps deployment examples. The `SERVER_PROFILE_PATH` environment variable indicates the location of the product profile data to use. In the previous example, the PingAccess profile data is located in the `baseline/pingaccess` directory.

We use environment variables for certain startup and runtime configuration settings of both standalone and orchestrated deployments. You can find environment variables that are common to all product images in the [PingBase Image Directory](../docker-images/pingbase/README.md). There are also product-specific environment variables. You can find these in the [Docker Image Reference](../reference/dockerImagesRef.md) for each available product.

## Before you begin

You must:

* Complete [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Understand the [Anatomy of the Product Containers](containerAnatomy.md).

## About this task

You will:

* Add or change the environment variables used for any of our server profiles to better fit your purposes.

    You can find these variables in the [Server Profiles Repository](https://github.com/pingidentity/pingidentity-server-profiles) for each product.

    For example, the location for the `env_vars` file for PingAccess is located in the [baseline/pingaccess server profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingaccess).

* Modify one of our server profiles to reflect an existing Ping Identity product installation in your organization.

    You can do this by either:

    * Forking our server profiles repository (`https://github.com/pingidentity/pingidentity-server-profiles`) to your Github repository
    * Using local directories

## Adding or Changing Environment Variables

1. Select any environment variables to add from either:

    * The product-specific environment variables in the [Docker Images Reference](../reference/dockerImagesRef.md)
    * The environment variables common to all of our products in the [PingBase Image Directory](../docker-images/pingbase/README.md)

1. From the `baseline`, `getting-started`, or `simple-sync`
   directories in the [Server Profiles Repository](https://github.com/pingidentity/pingidentity-server-profiles), select the product whose profile you want to modify.

1. Open the `env_vars` file associated with the product and either:

    * Add any of the environment variables you've selected.
    * Change the existing environment variables to fit your purpose.

## Modifying a Server Profile

You can modify one of our server profiles based on data from your existing Ping Identity product installation.

Modify a server profile by either:

* Using your Github repository
* Using local directories

### Using Your Github Repository

In this example PingFederate installation, using the Github Repository uses a server profile provided through a Github URL and assigned to the `SERVER_PROFILE_PATH` environment variable, such as `--env SERVER_PROFILE_PATH=getting-started/pingfederate`).

1. Export a [configuration archive](https://support.pingidentity.com/s/document-item?bundleId=pingfederate-84&topicId=adminGuide%2Fpf_c_configurationArchive.html) as a *.zip file from a PingFederate installation to a local directory.

    > Make sure this is *exported* as a .zip rather than compressing it yourself.

1. Sign on to Github and fork [https://github.com/pingidentity/pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles) into your own GitHub repository.

1. Open a terminal, create a new directory, and clone your Github repository to a local directory. For example:

    ```sh
    mkdir /tmp/pf_to_docker
    cd /tmp/pf_to_docker
    git clone https://github.com/<github-username>/pingidentity-server-profiles.git
    ```

    Where `<github-username>` is the name you used to sign on to the Github account.

1. Go to the location where you cloned your fork of our `pingidentity-server-profiles` repository, and replace the `/data` directory in `getting-started/pingfederate/instance/server/default` with the `data` directory you exported from your existing PingFederate installation. For example:

    ```sh
    cd pingidentity-server-profiles/getting-started/pingfederate/instance/server/default
    rm -rf data
    unzip -qd data <path_to_your_configuration_archive>/data.zip
    ```

    Where `<path_to_your_configuration_archive>` is the location for your exported PingFederate configuration archive.

    You now have a local server profile based on your existing PingFederate installation.

    !!! note "Pushing to Github"
        You should push to Github only what is necessary for your customizations. Our Docker images create the `/opt/out` directory using a product's base install and layering a profile (set of files) on top.

1. Push your changes (your local server profile) to the Github repository where you forked our server profile repository.

    You now have a server profile available through a Github URL.

1. Deploy the PingFederate container.

    !!! note "Saving Changes"
        To save any changes you make after the container is running, add the entry `--volume <local-path>:/opt/out` to the `docker run` command, where &lt;local-path&gt; is a directory you haven't already created. For more information, see [Saving Your Changes](../how-to/saveConfigs.md).

    As in this example, the environment variables `SERVER_PROFILE_URL` and `SERVER_PROFILE_PATH` direct Docker to use the server profile you've modified and pushed to Github:

    ```sh
    docker run \
      --name pingfederate \
      --publish 9999:9999 \
      --publish 9031:9031 \
      --detach \
      --env SERVER_PROFILE_URL=https://github.com/<your_username>/pingidentity-server-profiles.git \
      --env SERVER_PROFILE_PATH=getting-started/pingfederate \
      --env-file ~/.pingidentity/config \
      pingidentity/pingfederate:edge
    ```

    !!! note "Private Repo"
        If your GitHub server-profile repo is private, use the `username:token` format so the container can access the repository. For example, `https://github.com/<your_username>:<your_access_token>/pingidentity-server-profiles.git`. For more information, see [Using Private Github Repositories](privateRepos.md).

1. To display the logs as the container starts up, enter:

    ```sh
    docker container logs -f pingfederate
    ```

1. In a browser, go to [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app) to display the PingFederate console.

### Using Local Directories

This method is particularly helpful when developing locally and the configuration isn't ready to be distributed (using Github, for example).

We'll use PingFederate as an example. The local directories used by our containers to persist state and data, `/opt/in` and `/opt/out`, will be bound to another local directory and mounted as Docker volumes. This is our infrastructure for modifying the server profile.

!!! warning "Bind Mounts in Production"
    Docker recommends that you never use bind mounts in a production environment. This method is solely for developing server profiles. For more information, see the [Docker Documentation](https://docs.docker.com/storage/volumes/).

* The `/opt/out` directory

    All configurations and changes during our container runtimes (persisted data) are captured here. For example, the PingFederate image `/opt/out/instance` contains much of the typical PingFederate root directory:
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

    If a mounted `opt/in` directory exists, our containers reference this directory at startup for any server profile structures or other relevant files. This method is in contrast to a server profile provided using a Github URL assigned to the `SERVER_PROFILE_PATH` environment variable, such as, `--env SERVER_PROFILE_PATH=getting-started/pingfederate`.

    > For the data each product writes to a mounted `/opt/in` directory, see [Server profile structures](../reference/profileStructures.md).

    These directories are useful for building and working with local server-profiles. The `/opt/in` directory is particularly valuable if you don't want your containers to access Github for data (the default for our server profiles).

The following example deployment uses PingFederate.

1. Deploy PingFederate using our sample [getting-started Server Profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingfederate), and mount `/opt/out` to a local directory:

    ```sh
    docker run \
        --name pingfederate \
        --publish 9999:9999 \
        --detach \
        --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
        --env SERVER_PROFILE_PATH=getting-started/pingfederate \
        --env-file ~/.pingidentity/config \
        --volume /tmp/docker/pf:/opt/out \
    pingidentity/pingfederate:edge
    ```

    > Make sure the local directory (in this case, `/tmp/docker/pf`) isn't already created. Docker needs to create this directory for the mount to `/opt/out`.

2. Go to the mounted local directory (in this case, `/tmp/docker/pf`), then make and save some configuration changes to PingFederate using the management console.

    As you save the changes, you'll be able to see the files in the mounted directory change. For PingFederate, an `instance` directory is created. This is a PingFederate server profile.

3. Stop and remove the container and start a new container, adding another `/tmp/docker/pf` bind mounted volume, this time to `/opt/in`:

    ```sh
    docker container rm pingfederate

    docker run \
      --name pingfederate-local \
      --publish 9999:9999 \
      --detach \
      --volume /tmp/docker/pf:/opt/out \
      --volume /tmp/docker/pf:/opt/in \
    pingidentity/pingfederate:edge
    ```

      The new container will now use the changes you made using the PingFederate console. In the logs, you can see where `/opt/in` is used:

    ```sh
    docker logs pingfederate-local
   ```

4. Stop and remove the new container.

    Remember your `/tmp/docker/pf` directory will stay until you remove it (or until your machine is rebooted because this is in the `/tmp` directory):

    ```sh
    docker container rm pingfederate-local
    ```

    If you also want to remove your work, enter:

    ```sh
    rm -rf /tmp/docker/pf
    ```
