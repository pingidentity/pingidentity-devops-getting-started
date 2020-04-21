## Overview of Server Profile

The server profiles used in this example are based off the standalone profiles and do not contain additional configuration items beyond supporting Vault. The vault master key package requires 3 files:

- vault.config.properties
- VaultMasterKeyEncryptor.jar
- vault-java-driver-5.1.0.jar

Each of the above files are deployed in specific places for each product. The location is specified in the product's sample server-profile for this repo.

#### vault.config.properties

The common MasterKeyEncryptor implemention uses a java properties file to assist in communicating successfully with your Vault environment. This properties file is used across all products.

Note: This file **does support** variable subsitution. 

| Property Name | Description | Example |
|---------------|-------------|--------------|
| vault.api.address |  The base URL used to communicate with VAULT. | https://10.101.10.1:8200 |
| vault.api.token   | The client vault token used to authenticate to the Vault API. | |
| vault.api.verifyssl | True = verifies that the SSL cert is trusted or issued by a trusted CA. | false |
| vault.api.opentimeout | How long (in seconds) to keep an open connection | 5 |
| vault.api.readtimeout | How long (in seconds) to read data from a connection before timing out | 5 |
| vault.api.maxretry | The number of retries the http client will attempt to communicate with the Vault| 3 |
| vault.auth.roleid | The role id value for AppRole authentication (Mainly used in docker-compose environments). ||
| vault.auth.k8s.role | The kubernetes auth role used to identify the application/pod. | `<namespace>-<environment>-pingfederate` |
| vault.create.key | True if the application will create the transit key on startup. | true |
| vault.secret.path | Unique URI path to store the master key. | `<namespace>/<environment>/<product>/masterkey`  |
| vault.transit.keytype | Vault transit key type. Currently rsa-4096 and rsa-2048 are only supported | rsa-4096 |
| vault.tls.server.crt | Base64 encoded Vault TLS public cert or CA cert |  MIIEHDCCAwSgAwIBAgIBAzANBg..... |

### PingFederate

For PingFederate, you will need to make changes to the `hivemodule.xml` and `com.pingidentity.crypto.jwk.MasterKeySet.xml` files. 

#### hivemodule.xml

Locate the below XML block and update the class attribute with the following value: `com.pingidentity.gsa.devops.keymanagement.VaultMasterKeyEncryptor`
By default, the class value is `com.pingidentity.crypto.jwk.NoOpMasterKeyEncryptor`

```xml
    <!--
        Service for encrypting/decrypting PingFederate's master key file (pf.jwk). The default
        implementation does no operation and hence the keys are stored in plain text. Any custom
        implementation can be created and referred to here. Ping Federate 9.3 added support for
        master key encryption using AWS Key Management Services. See the PingFederate SDK's
        com.pingidentity.sdk.key.MasterKeyEncryptor interface for more info.

        Supported classes are
            com.pingidentity.crypto.jwk.NoOpMasterKeyEncryptor                    : The default implementation that does no operation.
            com.pingidentity.pingcommons.aws.key.AwsKmsMasterKeyEncryptor         : AWS KMS implementation. Note that admin should specify the key Id in MasterKeySet.xml.
     -->
    <service-point id="MasterKeyEncryptor" interface="com.pingidentity.sdk.key.MasterKeyEncryptor">
        <create-instance class="com.pingidentity.gsa.devops.keymanagement.VaultMasterKeyEncryptor"/>
    </service-point>
```

#### com.pingidentity.crypto.jwk.MasterKeySet.xml

Update the keyId value to uniquely describe the transit key for this application. Hint: Using the k8s role name is a good option.

Note: This file **does support** variable subsitution.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<con:config xmlns:con="http://www.sourceid.org/2004/05/config">
    <!--Uncomment the below attribute to use an external key for encryption of PF Master Key.

        <con:item name="keyId"> put the key Id here </con:item>-->
    <con:item name="keyId"><namespace>-<env>-pingfederate</con:item>
    <con:item name="jwkEncrypted">true</con:item>
</con:config>
```

### PingAccess

For PingAccess, you will need to update the following file: pa.jwk.properties. 

#### pa.jwk.properties

Update the pa.hostkey.masterKeyEncryptor property with the following value: `com.pingidentity.gsa.devops.keymanagement.VaultMasterKeyEncryptor`

```
pa.hostkey.masterKeyEncryptor=com.pingidentity.gsa.devops.keymanagement.VaultMasterKeyEncryptor
```
