---
title:  Using Certificates with PingData Images
---
# Using Certificates with PingData Images

This page provides details for using certificates with the Ping Identity images. Specifically, it outlines the preferred locations to place the certificate and PIN/key files to provide best security practices and enable use by the underlying Ping Identity product.

Currently, certificates can be provided to the PingData products (PingDirectory, PingDataSync, PingAuthorize, and PingDirectoryProxy) when the containers are started. For non-PingData images, such as PingAccess and PingFederate, the certificates are managed within the product configurations. Those images will not be covered here.

## Before you begin

You must:

* Complete [Get started](../get-started/introduction.md) to set up your DevOps environment and run a test deployment of the products.
* Strongly recommended: Have a secrets management system, such as Hashicorp Vault, that holds your certificate and places them into your SECRETS_DIR (/run/secrets).

  For information on using a vault, if you have one, see [Using Hashicorp Vault](../how-to/usingVault.md).

## About this topic

The following examples explain how to deploy a certificate/PIN combination to an image in a secure way.

## PingData Image Certificates

The PingData products use a file location to determine certificates/PIN files:

* It is best practice to use a non-persistent location, such as /run/secrets, to store these files.
* If no certificate is provided, the container/product will generate a self-signed certificate.

The default location for certificates and associated files are listed below, assuming a default SECRETS_DIR variable of `/run/secrets`.

|                      | Variable Used        | Default Location/Value<br>/run/secrets... | Notes                                                |
| -------------------- | -------------------- | ----------------------------------------- | ---------------------------------------------------- |
| Keystore (JKS)       | KEYSTORE_FILE        | keystore                                  | Java KeyStore (JKS) Format. Set as default in absence of .p12 suffix. |
| Keystore (PKCS12)    | KEYSTORE_FILE        | keystore.p12                              | PKCS12 Format                                        |
| Keystore Type        | KEYSTORE_TYPE        | jks, pkcs12, pem, or bcfks                | Based on suffix of KEYSTORE_FILE.<br>Only use BCFKS in FIPS mode. |
| Keystore PIN         | KEYSTORE_PIN_FILE    | keystore.pin                              |                                                      |
| Truststore (JKS)     | TRUSTSTORE_FILE      | truststore                                | Set as default in absence of .p12 suffix.            |
| Truststore (PKCS12)  | TRUSTSTORE_FILE      | truststore.p12                            | PKCS12 Format                                        |
| Truststore Type      | TRUSTSTORE_TYPE      | jks, pkcs12, pem, or bcfks                | Based on suffix of TRUSTSTORE_FILE.<br>Only use BCFKS in FIPS mode. |
| Truststore PIN       | TRUSTSTORE_PIN_FILE  | truststore.pin                            |                                                      |
| Certificate Nickname | CERTIFICATE_NICKNAME | see below                                 |                                                      |

!!! note "CERTIFICATE_NICKNAME Setting"
    There is an additional certificate-based variable used to identity the certificate alias used within the `KEYSTORE_FILE`.
    That variable is called `CERTIFICATE_NICKNAME`, which identifies the certificate to use by the server in the `KEYSTORE_FILE`.
    If a value is not provided, the container will look at the list certs found in the `KEYSTORE_FILE` and if one - and only one - certificate is found of type `PrivateKeyEntry`, that alias will be used.

!!! example "Specifying your own location for a certificate"
    If you are relying on certificates to be mounted to a different location than the SECRET_DIR location or a different filename, you can provide your own values for those variables identified above. As an example:

    ```properties
    KEYSTORE_FILE=/my/path/to/keystores/keystore
    KEYSTORE_PIN_FILE=/my/path/to/keystores/keystore.pin
    KEYSTORE_TYPE=jks
    CERTIFICATE_NICKNAME=development-cert
    ```

## PingData image certificate rotation
The certificate rotation process for PingData products varies depending on which product is being configured and whether that product is in a topology. For products that are not in a topology, certificates can be rotated by simply updating the environment variables. For products in a topology, certificate rotation must be done via a command-line call with the servers in the topology online.

### Rotating the listener certificate by adjusting environment variables
The process described in this section can be used for PingAuthorize, PingDirectoryProxy, and *standalone* (single-server) instances of PingDirectory or PingDataSync.

!!! warning
    If PingDirectory or PingDataSync is deployed with multiple servers, use the process described in the next section.

As mentioned above, for the PingData products there are variables defining the server truststore and keystore. To change certificates, you will need to update the contents of the truststore or keystore in your external storage (Vault etc.). After you update the contents, restart the container. The changes will be picked up automatically when the server restarts. If you have multiple certificates in the keystore, you can use the above-mentioned CERTIFICATE_NICKNAME variable to specify the certificate. The container will pick up that certificate from those stored in the keystore. For updating the product to use the new certificates, perform a rolling update. This action ensures that other servers will remain available as each pod is cycled.

!!! note "Rolling Update"
    Verify that remaining pods in the cluster have sufficient capacity to handle the increased load during the rolling update.

### Rotating the listener certificate with the replace-certificate command-line tool
If multiple PingDataSync or PingDirectory servers are running in a topology, then the servers must be online when updating the listener certificate. Updates to certificates with one or more servers offline (such as rolling updates) can lead to connection issues with the other members of the topology when those servers come back online. Use the PingData `replace-certificate` command-line tool to update certificates with the server online.

!!! warning
    If your keystore and truststore files are on a read-only filesystem, use the process described in the next section.

Shell into the running instance that needs to be updated, and ensure the keystore containing the needed certificate is mounted on the container. Then, run `replace-certificate`. Replace the `--key-manager-provider` and `--trust-manager-provider` values if necessary when using a non-JKS keystore, as well as the `--source-certificate-alias` value if necessary.

```
replace-certificate replace-listener-certificate \
    --key-manager-provider JKS \
    --trust-manager-provider JKS \
    --source-key-store-file /run/secrets/newkeystore \
    --source-key-store-password-file /run/secrets/newkeystore.pin \
    --source-certificate-alias server-cert \
    --reload-http-connection-handler-certificates
```

For more information on this command, run
```
replace-certificate replace-listener-certificate --help
```

Running the first command will replace the listener certificate and notify other servers in the topology that this server's certificate has changed.

To update certificates for the other servers in the topology, follow this same process, shelling into each individual instance.

Once this is done, the running pods have been updated. To ensure a restart does not undo these changes, verify that your server profile and orchestration environment variables are updated to point to the new certificates. For example, if you have modified your server configuration to point to `/run/secrets/newkeystore`, then you must update your KEYSTORE_FILE environment variable to point to that new keystore *after* you have completed the `replace-certificate` process on each server.

### Rotating the listener certificate when your keystore and truststore are on a read-only filesystem
Typically, the `replace-certificate` tool will edit your keystore and truststore when rotating your listener certificate. Because of this, the above method will not work when the keystore and truststore are read-only. In this case, use one of the two following processes to rotate your listener certificates.

#### Rotating certificates when they are all signed by the same issuer certificate
If all your listener certs will be signed by the same certificate authority, you can add this CA to your server instance listeners to make rotation easier, as the servers will automatically trust certificates signed by the CA.

##### Add the issuer certificate to the server instance listeners in the topology

- Copy a PEM file of the your issuer certificate onto your pods. For this example the path will be `/opt/out/instance/config/ca.crt`.
- On each server, use `replace-certificate` to add the issuer certificate to the server instance listener for that server. This will make the servers trust each other provided they are using a cert signed by this issuer. *Note* that this must be done with all servers online, so that the change gets replicated to the other servers.
    
```
replace-certificate add-topology-registry-listener-certificate \
    --certificate-file /opt/out/instance/config/ca.crt
```

##### Point the server's key manager provider at your new certificate

- Ensure your new certificate has been added to your keystore in whatever external storage method you are using (Vault, etc.), and note the alias you have given the new cert. For this example the alias will be `newcert`.
- Set `CERTIFICATE_NICKNAME=newcert` and perform a rolling update. `manage-profile replace-profile` will run and point your connection handlers to `newcert`, while the servers will continue to trust each other since that cert was signed by the trusted CA you added in the previous step.

##### Removing the old certs

- If desired, you can now remove unused certs from the server instance listeners in the topology registry. You can also remove the old certs from your keystores in your external storage. To remove the old certs from the topology registry, use `replace-certificate`, running the following command on each server in the topology. *Note* that again this must be done with all servers online, so that the config change gets mirrored across the topology.
```
replace-certificate purge-retired-listener-certificates
```

- It is also possible to purge the retired certificates from a single server rather than running a command on each pod, but it requires some configuration changes since it relies on an extended operation and a specific topology admin permission, so it will likely be easier to simply run the previous command on each server. Using dsconfig, the necessary changes would be:

```
dsconfig create-extended-operation-handler \
   --handler-name "Replace Certificate Extended Operation Handler"  \
   --type replace-certificate  \
   --set enabled:true  \
   --set allow-remotely-provided-certificates:true 
dsconfig set-topology-admin-user-prop \
   --user-name admin  \
   --add privilege:permit-replace-certificate-request 
```

- After these changes are in place on the other servers, the following command can be used to purge retired listener certificates from remote instances:

```
replace-certificate purge-remote-retired-listener-certificates
```

#### Rotating certificates without the assumption that they are all signed by the same issuer certificate

##### Add the new cert to the server instance listeners in the topology
    
- Add the new desired certificate to your keystore and truststore, in whatever external storage method you are using. Note that you are just adding the new cert, not removing the old one yet. Note the alias that you have given the new cert in the keystore. In these examples the new cert's alias will be `newcert` and the previous one `server-cert`.
- Ensure the pods have the updated keystore and truststore on the filesystem, via a rolling update. At this point the keystores and truststores will have both the old cert and the new cert, but the new one is not yet being used.
- On each server, export the PEM file of the new certificate to a writable location, using the `manage-certificates` tool. This action is necessary because the subsequent command can only use a PEM file, it can’t read from a keystore directly.

```
manage-certificates export-certificate \
    --keystore /run/secrets/keystore \
    --keystore-password-file /run/secrets/keystore.pin \
    --alias newcert \
    --output-file /opt/out/instance/config/newcert.crt \
    --output-format PEM
```

- On each server, use `replace-certificate` to add the exported certificate PEM file to the server instance listener in the topology. *Note* that this step must be done with all servers online, so that the config change is mirrored to the other servers in the topology.

```
replace-certificate add-topology-registry-listener-certificate \
    --certificate-file /opt/out/instance/config/newcert.crt
```

- Now the server will have both the previous cert and the new cert in its server instance listener.

##### Point the server’s key manager provider at the new cert

- There are two ways to do this - first is to change the `CERTIFICATE_NICKNAME` environment variable to point to your new certificate's alias, and then just restart your pods, allowing `manage-profile replace-profile` to apply the change on startup.
- The second is to edit your keystore and truststore and rename your new cert to the same alias as the previous one (in the case of this document, renaming `newcert` to `server-cert` - the previous cert will have to be either renamed or removed from the keystores). This way, the key manager provider for the server will load in the new cert. Then you can restart the pods and the new cert will be loaded on server startup.

##### Removing the old certs

- Refer to the removal step in the previous section.
