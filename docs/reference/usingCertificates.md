---
title:  Using Certificates with Images
---
# Using Certificates with Images

This provides details for using certificates with the Ping Identity images.  Specifically, the preferred locations to place the certificate and pin/key files to provide best security practices and use by the underlying Ping Identity product.

Currently, certificates can be provided to the PingData products when the containers are started.

!!! warning "Prior to 2008 sprint release"
    We encouraged these to be placed into the server profile (i.e. .../.sec/keystore).  For security best practices, this is no longer a recommended approach.
    Rather a secret should be used to pass this material to the containers.

## What You'll Do

The examples below will explain and show examples of:

* Deploying a certificate/pin combo to an image in a secure way

## Prerequisites

* You've already been through [Get started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Preferably, have a secrets management system (i.e. Hashicorp Vault) that holds your certificate and places them into your SECRETS_DIR (i.e. /run/secrets).
  Refer to [Using Hashicorp Vault](../how-to/usingVault.md) for information on using a vault if you have one.

## PingData Image Certificates

The PingData products (i.e. PingDirectory, PingDataSync, PingDataGovernance, PingDirectoryProxy) use a file location to determine certificates/pin files.
It is best practice to use non-persistent location (i.e. /run/secrets) to store these files.
If no certificate is provided, the container/product will generate a self-signed certificate.

The default location for certificates and associated files are listed below (assumes a default SECRETS_DIR variable of `/run/secrets`).

|                      | Variable Used        | Default Location/Value<br>/run/secrets... | Notes                                                |
| -------------------- | -------------------- | ----------------------------------------- | ---------------------------------------------------- |
| Keystore (JKS)       | KEYSTORE_FILE        | keystore                                  | JKS Format. Set as default in absence of .p12 suffix |
| Keystore (PKCS12)    | KEYSTORE_FILE        | keystore.p12                              | PKCS12 Format                                        |
| Keystore Type        | KEYSTORE_TYPE        | jks or pkcs12                             | Based on suffix of KEYSTORE_FILE                     |
| Keystore PIN         | KEYSTORE_PIN_FILE    | keystore.pin                              |                                                      |
| Truststore (JKS)     | TRUSTSTORE_FILE      | truststore                                | Set as default in absence of .p12 suffix             |
| Truststore (PKCS12)  | TRUSTSTORE_FILE      | truststore.p12                            | PKCS12 Format                                        |
| Truststore Type      | TRUSTSTORE_TYPE      | jks or pkcs12                             | Based on suffix of TRUSTSTORE_FILE                   |
| Truststore PIN       | TRUSTSTORE_PIN_FILE  | truststore.pin                            |                                                      |
| Certificate Nickname | CERTIFICATE_NICKNAME | see below                                 |                                                      |

!!! note "CERTIFICATE_NICKNAME Setting"
    There is an additional certificate based variable used to identity the certificate alias used within the `KEYSTORE_FILE`.
    That variable is called `CERTFICATE_NICKNAME` which identifies the certificate to use by the server in the `KEYSTORE_FILE`.
    If a value isn't provided, the container will look a the list certs found in the `KEYSTORE_FILE`
    and if 1 an only 1 certificate is found of type `PrivateKeyEntry`, then that alias will be used.

!!! example "Specifying your own location for a certificate"

If you are relying on certificates to be mounted to a different locations than the SECRET_DIR location and/or name of the files, you can provide your own values to these variables identified above to specify those locations.  As an example:

```properties
KEYSTORE_FILE=/my/path/to/certs/cert-file
KEYSTORE_PIN_FILE=/my/path/to/certs/cert.pin
KEYSTORE_TYPE=jks
CERTIFICATE_NICKNAME=development-cert
```

## Non PingData Image Cerfificates

For non PingData images (i.e. PingAccess, PingFederate) the certificates are managed withing the product configs.

