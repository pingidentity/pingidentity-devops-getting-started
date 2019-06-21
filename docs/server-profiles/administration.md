# Administration

This document explains how server profiles work for specific Ping Identity Docker images

## What's in it?

Server profiles aim at providing a common convention to adapt the common images into workable containers in all circumstances.

## Layout

### PingFederate

* `instance`

    Place any file that need to be present with the runtime of the product, in accordance with the file layout of the product.

  * Some examples:
    * `instance/server/default/data/drop-in-deployer/data.zip` can be used to apply a configuration archive exported to a container.

      This can be convenient when going from a PingFederate instance to deployed PingFederate containers

    * `server/default/deploy/OAuthPlayground.war`

      automatically deploy the OAuthPlayground web application

    * `instance/server/default/conf/pingfederate.lic`

      inject a PingFederate license into the running container

    * `instance/server/default/conf/META-INF/hivemodule.xml`

      apply a hivemodule configuration to the container

### PingAccess

* `instance`

    Place any file that needs to be present with the runtime of the product, in accordance  with the file layout of the product.

### PingDirectory

* `dsconfig` Provide dsconfig configuration fragments. When the container starts, all the fragments are appended in the order in which they are numbered and applied in one large batch. Files must be named with two digits, a dash, a label, and with the .dsconfig extension \(i.e. 12-index-oauth-grants.dsconfig\).
* `data` Provide ldif data fragments. When the container starts, all the provided files are imported in the order in which they're named. Files must be named with two digits, a dash, the backend name \(the default is userRoot\), a label, and with the .ldif extension for plain LDIF or .ldif.gz for a gzip compressed file For example:
  * `10-userRoot-skeleton.ldif`
  * `20-userRoot-users.ldif.gz`
  * `30-userRoot-groups.ldif`
* `hooks` In this directory you can put a set of custom scripts that will be called at key points during the container startup sequence.
  * On every container start event:
    * `00-immediate-startup.sh` is called immediately upon container startup
  * The first time a container starts:
    * `10-before-copying-bits.sh` is called 
    * `20-before-setup.sh` is called immediately before the setup tool is executed
    * `30-before-configuration.sh` is called immediately before the dsconfig tool is executed
    * `40-before-import.sh` is called immediately before the import-ldif is executed
  * On every container start event:
    * `50-before-post-start.sh` is called before the built-in postStart.sh script is executed in the background
    * `80-post-start.sh` is called instead of the built-in postStart.sh script if it is provided
* `instance` Place any file that needs to be present with the runtime of the product, in accordance with the file layout of the product.
  * You can place custom schema in `instance/config/schema/`
  * You can provide your certificates in a JKS keystore with these two files:

      `instance/config/keystore`

      `instance/config/keystore.pin`

  * You can provide your certificates in a PKCS\#12 keystore with these two files:

      `instance/config/keystore.pin`

  * You can provide your trusted certificates in a JKS trust store by providing this file:

      `instance/config/truststore`

  * You can provide your trusted certificates in a JKS trust store by providing this file:

      `instance/config/truststore.p12`

  * Optionally, if the truststore is pin-protected, provide the

      `instance/config/truststore.pin`

### PingDataSync

* `dsconfig` Provide dsconfig configuration fragments. When the container starts, all the fragments are appended in the order in which they are numbered and applied in one large batch. Files must be named with two digits, a dash, a label, and with the .dsconfig extension
* `instance` Place any file that needs to be present with the runtime of the product, in accordance with the file layout of the product.
  * You can place custom schema in `instance/config/schema/`
  * You can provide your certificates in a JKS keystore with these two files:

      `instance/config/keystore`

      `instance/config/keystore.pin`

  * You can provide your certificates in a PKCS\#12 keystore with these two files:

      `instance/config/keystore.p12`

      `instance/config/keystore.pin`

  * You can provide your trusted certificates in a JKS trust store by providing this file:

      `instance/config/truststore`

  * You can provide your trusted certificates in a JKS trust store by providing this file:

      `instance/config/truststore.p12`

  * Optionally, if the truststore is pin-protected, provide the

      `instance/config/truststore.pin`

