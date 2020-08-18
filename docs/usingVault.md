# Using Hashicorp Vault with Images

This provides details for using Hashicorp Vault and secrets with Ping Identity DevOps Images.

## What you'll do

In the examples below, the use case involves the storing of PingFederate's master key `pf.jwk` in vault and pulling that into a PingFederate image when started.

You will make use of vault secrets within both:
- Deployment of image in Kubernetes, using the vault injector agent to inject secrets.
- Deploymnnt of image using docker-compose, using the images ability to pull in vault secrets.

## Prerequisites

- You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
- Have a running Hashicorp Vault instance.  Refer to [Deploy Hashicorp Vault](deployVault.md) for information on deploying a vault if you need one.

## Using HashiCorp Vault Injector in kubernetes deployments

If the HashiCorp Vault Injector Agent is installed, annotaions can be added to the `.yaml` file of a Pod, Deployment, StatefulSet resource to pull in the secrets.  The snippet below provides an example set of annotations (placed in to the metadata of the container) to pull in a `pf.jwk` secret into a container.

> Note: This was crated using `ping-devops vault create-annotations pingfederate/encryption-keys` tool.

``` yaml
  annotations:
    #----------------------------------------------------
    # Annotation secretes prepared for hashicorp vault secrets
    # for use in Deployment, StatefulSet, Pod resources.
    #
    # https://www.vaultproject.io/docs/platform/k8s/injector/annotations
    #
    vault.hashicorp.com/agent-pre-populate-only: true
    vault.hashicorp.com/agent-inject: true
    vault.hashicorp.com/role: k8s-default
    vault.hashicorp.com/log-level: info
    vault.hashicorp.com/preserve-secret-case: true
    #------------------------------------------------
    #
    #------------ key: pf.jwk
    vault.hashicorp.com/agent-inject-secret-pf.jwk: "secret/pingfederate/encryption-keys/"
    vault.hashicorp.com/agent-inject-template-pf.jwk: |
      {{ with secret "secret/pingfederate/encryption-keys/" -}}
      {{ .Data.data.pf.jwk }}
      {{- end }}
    #------------------------------------------------
```

Upon starting containers related to this resource, the value for secret `secret/pingfederate/encryption-keys` key of `pf.jwk` will be pulled into the container.  By default, the secret would be placed in to a tmpfs volume `/vault/secrets`.

```
  /vault/secrets/pf.jwk
```

If the secret should be put into a different location by default, the following annotation can be added providng that location.

``` yaml
    vault.hashicorp.com/secret-volume-path-devops.env: /opt/out/instance/server/default/data`
```

resulting in the location

```
  /opt/out/instance/server/default/data/pf.jwk
```

## Using HashiCorp Vault Secrets in native PingIdentity DevOps Images

Vault secrets can also be used in native PingIdentity DevOps Images regardless of the environment they are deployed in (i.e. kubernetes, docker, docker-compose).  In these cases, there is no injector agent avaialable.  Best example is when using docker-compose to perform testing when vault secrets are needed.

There are a set of variables that can be used when deploying an image that will instruct the image how to use Vault to obtain and deploy the secrets on startup.

| Variable            | Example     | Description
| ------------------- | ----------- | ---------------------------------
| SECRETS_DIR         | /vault/secrets    | Location where secrets will be stored by default.  Please see section below on using a `tmpfs` mounted filesystem to store secrets in a memory location.
| VAULT_TYPE          | hashicorp   | Type of vault used. Currently supporting hashicorp.
| VAULT_ADDR          | https://vault.example.com:8200 | URL for the vault with secrets
| VAULT_TOKEN         | s.gvC3vd5aFzP8sunSJovV0b0A     | Active token used to authticate/authorize container to vault.  Optional if VAULT_AUTH_USER/VAULT_AUTH_PASSWORD are provided.
| VAULT_AUTH_USER     | demo                           | Username of internal vault identity
| VAULT_AUTH_PASSWORD | secet                          | Password of internal vault identity
| VAULT_SECRETS       | /pingfederate/encryption-keys  | A list of secrets to pull into the container.  Must be the full secret path used in vault.

Below is an example of how these might be used in an docker-compose.yaml file.  Note that this example provides 2 secrets as denoted by the VAULT_SECRETS setting.

``` yaml
services:
  pingfederate:
    image: pingidentity/pingfederate:edge
    environment:
      ...
      ################################################
      # SECRET_LOCATION
      ################################################
      - SECRETES_DIR=/vault/secrets
      ################################################
      # Vault Info
      ################################################
      - VAULT_TYPE=hashicorp
      - VAULT_ADDR=https://vault.ping-devops.com:8200
      - VAULT_TOKEN=s.gvC3vd5aFzP8sunSJovV0b0A
      - VAULT_SECRETS=/pingfederate/encryption-keys
                      /pingfederate/license

```

Assuming the following secret defintion of each secret:

```
$ vault kv get secret/pingfederate/encryption-keys

====== Data ======
Key          Value
---          -----
pf.jwk       {"keys":[{"kty":"oct","kid":"....yy5yZ","k":"...YBi1z..."}]}

$ vault kv get secret/pingfederate/license

========== Data ==========
Key                 Value
---                 -----
pingfederate.lic    ID=....789
                    Product=PingFederate
                    ...
```

This would result in the following files:

```
  /vault/secrets/pf.jwk
  /vault/secrets/pingfederate.lic
```

## Special secret metadata

By default, all the keys in a secret translate to a file that is created with the value representing the file contents.

```
secret-name
  KEY         VALUE            File Created
  ---         -----            ------------
  pf.jwk      {"keys"...}      ${SECRET_DIR}/pf.jwk
  pa.jwk      {"keys"...}      ${SECRET_DIR}/pa.jwk
```

However, there are special use cases that the Ping Identity DevOps images will support depending on the secret name and special keys (i.e. meta information) found in the secret.
- Storing the key=value pairs as variable settings (i.e. property file)
- Specifying a path that should copy/link from
- Specifying special permission to assign the secret (default: `0400`)
- Specifying that the key contents are base64 encoded, to be decoded when created into container

Special secret metadata is provided by key naems starting with an underscore (_).  The following table provides the *optional* metadata details that can be used in a secret.

| Metadata            | Options        | Description
| ------------------- | -------------- | ---------------------------------
| _type               | properties     | Creates a file with `name=value` for each key/value.  This is optional, and default is to create a file for each key.
| _location           | {path}         | Places file(s) in this path location.  This is optional, and default is to place in ${SECRETS_DIR} location.
| _link               | {path}         | Creates link(s) from this path location to file(s). If there is a file in this location, it will be replaced by the symbolic link(s).  This is optional, and default is no link created.
| _permission         | {unix chmod mode} | Sets permission on created file(s). This is optional, and default is `0400`.



Example: If the secret has a key/value of the name `_type=properties`, then a property file will be created with each kv pair as an entry in that file.

```
Secret: .../app-environment
  KEY         VALUE
  ---         -----
  _type       properties
  _location   /vault/secrets/app-secrtes/app.props
  _link       /opt/app/application.properties
  PROP_1      value 1
  PROP_2      value 2
```

would result in the following file:

```
/opt/app/application.properites --> /vault/secrets/app-secrtes/app.props
  CONTENTS
  --------
  PROP_1="value 1"
  PROP_2="value 2"
```

Special key name suffixes can be used to perform certain processing on the keys when the file is crated.  The following table provides examples of how keys with special suffixes.

| Key Suffix          | Description
| ------------------- | ---------------------------------
| .b64 or .base64     | Specifies that the value is base64 encoded and the resulting file should be decoded when written.

Example:

```
Secret: .../app-environment
  KEY         VALUE
  ---         -----
  msg.b64     SGVsbG8gV29ybGQhCg==
```

would result in the following files:

```
/opt/app/msg.b64
  CONTENTS
  --------
  SGVsbG8gV29ybGQhCg==

/opt/app/msg
  CONTENTS
  --------
  Hello World!
```

## Providing a tmpfs shared memory volume for secrets

It is best practice to place secrets in a volume that won't be persisted to storage with the possibility that it might be improperly accessed at any point in the future.  Options include locations like `/tmp` or as provided in the docker-compose.yal example below a `tmpfs` volume mount.

This docker-compose.yaml example will create a `tmpfs` type volume and size it to `32m` and mount it to a path of `/vault/secrets`.

``` yaml
version: "2.4"

services:
  pingfederate:
    image: pingidentity/pingfederate:10.1.0-alpine-az11-build-gdo-408-3051
    environment:
      - SECRETS_DIR=/vault/secrets

    ################################################
    # /vault/secrets - tmpfs
    ################################################
    volumes:
      - type: tmpfs
        target: /vault/secrets
        tmpfs:
          size: 32m
```



