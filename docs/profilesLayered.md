# Layering server profiles

One of the benefits of our Docker images is the ability to layer product configuration. By using small discrete portions of your configuration, you can build and assemble a server profile based on multiple installations of a product.

A typical organization can have multiple installations of our products, each using different configurations. By layering the server profiles, you can reuse the configurations that are common across environments, leading to fewer configurations to manage.

You can have as many layers as needed. Each layer of the configuration is *copied* on top of the container's filesystem (not merged).

## Prerequisite

  * You've already been through [Get started](evaluate.md) to set up your DevOps environment and run a test deployment of the products.

## What you'll do

* Create a layered server profile based on the PingFederate server profile located in the [pingidentity-server-profiles](../../pingidentity-server-profiles/getting-started/pingfederate) repository.
* Assign a parent server profile for the layered profiles using the `SERVER_PROFILE_PARENT` environment variable (`SERVER_PROFILE_PARENT=<parent-name>`).
* Declare the parent layer using this naming convention:
  - SERVER_PROFILE_<LAYER-NAME>_URL
  - SERVER_PROFILE_<LAYER-NAME>_PATH
  - SERVER_PROFILE_<LAYER-NAME>_PARENT

## Create a layered server profile

We'll use PingFederate for this example, and create separate layers for:

* Product license
* Extensions (such as, Integration Kits and Connectors)
* OAuth Playground

These layers will be applied on top of the PingFederate server profile located in the [pingidentity-server-profiles](../../pingidentity-server-profiles/getting-started/pingfederate) repository.

The complete working, layered server profile of the PingFederate example we're doing here is in the [pingidentity-server-profiles/layered-profiles](../../pingidentity-server-profiles/layered-profiles) directory.

Because PingFederate's configuration is file-based, the layering works by copying configurations on top of the PingFederate container’s file system.

> Files are copied, not merged, when layering, so it is best practice to only layer items that won't be impacted by other configuration files.

### Create the base directories

In this example we will use one GitHub repository for simplicity, however, you can span configurations across multiple repositories if desired.

For this exercise, create a working directory named `layered_profiles` then within that directory create the following directories:

* license
* extensions
* oauth

Once completed your directory structure should be

```
└── layered_profiles
    ├── extensions
    ├── license
    └── oauth
```

### Construct the license layer

* Navigate to the license directory
* Create directory `pingfederate`

As PingFederate expects the license file to reside in the `/instance/server/default/conf/` directory, we'll create that path and place the `pingfederate.lic` file there.

Your license profile should now look like this

```
└── license
    └── pingfederate
        └── instance
            └── server
                └── default
                    └── conf
                        └── pingfederate.lic
```

### Build the extensions layer

* Navigate to the layered-profiles `extensions` directory
* Create directory `pingfederate`

Extensions are placed within the `/instance/server/default/deploy` folder.

* `mkdir -p /instance/server/default/deploy`
* Place the extensions you want to be available within PingFederate

The extensions profile should now look similar to this (extensions will vary based on your requirements)

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

PingFederate's OAuth Playground is placed within the `/instance/server/default/deploy` directory, like other extensions, so the same steps as above apply. For this example, we've broken out OAuth Playground into its own layer as that we may not want to make it available within all deployments of PingFederate.

Your oauth layer should now look like this

```
└── oauth
    └── pingfederate
        └── instance
            └── server
                └── default
                    └── deploy
                        └── OAuthPlayground.war
```

### Build the deployment file

For this example, we'll use docker-compose, however, this technique can be applied to any Docker deployment (Docker Run, Swarm, Kubernetes etc)

First, let's add our license profile
```
    - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_PATH=layered-profiles/license/pingfederate
```
The SERVER_PROFILE_ variables support URL, PATH, BRANCH and PARENT values

By using the SERVER_PROFILE_PARENT variable we can instruct the container to retrieve its parent configuration

For this example, we will specify the `extensions` profile as the parent

```
    - SERVER_PROFILE_PARENT=EXTENSIONS
```

The SERVER_PROFILE variable can be extended to use reference additional profiles. Since we specified license profile's parent as EXTENSIONS, the EXTENSIONS profile can be declared as

```
    - SERVER_PROFILE_EXTENSIONS_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_EXTENSIONS_PATH=layered-profiles/extensions/pingfederate
```

Note: the name of the PARENT is inserted into the SERVER_PROFILE variable Eg. SERVER_PROFILE_**EXTENSIONS**_URL

Next, set EXTENSIONS parent to OAUTH

```
    - SERVER_PROFILE_EXTENSIONS_PARENT=OAUTH
```

Specify the URL and PATH for the OAUTH server profile

```
    - SERVER_PROFILE_OAUTH_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_OAUTH_PATH=layered-profiles/oauth/pingfederate
```

Finally, set OAUTH's parent as GETTING_STARTED and declare GETTING-STARTED URL and PATH

```
    - SERVER_PROFILE_OAUTH_PARENT=GETTING_STARTED

    - SERVER_PROFILE_GETTING_STARTED_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_GETTING_STARTED_PATH=getting-started/pingfederate
```

As the GETTING_STARTED profile is the last profile to add, it will **not** have a parent.

Your environment section of the docker-compose.yaml file should now look like this

```
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

Once you have committed your profiles to GitHub and reference your repo's URLs within the docker-compose file, you're set to run the example.

To view this example in its entirety, including profile layers and docker-compose.yaml visit https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles
