# Layering Server Profiles

One of the many features of Ping Identity's product Docker Images is the ability to layer product configuration. By using small discrete portions of your configuration, you are able to build and assemble the overall profile.

In this example, we'll walkthrough breaking up PingFederate's configuration into bite-sized bits, then reassemble using a layered profile approach

## Benefits of Layering Profiles

In a typical organization, you may have multiple versions of Ping Identity products running with slightly different configurations applied to each. By layering the profiles, you can reuse the configurations that are common across environments, leading to fewer configurations to manage.

## TL;DR

* Server Profiles can be layered by specifying a parent profile (SERVER_PROFILE_PARENT=**<LAYER_NAME>**)
* Declare the parent layer using the following naming convention:
  * SERVER_PROFILE_**<LAYER_NAME>**_URL
  * SERVER_PROFILE_**<LAYER_NAME>**_PATH
  * SERVER_PROFILE_**<LAYER_NAME>**_PARENT
* You can have as many layers as needed
* Each layer of the configuration is copied on top of the container's filesystem (not merged)
* View a working example [here](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles )

## Layered Example

### Overview

In this example, we'll create separate layers for:

* Product License
* Extensions (Eg. Integration Kits, Connectors)
* OAuth Playground

These layers will be applied on top of PingFederate's [Getting-Started](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingfederate) server profile

See completed layered profile example [here](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles)

### Layering Approach

As PingFederate's configuration is file-based, layering configuration works by copying configuration on top of the Docker container’s filesystem. It is important to note that files are not merged when layering so it is best practice to only layer items that won't be impacted by other configuration files.

### Creating the base folders

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

### Constructing the PingFederate License layer

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

### Building the PingFederate Extensions layer

* Navigate to the layered-profiles extensions directory
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

### Building the PingFederate OAuth layer

PingFederate's OAuth Playground is placed within the deploy folder like other extensions so the same steps as above apply. For this example, we've broken out the OAuth Playground into its own layer is that we may not want to make it available on all deployments of PingFederate.

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

### Building the PingFederate Deployment File

For this example, we'll be using docker-compose, however, this technique can be applied to any Docker deployment (Docker Run, Swarm, Kubernetes etc)

First, let's add our license profile
```
    - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_PATH=layered-profiles/license/pingfederate
```
The SERVER_PROFILE_ variables support URL, PATH, BRANCH and PARENT values

By using the SERVER_PROFILE_PARENT we can instruct the image to retrieve its parent configuration

For this example, we will specify the `extensions` profile as the parent

```
    - SERVER_PROFILE_PARENT=EXTENSIONS
```

The SERVER_PROFILE variable can be extended to use reference profiles. Since we said the parent to the license profile is EXTENSIONS. The EXTENSIONS profile can be declared as

```
    - SERVER_PROFILE_EXTENSIONS_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_EXTENSIONS_PATH=layered-profiles/extensions/pingfederate
```

Note: the name of the PARENT is inserted into the SERVER_PROFILE variable Eg. SERVER_PROFILE_**EXTENSIONS**_URL

Next, let's set EXTENSIONS parent to OAUTH

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

To view this example in its entirety, view the profiles and source at https://github.com/pingidentity/pingidentity-server-profiles/tree/master/layered-profiles 
