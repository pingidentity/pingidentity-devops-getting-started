# Server profile structures

Each of the Docker images created for our products reflects the server profile structures used by our installed products. The directory paths for these server profiles can differ between products, as can the server profile structures (the directory paths and data). You'll see these server profile structures in the local directory bound to the Docker `/opt/in` volume when you elect to save any changes you make to a server profile. See [Saving your changes](saveConfigs.md) for more information.

The server profile structures in the local directory bound to the `/opt/in` volume are used by our containers at startup. Any files you place in the server profile structures will be used to configure the container.

You'll find here the server profile structures you can use for each of our products with example usages.

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
| `instance/server/default/conf/pingaccess.lic` | Use an existing PingAccess license, rather than the DevOps evaluation license. |
| `instance/conf/pa.jwk` | Used to decrypt a `data.json` configuration upon import |
| `instance/data/data.json` | A config file that, if found by the container, is uploaded into the container |
| `instance/data/PingAccess.mv.db` | database binary that would be ingested at container startup if found. |

### PingAccess Profile Nuances and Best Practices

#### PingAccess profiles are typically very minimal
This is because the majority of PingAccess config can be found within a `data.json` or PingAccess.mv.db. It is typically preferred to use a data.json for config with absolute minimal configs in the PingAccess.mv.db. Simply because you can see and manipulate configs directly in a json file rather than the binary PingAccess.mv.db file. This makes tracking changes in version control easier as well. 

Thus, if running PingAccess in 'Standalone' mode, try to _only_ use a `data.json`. Currently, clustering PingAccess requires using the `PingAccess.mv.db` in order to set the cluster bind port. 

<!-- When using a `data.json`, the container uses the PingAccess Admin API to import the data.json. This means: 
1. The PingAccess server has to be running. So be careful when determining when the container is 'ready' to accept traffic. Check that the configuration has been imported, rather than just that the server is up. Refer to the `liveness.sh` within the image for an example. 
2. Import only _needs_ to occur on the admin node. Typically engines can be  -->

#### Config file names and paths are important
The json config file in PingAccess _must_ be named `data.json` and located in `instance/data`. A corresponding file names `pa.jwk` must also exist at `instance/conf` for the data.json to be decrypted on import. To get a `data.json` and `pa.jwk` that work together, pull them both from the same running PingAccess. For example, if PingAccess is running in a local docker container you can use: 
  ```
    curl -k -u "Administrator:${ADMIN_PASSWORD}" -H "X-Xsrf-Header: PingAccess" https://localhost:9000/pa-admin-api/v3/config/export -o ~/Downloads/data.json

    docker cp <container_name>:/opt/out/instance/conf/pa.jwk ~/Downloads/pa.jwk
  ```

#### Understand the password variables
The administrator user password is not found in `data.json` but is found in PingAccess.mv.db. As such, there are variables available to manage different scenarios. 
`PA_ADMIN_PASSWORD` - use this if your PingAccess.mv.db has a password other than the default `2Access`. This will be used for all interactions with the Admin API. (e.g. importing config, creating clustering)

`SET_ADMIN_PASSWORD` - Use this to set the runtime admin password if you are: 
  1. starting a PingAccess container without any config 
  2. using a data.json only
  3. overriding the password in PingAccess.mv.db (note: this would mean passing both variables)

## PingDirectory

| Path | Location description |
| :--- | :--- |
| `instance` | Any file that you want to be used at product runtime, in accordance with the directory layout of the product. |
| `instance/server/default/conf/pingdirectory.lic` | Use an existing PingDirectory license, rather than the DevOps evaluation license. |
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
| `instance/server/default/conf/pingdatasync.lic` | Use an existing PingDataSync license, rather than the DevOps evaluation license. |
| `instance/config/schema/` | A custom schema. |
| `instance/config/keystore` | Certificates in a Java KeyStore (JKS). |
| `instance/config/keystore.pin` | Certificates in a PKS#12 KeyStore. |
| `instance/config/truststore` | Certificates in a Java TrustStore. |
| `instance/config/truststore.p12` | Certificates in a PKS#12 TrustStore. |
| `instance/config/truststore.pin` | Certificates in a pin-protected TrustStore. |
| `dsconfig` | Directory server configuration fragments. When the container starts, all fragments are appended in the order based on their number prefix, and applied in one large batch. Files must be named using two digits, a dash, a label, and the .dsconfig extension (for example, 12-index-oauth-grants.dsconfig). |
