# Server profile structures

Each of the Docker images created for our products reflects the server profile structures used by our installed products. The directory paths for these server profiles can differ between products, as can the server profile structures (the directory paths and data). You'll see these server profile structures in the local directory bound to the Docker `/opt/in` volume when you elect to save any changes you make to a server profile. See *Saving your changes* in [Get Started](getStarted.md) for more information.

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
