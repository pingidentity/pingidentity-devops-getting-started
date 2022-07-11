---
title:  Using Certificates with Images
---
# Using Certificates with Images

This page provides details for using certificates with the Ping Identity images. Specifically it outlines the preferred locations to place the certificate and PIN/key files to provide best security practices and enable use by the underlying Ping Identity product.

Currently, certificates can be provided to the PingData products when the containers are started.

!!! warning "Prior to the 2008 sprint release"
    Before the 2008 release, you were encouraged to place these files in the server profile (.../.sec/keystore). To align with security best practices, this approach is no longer longer recommended Instead, use a secret to pass the files to the containers.

## Before you begin

You must:

* Complete [Get started](../get-started/introduction.md) to set up your DevOps environment and run a test deployment of the products.
* Strongly recommended: Have a secrets management system, such as Hashicorp Vault, that holds your certificate and places them into your SECRETS_DIR (/run/secrets).

  For information on using a vault, if you have one, see [Using Hashicorp Vault](../how-to/usingVault.md).

## About this topic

The following examples explain how to deploy a certificate/PIN combination to an image in a secure way.

## PingData Image Certificates

The PingData products, such as PingDirectory, PingDataSync, PingAuthorize, and PingDirectoryProxy, use a file location to determine certificates/PIN files:

* It is best practice to use a non-persistent location, such as /run/secrets, to store these files.
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
    If a value is not provided, the container will look at the list certs found in the `KEYSTORE_FILE` and if one - and only one - certificate is found of type `PrivateKeyEntry`, that alias will be used.

!!! example "Specifying your own location for a certificate"
    If you are relying on certificates to be mounted to a different locations than the SECRET_DIR location or a different filename, you can provide your own values for those variables identified above. As an example:

    ```properties
    KEYSTORE_FILE=/my/path/to/certs/cert-file
    KEYSTORE_PIN_FILE=/my/path/to/certs/cert.pin
    KEYSTORE_TYPE=jks
    CERTIFICATE_NICKNAME=development-cert
    ```
## PingData image certificate rotation

As mentioned above, for the PingData products there are variables for truststore and keystore. To change certificates, you will need to update the contents of the truststore or keystore in your server profile or secret store. After you update the contents, restart the container. The changes will be picked up automatically when the server restarts. If you have multiple certificates in the keystore, you can use the above-mentioned CERTIFICATE_NICKNAME variable to specify the certificate. The container will pick up that certificate from those stored in the keystore. For updating the product to use the new certificates, perform a rolling update. This action ensures that other servers will remain available as each pod is cycled. In addition, verify that remaining pods in the cluster have sufficient capacity to handle the increased load during the rolling update.

## Non-PingData image certificates

For non-PingData images, such as PingAccess and PingFederate, the certificates are managed within the product configurations.
