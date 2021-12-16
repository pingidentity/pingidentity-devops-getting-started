---
title:  Server Profile Structures
---
# Server Profile Structures

Each of the Docker images use a server profile structure that is specific to each product.
The structure (directory paths and data) of the server profile differs between products.
Depending on how you [Deploy Your Server Profile](../how-to/containerAnatomy.md), it will be pulled or mounted
into `/opt/in` on the container and used to stage your deployment.

The following are the server profile structures for each of our products with some example usages.
To help with an example of the basics, see the
[pingidentity-server-profiles/getting-started](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started) examples.

!!! note "Ignore `.sec` directories in examples"
    For the getting-started profile examples, you should not use the practice of the `.sec` directory
    when providing passwords to your containers.  These are intended for demonstration purposes.
    Instead, set an environment variable with your secrets or orchestration later:

    ```shell
      PING_IDENTITY_PASSWORD="secret"
    ```

## PingFederate

See the example at [getting-started/pingfederate](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingfederate).

| Path                                                 | Location description                                                                                                       |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| instance                                             | Directories and files that you want to be used at product runtime, in accordance with the directory layout of the product. |
| instance/server/default/data                         | An extracted configuration archive exported from PingFederate.                                                              |
| instance/bulk-config/data.json                       | A JSON export from the PingFed admin API `/bulk/export`.                                                                   |
| instance/server/default/deploy/OAuthPlayground.war   | Automatically deploy the OAuthPlayground web application.                                                                  |
| instance/server/default/conf/META-INF/hivemodule.xml | Apply a Hive module config to the container. Used for persisting OAuth clients, grants, and sessions to an external DB.    |

!!! note "PingFederate Integeration Kits" By default, PingFederate is shipped with few integeration kits and adapters. But, if you need any other integeration kits or adapters to be a part of the deployment, they need to be manually downloaded and placed inside `server/default/deploy` of the server profile. You can find these resources in the product download page.

## PingAccess

Example at [getting-started/pingaccess](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingaccess).

| Path                           | Location description                                                                                                       |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| instance                       | Directories and files that you want to be used at product runtime, in accordance with the directory layout of the product. |
| instance/conf/pa.jwk           | Used to decrypt a `data.json` configuration upon import.                                                                    |
| instance/data/data.json        | PA 6.1+ A config file that, if found by the container, is uploaded into the container.                                      |
| instance/data/PingAccess.mv.db | Database binary that would be ingested at container startup if found.                                                      |

!!! note "PingAccess Best Practices"
    PingAccess profiles are typically minimalist. This is because the majority of PingAccess configurations can be found within a `data.json` or `PingAccess.mv.db` file. You should only use `data.json` for configurations and only use `PingAccess.mv.db` if necessary. You can easily view and manipulate configurations directly in a JSON file as opposed to the binary `PingAccess.mv.db` file. This makes tracking changes in version control easier as well.

    PingAccess 6.1.x+ supports using only `data.json`, even when clustering. _However_ on  6.1.0.3 make sure `data.json` is only supplied to the admin node.


<!-- When using a `data.json`, the container uses the PingAccess Admin API to import the data.json. This means:
1. The PingAccess server has to be running. So be careful when determining when the container is 'ready' to accept traffic. Check that the configuration has been imported, rather than just that the server is up. Refer to the `liveness.sh` within the image for an example.
2. Import only _needs_ to occur on the admin node. Typically engines can be  -->

!!! note "PingAccess 6.1.0+"
    PingAccess now supports native `data.json` ingestion, which is *the recommended method*. Place `data.json` or `data.json.subst` in `instance/conf/data/start-up-deployer`.

    > The JSON configuration file for PingAccess _must_ be named `data.json`.

    A `data.json` file that corresponds to earlier PingAccess versions _might_ be accepted. However, after you're on version 6.1.x, the `data.json` file will be forward compatible. This means you're able to avoid upgrades for your deployments!

!!! note "PingAccess 6.0.x and earlier"

    The JSON configuration file for PingAccess _must_ be named `data.json` and located in the `instance/data` directory.

!!! note "All PingAccess versions"
    A corresponding file named `pa.jwk` must also exist in the `instance/conf` directory for the `data.json` file to be decrypted on import. To get a `data.json` and `pa.jwk` that work together, pull them both from the same running PingAccess instance.

    For example, if PingAccess is running in a local Docker container you can use these commands to export the `data.json` file and copy the `pa.jwk` file to your local Downloads directory:

    ```shell
        curl -k -u "Administrator:${ADMIN_PASSWORD}" -H "X-Xsrf-Header: PingAccess" https://localhost:9000/pa-admin-api/v3/config/export -o ~/Downloads/data.json

        docker cp <container_name>:/opt/out/instance/conf/pa.jwk ~/Downloads/pa.jwk
    ```

!!! note "Password Variables"
    You can find the PingAccess administrator password in `PingAccess.mv.db`, not in `data.json`. For this reason, you can use the following environment variables to manage different scenarios:

    * `PING_IDENTITY_PASSWORD`

        Use this variable if:

        * You're starting a PingAccess container without any configurations.
        * You're using only a `data.json` file for configurations.
        * Your `PingAccess.mv.db` file has a password other than the default "2Access".

        The `PING_IDENTITY_PASSWORD` value will be used for all interactions with the PingAccess Admin API (such as, importing configurations, and creating clustering).

    * `PA_ADMIN_PASSWORD_INITIAL`

        Use this in addition to `PING_IDENTITY_PASSWORD` to change the runtime admin password and override the password in `PingAccess.mv.db`.

        > If you use only `data.json` and don't pass `PING_IDENTITY_PASSWORD`, the password will default to "2FederateM0re". So, *always* use `PING_IDENTITY_PASSWORD`.

## Ping Data Products

The Ping Data Products (PingDirectory, PingDataSync, PingAuthorize, PingDirectoryProxy)
follow the same structure for server-profiles.

Example at [getting-started/pingdirectory](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started/pingdirectory).

| Path       | Location description                                                                                                                                                            |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| pd.profile | Server profile matching the structure as defined by [PingDirectory Server Profiles](https://docs.pingidentity.com/bundle/pingdirectory-80/page/eae1564011467693.html)           |
| instance   | Directories and files that you want to be used at product runtime, in accordance with the layout of the product. In general, this should be **non existing or empty**.          |
| env-vars   | You can set environment variables used during deployment.  See [Variables and Scope](variableScoping.md) for more info.   In general, this should be **non existing or empty**. |

!!! note "Ping Data Server Profile Best Practices"
    * In most circumstances, the `pd.profile` should be on the only directory in the server profile.
    * All environment variables should be provided through Kubernetes configmaps/secrets and secret management tool.
      Be careful providing an `env-vars` and if you do, please review [Variables and Scope](variableScoping.md)

!!! note "Creating a `pd.profile` from scratch"
    Use the `manage-profile` tool (found in product `bin` directory) to generate a `pd.profile` from an existing Ping Data 8.0+ deployment.  An example on creating
    this `pd.profile` looks like:

       ```bash
       manage-profile generate-profile --profileRoot /tmp/pd.profile
       rm /tmp/pd.profile/setup-arguments.txt
       ```

   Follow instructions provided when you run the `generate-profile` to ensure that you include any additional components, such as `encryption-settings`.
