---
title: The ping-devops Utility (Deprecated)
---
# The `ping-devops` Utility (Deprecated)

`ping-devops` was our general DevOps command-line utility, but has been superseded by the [pingctl tool](pingctlUtil.md). This page is maintained for referential knowledge only, and the tool is no longer actively maintained or supported. Users are recommended to migrate to the `pingctl` product for continued support.

## Dependent Utilities

To perform all of its operations, `ping-devops` has a dependency on the following utilities:

* openssl
* base64
* kustomize
* kubectl
* envsubst
* jq

## `ping-devops` Usage

Enter `ping-devops` in a terminal to display the commands listing, which is shown in the following example.

```sh
#####################################################################
#  Ping Identity DevOps (version 0.7.2)
#
#  Documentation: https://devops.pingidentity.com
#   GitHub Repos: https://github.com/topics/ping-devops
#####################################################################

General Usage:
  ping-devops config
  ping-devops info [-v]
  ping-devops version
  ping-devops clean
  ping-devops topic [ {topic-name} ]

Generate Kubernetes/Kustomize/License Resources:
  ping-devops generate devops-secret
  ping-devops generate tls-secret {domain}
  ping-devops generate ssh-id-secret {ssh id_rsa file}
  ping-devops generate license {product} {ver}
  ping-devops generate license-secret {license file}
  ping-devops generate license-secret {product} {ver}
  ping-devops generate kustomization.yaml

Running Docker/Kubernetes Environments:
  ping-devops docker     [info|start|stop|rm|clean]
  ping-devops kubernetes [info|start|rm|clean]

Hashicorp Vault:
  ping-devops vault get-token
  ping-devops vault create-annotations {secret}

Further help:
  https://github.com/pingidentity/ping-devops
```
