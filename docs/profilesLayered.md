# Layering server profiles

One of the benefits of our Docker images is the ability to layer product configuration. By using small discrete portions of your configuration, you can build and assemble a server profile based on multiple installations of a product.

A typical organization can have multiple installations of our products, each using different configurations. By layering the server profiles, you can reuse the configurations that are common across environments, leading to fewer configurations to manage.

You can have as many layers as needed. Each layer of the configuration is *copied* on top of the container's filesystem (not merged).

> The profile layers are applied starting at the top layer and ending at the base layer. This may not be apparent. In our examples, the base profile layer appears first in the `docker-compose.yaml` file. In these cases, it's a child-before-parent order of application.

## Prerequisite

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## What you'll do

* Create a layered server profile.
* Assign the environment variables for the deployment.
* Deploy the layered server profile.

## Create a layered server profile

We'll use PingFederate and our server profile located in the [pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingfederate) repository. We recommend you fork this repository to your Github repository, then pull your Github repository to to a local directory. When we've finished creating the layered profile, you can then push your updates the your Github repository, and reference your Github repository as an environment variable to run the deployment.

We'll create separate layers for:

* Product license
* Extensions (such as, Integration Kits and Connectors)
* OAuth Playground

For this example, these layers will be applied on top of the PingFederate server profile. However, you can span configurations across multiple repositories if you want.

The complete working, layered server profile of the PingFederate example we're building here is in the [pingidentity-server-profiles/layered-profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles) directory.

Because PingFederate's configuration is file-based, the layering works by copying configurations on top of the PingFederate container’s file system.

> Files are copied, not merged, when layering, so it is best practice to only layer items that won't be impacted by other configuration files.

### Create the base directories

1. Create a working directory named `layered_profiles` and within that directory create `license`, `extensions`, and `oauth` directories. When completed your directory structure should be:
   ```
   └── layered_profiles
      ├── extensions
      ├── license
      └── oauth
   ```

### Construct the license layer

1. Go to the `license` directory and create a `pingfederate` subdirectory.
2. The PingFederate license file resides in the `/instance/server/default/conf/` path. Create that directory path under the `pingfederate` directory. For example:
   ```bash
   mkdir -p instance/server/default/conf/
   ```

   Your license profile path should look like this:

   ```
   └── license
      └── pingfederate
          └── instance
              └── server
                  └── default
                      └── conf
                          └── pingfederate.lic
   ```

3. Copy your `pingfederate.lic` file to `license/pingfederate/instance/server/default/conf`. If you're using the DevOps evaluation license, when the PingFederate container is running, the license is located in the Docker file system's `/opt/in/instance/server/default/conf` directory. You can copy the `pingfederate.lic` file from the Docker file system using the syntax:
   `docker cp <container> <source-location> <target-location>`

   For example:

   ```bash
   docker cp pingfederate /opt/in/instance/server/default/conf/pingfederate.lic ${HOME}/projects/devops/layered_profiles/license/pingfederate/instance/server/default/conf
   ```

### Build the extensions layer

1. Go to the `layered-profiles/extensions` directory, and create a `pingfederate` subdirectory.
2. The PingFederate extensions reside in the `/instance/server/default/deploy` path. Create that directory path under the `pingfederate` directory. For example:
   ```bash
   mkdir -p instance/server/default/deploy
   ```

3. Copy to this directory (`layered-profiles/extensions/pingfederate/instance/server/default/deploy`) the extensions you want to be available to PingFederate.

   The extensions profile path should look similar to this (extensions will vary based on your requirements):

   ```
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

### Build the OAuth layer

1. Go to the `layered-profiles/oauth` directory, and create a `pingfederate` subdirectory.
   
   ```bash
   mkdir -p instance/server/default/pingfederate
   ```

2. OAuth Playground for PingFederate is also located in the `/instance/server/default/deploy` directory, like other extensions. For this example, we're building OAuth Playground into its own layer to show that it's optional for PingFederate deployments.
3. Copy the `OAuthPlayground.war` file to `layered-profiles/oauth/pingfederate/instance/server/default/deploy`.

   Your oauth profile layer should look like this:

   ```
   └── oauth
       └── pingfederate
           └── instance
               └── server
                   └── default
                       └── deploy
                           └── OAuthPlayground.war
   ```

## Assign the environment variables for the deployment

We'll assign the environment variables for use in a Docker Compose YAML file. However, you can use this technique with any Docker deployment (such as `docker run`, Kubernetes, Docker Swarm).

If you're intending on using your Github repository for the deployment, in the following examples, replace 
`SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git` 

with

`SERVER_PROFILE_URL=https://github.com/<your-username>/pingidentity-server-profiles.git`

> If your GitHub server-profile repo is private, use the `username:token` format so the container can access the repository. For example, `https://github.com/<your_username>:<your_access_token>/pingidentity-server-profiles.git`. See [Using private Github repositories](privateRepos.md) for more information.

1. Create a new `docker-compose.yaml` file.
2. Add your license profile to the YAML file. For example:
   
   ```yaml
    - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_PATH=layered-profiles/license/pingfederate
   ```
    `SERVER_PROFILE` supports `URL`, `PATH`, `BRANCH` and `PARENT` variables.

3. Using `SERVER_PROFILE_PARENT`, we can instruct the container to retrieve its parent configuration. We'll specify the `extensions` profile as the parent:
   
   ```yaml
    - SERVER_PROFILE_PARENT=EXTENSIONS
   ```
   `SERVER_PROFILE` can be extended to reference additional profiles. Since we specified the license profile's parent as `EXTENSIONS`, we can extend `SERVER_PROFILE` by referencing the `EXTENSIONS` profile (prior to the `URL` and `PATH` variables):
    ```yaml
     - SERVER_PROFILE_EXTENSIONS_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
     - SERVER_PROFILE_EXTENSIONS_PATH=layered-profiles/extensions/pingfederate
    ```

4. Set the `EXTENSIONS` parent to `OAUTH`:
   
   ```yaml
    - SERVER_PROFILE_EXTENSIONS_PARENT=OAUTH
   ```

   Then set the `URL` and `PATH` for the `OAUTH` profile:

    ```yaml
     - SERVER_PROFILE_OAUTH_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
     - SERVER_PROFILE_OAUTH_PATH=layered-profiles/oauth/pingfederate
    ```

5. Set `GETTING_STARTED` as the `OAUTH` parent and declare the `URL` and `PATH`:
   
   ```yaml
    - SERVER_PROFILE_OAUTH_PARENT=GETTING_STARTED
    - SERVER_PROFILE_GETTING_STARTED_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_GETTING_STARTED_PATH=getting-started/pingfederate
   ```

   > Because the `GETTING_STARTED` profile is the last profile to add, it won't have a parent.

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
    - SERVER_PROFILE_EXTENSIONS_PARENT=OAUTH

    # Server Profile - OAUTH
    - SERVER_PROFILE_OAUTH_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_OAUTH_PATH=layered-profiles/oauth/pingfederate
    - SERVER_PROFILE_OAUTH_PARENT=GETTING_STARTED

    # Base Server Profile
    - SERVER_PROFILE_GETTING_STARTED_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_GETTING_STARTED_PATH=getting-started/pingfederate
    # **** SERVER PROFILE END ****
   ```

## Deploy the layered server profile

1. Push your profiles and updated `docker-compose.yaml` file to your GitHub repository.
2. Deploy the stack with the layered profiles.

To view this example in its entirety, including the profile layers and `docker-compose.yaml` file, see the [pingidentity-server-profiles/layered-profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles) directory.
