---
title: Layering Server Profiles
---
# Layering server profiles

One of the benefits of our Docker images is the ability to layer product configuration. By using small, discrete portions of your configuration, you can build and assemble a server profile based on multiple installations of a product.

A typical organization can have multiple installations of our products, each using different configurations. By layering the server profiles, you can reuse the configurations that are common across environments, leading to fewer configurations to manage.

You can have as many layers as needed. Each layer of the configuration is *copied* on top of the container's filesystem (not merged).

!!! note "Layer Precedence"
    The profile layers are applied starting at the top layer and ending at the base layer. This ordering might not be apparent at first.

## Before you begin

You must:

* Complete [Get Started](../get-started/introduction.md) to set up your DevOps environment and run a test deployment of the products.

## About this task

You will:

* Create a layered server profile.
* Assign the environment variables for the deployment.
* Deploy the layered server profile.

## Creating a layered server profile

For this guide, PingFederate is used along with the server profile located in the [pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingfederate) repository. You should fork this repository to your Github repository, then pull your Github repository to a local directory. After you have finished creating the layered profile, you can push your updates to your Github repository and reference it as an environment variable to run the deployment.

You will create separate layers for:

* Product license
* Extensions (such as, Integration Kits and Connectors)

For this example, these layers will be applied on top of the PingFederate server profile. However, you can span configurations across multiple repositories if you want.

You can find the complete working, layered server profile of the PingFederate example from this guide in the [pingidentity-server-profiles/layered-profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles) directory.

Because PingFederate's configuration is file-based, the layering works by copying configurations on top of the PingFederate container’s file system.

!!! warning "Files Copied"
    Files are copied, not merged. It is best practice to only layer items that will not be impacted by other configuration files.

### Creating the base directories

Create a working directory named `layered_profiles` and within that directory create `license` and `extensions` directories. When completed, your directory structure should be:

```text
└── layered_profiles
   ├── extensions
   └── license
```

### Constructing the license layer

1. Go to the `license` directory and create a `pingfederate` subdirectory.
1. Create the PingFederate license file directory path under the `pingfederate` directory.

    The PingFederate license file resides in the `/instance/server/default/conf/` path.

      ```sh
      mkdir -p instance/server/default/conf/
      ```

      Your license profile path should look like this:

      ```text
      └── license
         └── pingfederate
            └── instance
               └── server
                     └── default
                        └── conf
                           └── pingfederate.lic
      ```

1. Copy your `pingfederate.lic` file to `license/pingfederate/instance/server/default/conf`.

    Using the DevOps evaluation license, when the PingFederate container is running, you can find the license in the container file system `/opt/out/instance/server/default/conf` directory.

    You can copy the `pingfederate.lic` file from the Docker file system using the syntax:
    `docker cp <container> <source-location> <target-location>`

      For example:

      ```sh
      docker cp \
         pingfederate \
         /opt/in/instance/server/default/conf/pingfederate.lic \
         ${HOME}/projects/devops/layered_profiles/license/pingfederate/instance/server/default/conf
      ```

      Using the `ping-devops` tool:

      ```sh
      ping-devops generate license pingfederate > \
         ${HOME}/projects/devops/layered_profiles/license/pingfederate/instance/server/default/conf
      ```

### Building the extensions layer

1. Go to the `layered-profiles/extensions` directory and create a `pingfederate` subdirectory.
1. Create the PingFederate extensions directory path under the `pingfederate` directory.

    The PingFederate extensions reside in the `/instance/server/default/deploy` directory path.

      ```sh
      mkdir -p instance/server/default/deploy
      ```

1. Copy the extensions you want to be available to PingFederate to the `layered-profiles/extensions/pingfederate/instance/server/default/deploy` directory .

    The extensions profile path should look similar to the following (extensions will vary based on your requirements):

      ```text
      └── extensions
         └── pingfederate
            └── instance
                  └── server
                     └── default
                        └── deploy
                              ├── pf-aws-quickconnection-2.0.jar
                              ├── pf-azure-ad-pcv-1.2.jar
                              └── pf-slack-quickconnection-3.0.jar
      ```

## Assigning environment variables

Although this deployment assigns the environment variables for use in a Docker Compose YAML file, you can use the following technique with any Docker or Kubernetes deployment.

If you want to use your own Github repository for the deployment in the following examples, replace:

```sh
SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
```

with:

```sh
SERVER_PROFILE_URL=https://github.com/<your-username>/pingidentity-server-profiles.git
```

!!! note "Private Github Repo"
    If your GitHub server-profile repo is private, use the `username:token` format so the container can access the repository. For example, `https://github.com/<your_username>:<your_access_token>/pingidentity-server-profiles.git`. For more information, see [Using Private Github Repositories](./privateRepos.md).

1. Create a new `docker-compose.yaml` file.

2. Add your license profile to the YAML file.

    For example:

      ```yaml
      - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_PATH=layered-profiles/license/pingfederate
      ```

      > `SERVER_PROFILE` supports `URL`, `PATH`, `BRANCH` and `PARENT` variables.

3. Using `SERVER_PROFILE_PARENT`, instruct the container to retrieve its parent configuration by specifying the `extensions` profile as the parent:

      ```yaml
      - SERVER_PROFILE_PARENT=EXTENSIONS
      ```

      `SERVER_PROFILE` can be extended to reference additional profiles. Because we specified the license profile's parent as `EXTENSIONS`, we can extend `SERVER_PROFILE` by referencing the `EXTENSIONS` profile (prior to the `URL` and `PATH` variables):

      ```yaml
      - SERVER_PROFILE_EXTENSIONS_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_EXTENSIONS_PATH=layered-profiles/extensions/pingfederate
      ```

4. Set `GETTING_STARTED` as the `EXTENSIONS` parent and declare the `URL` and `PATH`:

      ```yaml
      - SERVER_PROFILE_EXTENSIONS_PARENT=GETTING_STARTED
      - SERVER_PROFILE_GETTING_STARTED_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_GETTING_STARTED_PATH=getting-started/pingfederate
      ```

      > Because the `GETTING_STARTED` profile is the last profile to add, it will not have a parent.

      Your `environment` section of the `docker-compose.yaml` file should look similar to this:

      ```yaml
      environment:
      # **** SERVER PROFILES BEGIN ****
      # Server Profile - Product License
      - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_PATH=layered-profiles/license/pingfederate
      - SERVER_PROFILE_PARENT=EXTENSIONS

      # Server Profile - Extensions
      - SERVER_PROFILE_EXTENSIONS_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_EXTENSIONS_PATH=layered-profiles/extensions/pingfederate
      - SERVER_PROFILE_EXTENSIONS_PARENT=GETTING_STARTED

      # Base Server Profile
      - SERVER_PROFILE_GETTING_STARTED_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_GETTING_STARTED_PATH=getting-started/pingfederate
      # **** SERVER PROFILE END ****
      ```

## Deploying the layered profile

1. Push your profiles and updated `docker-compose.yaml` file to your GitHub repository.
1. Deploy the stack with the layered profiles.

To view this example in its entirety, including the profile layers and `docker-compose.yaml` file, see the [pingidentity-server-profiles/layered-profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles) directory.
