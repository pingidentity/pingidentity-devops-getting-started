# The `ping-devops` utility

`ping-devops` is our general DevOps command line utility.

## Dependent utilities

To perform all of its operations, `ping-devops` has a dependency on these utilities:

* openssl
* base64
* kustomize
* kubectl
* envsubst
* jq

## Installation and upgrades

* Use Homebrew, to install `ping-devops` on Apple or Linux:

  1. To install, enter:

      ```bash
      brew tap pingidentity/devops
      brew install ping-devops
      ```

  2. To upgrade, enter:

      ```bash
      brew upgrade ping-devops
      ```

  3. Check for upgrades regularly.

  The dependent utilities for `ping-devops` will also be installed or upgraded during this process.

* On Linux systems, install or upgrade the `ping-devops` utility and `bash_profile` aliases to your current directory by entering:

  ```bash
  curl -sL https://bit.ly/ping-devops-install | bash
  ```

  Follow instructions to copy to the preferred location.

  Ensure you have the dependent utilities for `ping-devops` installed as well.

## `ping-devops` Usage

Enter `ping-devops` in a terminal to display the commands listing. The display will be similar to this:

```shell
#####################################################################
#  Ping Identity DevOps (version 0.6.6)
#
#  Documentation: https://pingidentity-devops.gitbook.io/devops/
#   GitHub Repos: https://github.com/topics/ping-devops
#####################################################################

General Usage:
  ping-devops config
  ping-devops info [-v]
  ping-devops version
  ping-devops topic [ {topic-name} ]

Generate Kubernetes/Kustomize/License Resources:
  ping-devops generate devops-secret
  ping-devops generate tls-secret {domain}
  ping-devops generate ssh-id-secret {ssh id_rsa file}
  ping-devops generate license {product}
  ping-devops generate license-secret {license file}
  ping-devops generate kustomization.yaml

Running Docker/Kubernetes Evironments:
  ping-devops docker     [info|start|stop|rm|clean]
  ping-devops kubernetes [info|start|rm|clean]

Further help:
  https://github.com/pingidentity/ping-devops
```
