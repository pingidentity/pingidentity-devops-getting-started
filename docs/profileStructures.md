# Server profile structures

Each of the Docker images created for our products reflects the server profile structures used by our installed products. The directory paths for these server profiles can differ between products, as can the server profile structures (the directory paths and data). You'll see these server profile structures in the local directory bound to the Docker `/opt/in` volume when you elect to save any changes you make to a server profile. See [Saving your changes](saveConfigs.md) for more information.

The server profile structures in the local directory bound to the `/opt/in` volume are used by our containers at startup. Any files you place in the server profile structures here will be used to configure the container.

You'll find in this document the server profile structures you can use for each of our products with some example usages.

## PingFederate

| Path | Location description |
| :--- | :--- |
| `instance` | Any file that you want to be used at product runtime, in accordance with the directory layout of the product. |
| `instance/server/default/conf/pingfederate.lic` | Use an existing PingFederate license, rather than the DevOps evaluation license. |
| `instance/server/default/data/data.zip` | A configuration archive you've exported from PingFederate. |
| `instance/server/default/deploy/OAuthPlayground.war` | Automatically deploy the OAuthPlayground web application. |
| `instance/server/default/conf/META-INF/hivemodule.xml` | Apply a Hive module configuration to the container. |


## PingAccess

| Path | Location description |
| :--- | :--- |
| `instance` | Any file that you want to be used at product runtime, in accordance with the directory layout of the product. |
| `instance/conf/pingaccess.lic` | Use an existing PingAccess license, rather than the DevOps evaluation license. |
| `instance/conf/pa.jwk` | Used to decrypt a `data.json` configuration upon import |
| `instance/data/data.json` | A config file that, if found by the container, is uploaded into the container |
| `instance/data/PingAccess.mv.db` | database binary that would be ingested at container startup if found. |

### PingAccess server profile best practices

PingAccess profiles are typically minimalist. This is because the majority of PingAccess configurations can be found within a `data.json` or `PingAccess.mv.db` file. We highly recommend you only use `data.json` for configurations and only use `PingAccess.mv.db` if necessary. You can easily view and manipulate configurations directly in a JSON file as opposed to the binary `PingAccess.mv.db` file. This makes tracking changes in version control easier as well. 

PingAccess 6.1.x+ supports using only `data.json`, even when clustering. _However_ on  6.1.0.3 make sure `data.json` is only supplied to the admin node.

<!-- When using a `data.json`, the container uses the PingAccess Admin API to import the data.json. This means: 
1. The PingAccess server has to be running. So be careful when determining when the container is 'ready' to accept traffic. Check that the configuration has been imported, rather than just that the server is up. Refer to the `liveness.sh` within the image for an example. 
2. Import only _needs_ to occur on the admin node. Typically engines can be  -->

> Configuration file names and paths are important.

#### For PingAccess 6.1.0 or greater

PingAccess now supports native `data.json` ingestion. *This is the recommended method*. Place `data.json` or `data.json.subst` in `instance/conf/data/start-up-deployer`.

> The JSON configuration file for PingAccess _must_ be named `data.json`.

A `data.json` file that corresponds to earlier PingAccess versions _might_ be accepted. However, once you're on version 6.1.x, the `data.json` file will be forward compatible. This means you're able to avoid upgrades for your deployments! 

#### For PingAccess 6.0.x and prior versions

The JSON configuration file for PingAccess _must_ be named `data.json` and located in the `instance/data` directory. 

#### For all PingAccess versions

A corresponding file named `pa.jwk` must also exist in the `instance/conf` directory for the `data.json` file to be decrypted on import. To get a `data.json` and `pa.jwk` that work together, pull them both from the same running PingAccess instance. 

For example, if PingAccess is running in a local Docker container you can use these commands to export the `data.json` file and copy the `pa.jwk` file to your local Downloads directory: 

  ```shell
    curl -k -u "Administrator:${ADMIN_PASSWORD}" -H "X-Xsrf-Header: PingAccess" https://localhost:9000/pa-admin-api/v3/config/export -o ~/Downloads/data.json

    docker cp <container_name>:/opt/out/instance/conf/pa.jwk ~/Downloads/pa.jwk
  ```

### Understanding the password variables

The PingAccess administrator user password is not found in `data.json`, but in `PingAccess.mv.db`. For this reason, here are environment variables you can use to manage different scenarios:

* `PING_IDENTITY_PASSWORD` 
  
  Use this variable if:

  - You're starting a PingAccess container without any configurations. 
  
  - You're using only a `data.json` file for configurations.  

  - Your `PingAccess.mv.db` file has a password other than the default "2Access".
  
  The `PING_IDENTITY_PASSWORD` value will be used for all interactions with the PingAccess Admin API (such as, importing configurations, and creating clustering).

* `PA_ADMIN_PASSWORD_INITIAL` 
  
  Use this in addition to `PING_IDENTITY_PASSWORD` to change the runtime admin password and override the password in `PingAccess.mv.db`.

> If you use only `data.json` and don't pass `PING_IDENTITY_PASSWORD`, the password will default to "2FederateM0re". So, *always* use `PING_IDENTITY_PASSWORD`.

## PingDirectory

| Path | Location description |
| :--- | :--- |
| `instance` | Any file that you want to be used at product runtime, in accordance with the directory layout of the product. |
| `instance/PingDirectory.lic` | Use an existing PingDirectory license, rather than the DevOps evaluation license. |
| `instance/config/schema/` | A custom schema. |
| `instance/config/keystore` | Certificates in a Java KeyStore (JKS). |
| `instance/config/keystore.pin` | Certificates in a PKS#12 KeyStore. |
| `instance/config/truststore` | Certificates in a Java TrustStore. |
| `instance/config/truststore.p12` | Certificates in a PKS#12 TrustStore. |
| `instance/config/truststore.pin` | Certificates in a pin-protected TrustStore. |
| `dsconfig` | Directory server configuration fragments. When the container starts, all fragments are appended in the order based on their number prefix, and applied in one large batch. Files must be named using two digits, a dash, a label, and the .dsconfig extension (for example, 12-index-oauth-grants.dsconfig). |
| `data` | LDIF data fragments. When the container starts, all the supplied files are imported in the order based on their number prefix. Files must be named with two digits, a dash, the backend name ( defaults to `userRoot`), a label, and the .ldif extension (for plain LDIF) or .ldif.gz for a gzip compressed file. Ordered examples are: `10-userRoot-skeleton.ldif`, `20-userRoot-users.ldif.gz`, `30-userRoot-groups.ldif`. |
| `hooks` | A set of custom scripts that will be called at key points during the container startup sequence. The order in which the scripts are called is determined by the number prefix. Ordered examples are: `00-immediate-startup.sh` (called immediately), `10-before-copying-bits.sh`, `20-before-setup.sh` |

## PingDataSync

| Path | Location description |
| :--- | :--- |
| `instance` | Any file that you want to be used at product runtime, in accordance with the directory layout of the product. |
| `instance/PingDirectory.lic` | Use an existing PingDirectory license (also used for PingDataSync), rather than the DevOps evaluation license. |
| `instance/config/schema/` | A custom schema. |
| `instance/config/keystore` | Certificates in a Java KeyStore (JKS). |
| `instance/config/keystore.pin` | Certificates in a PKS#12 KeyStore. |
| `instance/config/truststore` | Certificates in a Java TrustStore. |
| `instance/config/truststore.p12` | Certificates in a PKS#12 TrustStore. |
| `instance/config/truststore.pin` | Certificates in a pin-protected TrustStore. |
| `dsconfig` | Directory server configuration fragments. When the container starts, all fragments are appended in the order based on their number prefix, and applied in one large batch. Files must be named using two digits, a dash, a label, and the .dsconfig extension (for example, 12-index-oauth-grants.dsconfig). |
