# The `ping-devops` utility

`ping-devops` is our general DevOps command line utility. To perform all of its operations, `ping-devops` has a dependency on these utilities:

* openssl
* base64
* kustomize
* kubectl
* envsubst
* jq

## Installation/Update

* Use Homebrew, to install `ping-devops` on Apple or Linux:

  * Install
    ```bash
    brew tap pingidentity/devops
    brew install ping-devops
    ```

  * Upgrade
    ```bash
    brew upgrade ping-devops
    ```

  The dependent utilities listed above will also be installed/upgraded during this process.

* On Linux systems without brew, install/upgrade the `ping-devops` utility and bash_profile aliases to your current directory by entering:

  ```bash
  curl -sL https://bit.ly/ping-devops-install | bash
  ```

  Follow instructions to copy these to the preferred location.

  Ensure you have the dependent utilities listed above installed as well.

## `ping-devops` Usage

```
################################################################################
#  Ping Identity DevOps (version 0.6.0)
#
#  Documentation: https://pingidentity-devops.gitbook.io/devops/
#   GitHub Repos: https://github.com/topics/ping-devops
################################################################################

General Usage:
  ping-devops config                            # Configure Ping DevOps
  ping-devops info [-v]                         # Print Config Information
  ping-devops version                           # Version Details and Check
  ping-devops topic [ {topic-name} ]            # Short Help Topics

Generate Kubernetes/Kustomize/License Resources:
  ping-devops generate devops-secret                    # Ping DevOps secret
  ping-devops generate tls-secret {domain}              # TLS Cert/Key (i.e. example.com)
  ping-devops generate ssh-id-secret {ssh id_rsa file}  # SSH ID Key (i.e. ~/.ssh/id_rsa)
  ping-devops generate license {product}                # Eval license file for product
  ping-devops generate license-secret {license file}    # License secret from license file
  ping-devops generate kustomization.yaml               # Skeleton kustomization.yaml

Running Docker/Kubernetes Evironments:
  ping-devops docker     [info|start|stop|rm|clean]
  ping-devops kubernetes [info|start|rm|clean]

Further help:
  https://github.com/pingidentity/ping-devops
```