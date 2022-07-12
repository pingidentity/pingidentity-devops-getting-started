---
title: pingctl kubernetes - Generate kubernetes resources
---

# pingctl kubernetes

## Description

Manage Ping related Kubernetes resources.

* Generate `devops-secret` secret containing Ping DevOps variables `PING_IDENTITY_DEVOPS_KEY` and `PING_IDENTITY_DEVOPS_SECRET`
* Generate `tls-secret` secret containing a self-signed certificate and key for a specified domain.
* Generate `ssh-id-secret` secret containing a file with ssh id (i.e. ~/.ssh/id_rsa)
* Generate `license-secret` secret containing a Ping Identity product license file or generated eval license
* Provide details about a cached kubectl oidc token
  * Display the entire jwt token
  * Display a specific claim
  * Clear the kubectl oidc cache

## Usage

    pingctl kubernetes generate devops-secret
    pingctl kubernetes generate tls-secret {domain}
    pingctl kubernetes generate ssh-id-secret {ssh id_rsa file}
    pingctl kubernetes generate license-secret {license file}
    pingctl kubernetes generate license-secret {product} {ver}

    pingctl kubernetes oidc clear
    pingctl kubernetes oidc {claim}
    pingctl kubernetes oidc info

## Options

