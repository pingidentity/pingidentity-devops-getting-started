# Using Certificates with Images

This provides details for using certificates with the Ping Identity images.  Specifically, the preferred locations to place the certificate and pin/key files to provide best security practices and use by the underlying Ping Identity product.

Currently, certificates can be provided to the PingData products when the containers are started.

> Note: Prior to 2008 sprint release, we encouraged these to be placed into the server profile (i.e. .../.sec/keystore).  For seceurity best practices, this is no longer a recommended approach.  Rather a secret shoudl be used to pass this material to the containers.

## What you'll do

The examples below will explain and show examples of:
- Deploying a certficate/pin combo to an image in a secure way

## Prerequisites

- You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
- Preferably, have a secrets management system (i.e. Hashicorp Vault) that holds your certifcate and places them into your SECRETS_DIR (i.e. /run/secrets).  Refer to [Using Hashicorp Vault](usingVault.md) for information on using a vault if you have one.


## Usage of certificates in PingIdentity DevOps Images

### PingData images (i.e. PingDirectory, PingDataSync, PingDataGovernance, PingDirectoryProxy)

These products are able to make use of certificates from a location (i.e. /run/secrets) outside of the deployed product files (/opt/out/instance).  If not certificate is provided, the container/product will generate a self-signed certificate.  Please see important note below for PingDirectory.

>Note: If you intended to RESTART the PingDirectory, you MUST provide a certificate on the initial setup of the container.

The default location for certificates and associated files are listed below (assumes a default SECRETS_DIR varialbe of `/run/secrets`).

|                      | Variable Used          | Default Location/VAlue        | Notes
| -------------------- | ---------------------- | ----------------------------- | -------------------
| Keystore (JKS)       | `KEYSTORE_FILE`        | `/run/secrets/keystore`       | JKS Format. Set as default in absence of .p12 suffix
| Keystore (PKCS12)    | `KEYSTORE_FILE`        | `/run/secrets/keystore.p12`   | PKCS12 Format
| Keystore Type        | `KEYSTORE_TYPE`        | `jks` or `pkcs12`             | Based on suffix of KEYSTORE_FILE
| Keystore PIN         | `KEYSTORE_PIN_FILE`    | `/run/secrets/keystore.pin`   |
| Truststore (JKS)     | `TRUSTSTORE_FILE`      | `/run/secrets/truststore`     |  Set as default in absence of .p12 suffix
| Truststore (PKCS12)  | `TRUSTSTORE_FILE`      | `/run/secrets/truststore.p12` | PKCS12 Format
| Truststore Type      | `TRUSTSTORE_TYPE`      | `jks` or `pkcs12`             | Based on suffix of TRUSTSTORE_FILE
| Truststore PIN       | `TRUSTSTORE_PIN_FILE`  | `/run/secrets/truststore.pin` |
| Certificate Nickname | `CERTIFICATE_NICKNAME` | see below                     |


There is an additional certificate based varialbe used to identity the certificate alias used within the `KEYSTORE_FILE`.  That variable is called `CERTFICATE_NICKNAME` which identifies the certifiate to use by the server in the `KEYSTORE_FILE`.  If a value isn't provided, the container will look a the list certs found in the `KEYSTORE_FILE` and if 1 an only 1 certificate is found of type `PrivateKeyEntry`, then that alias will be used.

#### Specifying your own location for a certificate

If you are realying on certicates to be mounted to a different locations than the SECRET_DIR location and/or name of the files, you can provide your own values to these variables identified above to specify those locations.  As an example:

```
   KEYSTORE_FILE=/my/path/to/certs/cert-file
   KEYSTORE_PIN_FILE=/my/path/to/certs/cert.pin
   KEYSTORE_TYPE=jks
   CERTIFICATE_NICKNAME=development-cert
```

### Non PingData images (i.e. PingAccess, PingFederate)

The certificates are managed withing the product configs.

