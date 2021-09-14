---
title:  Using Certificates with Images
---
# Using Certificates with Images

This provides details for using certificates with the Ping Identity images, specifically, the preferred locations to place the certificate and PIN/key files to provide best security practices and use by the underlying Ping Identity product.

Currently, certificates can be provided to the PingData products when the containers are started.

!!! warning "Before the 2008 sprint release"
    We encouraged these to be placed into the server profile (.../.sec/keystore). For security best practices, we no longer recommend this approach.
    Instead, use a secret to pass this material to the containers.

## Before you begin

You must:

* Complete [Get started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Preferably, have a secrets management system, such as Hashicorp Vault, that holds your certificate and places them into your SECRETS_DIR (/run/secrets).

  For information on using a vault, if you have one, see [Using Hashicorp Vault](../how-to/usingVault.md).

## About this topic

The following examples explain how to deploy a certificate/PIN combo to an image in a secure way.

## PingData Image Certificates

The PingData products, such as PingDirectory, PingDataSync, PingAuthorize, and PingDirectoryProxy, use a file location to determine certificates/PIN files:

* It's best practice to use non-persistent location, such as /run/secrets, to store these files.
* If no certificate is provided, the container/product will generate a self-signed certificate.

The default location for certificates and associated files are listed below, assuming a default SECRETS_DIR variable of `/run/secrets`.

|                      | Variable Used        | Default Location/Value<br>/run/secrets... | Notes                                                |
| -------------------- | -------------------- | ----------------------------------------- | ---------------------------------------------------- |
| Keystore (JKS)       | KEYSTORE_FILE        | keystore                                  | Java KeyStore (JKS) Format. Set as default in absence of .p12 suffix |
| Keystore (PKCS12)    | KEYSTORE_FILE        | keystore.p12                              | PKCS12 Format                                        |
| Keystore Type        | KEYSTORE_TYPE        | jks or pkcs12                             | Based on suffix of KEYSTORE_FILE                     |
| Keystore PIN         | KEYSTORE_PIN_FILE    | keystore.pin                              |                                                      |
| Truststore (JKS)     | TRUSTSTORE_FILE      | truststore                                | Set as default in absence of .p12 suffix             |
| Truststore (PKCS12)  | TRUSTSTORE_FILE      | truststore.p12                            | PKCS12 Format                                        |
| Truststore Type      | TRUSTSTORE_TYPE      | jks or pkcs12                             | Based on suffix of TRUSTSTORE_FILE                   |
| Truststore PIN       | TRUSTSTORE_PIN_FILE  | truststore.pin                            |                                                      |
| Certificate Nickname | CERTIFICATE_NICKNAME | see below                                 |                                                      |

!!! note "CERTIFICATE_NICKNAME Setting"
    There is an additional certificate-based variable used to identity the certificate alias used within the `KEYSTORE_FILE`.
    That variable is called `CERTIFICATE_NICKNAME`, which identifies the certificate to use by the server in the `KEYSTORE_FILE`.
    If a value isn't provided, the container will look at the list certs found in the `KEYSTORE_FILE`
    and if one and only one certificate is found of type `PrivateKeyEntry`, then that alias will be used.

!!! example "Specifying your own location for a certificate"
    If you are relying on certificates to be mounted to a different locations than the SECRET_DIR location or name of the files, you can provide your own values to these variables identified above to specify those locations. As an example:

    ```properties
    KEYSTORE_FILE=/my/path/to/certs/cert-file
    KEYSTORE_PIN_FILE=/my/path/to/certs/cert.pin
    KEYSTORE_TYPE=jks
    CERTIFICATE_NICKNAME=development-cert
    ```
## PingData image certificate rotation

As mentioned above, for PingData products, there are variables for Truststore and Keystore. To change certificates, you'll need to update the contents in the server profile or secret store. Once you update the contents, restart the server. The changes will be picked up automatically after the server restarts. If you have multiple certificates on the Keystore, you can use the above-mentioned "CERTIFICATE_NICKNAME" variable to specify the certificate. The container will pick up that certificate from the list in the KEYSTORE_FILE.  Perform a rolling update to prevent downtime. This ensures that other servers will be available when one goes down. Verify that other servers in the cluster have enough capacity to handle the increased load.

## Non-PingData image certificates

For non-PingData images, such as PingAccess and PingFederate, the certificates are managed within the product configurations.
