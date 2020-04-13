# The `ping-devops` utility

`ping-devops` is our general DevOps command line utility. To perform all of its operations, `ping-devops` has a dependency on these utilities:

* openssl
* base64
* kustomize
* kubectl
* envsubst

## Installation

* Use Homebrew, to install `ping-devops` on Apple macos, enter:

  ```bash
  brew tap pingidentity/devops
  brew install ping-devops
  ```

  If not found, the dependent utilities listed above are included in the installation.

* On Linux systems, install the `ping-devops` utility and bash_profile aliases to your current directory by entering:

  ```bash
  curl -s https://raw.githubusercontent.com/pingidentity/ping-devops/master/install.sh | bash
  ```

  You'll then want to copy these to the preferred location in your path (such as, ~/bin or /usr/local/bin).

  Ensure you have the dependent utilities listed above installed as well.

## `ping-devops` Usage

```
################################################################################
#  Ping Identity DevOps
#
#  Documentaion: https://pingidentity-devops.gitbook.io/devops/
#
#  GitHub Repos: https://github.com/pingidentity/pingidentity-devops-getting-started
#                https://github.com/pingidentity/pingidentity-server-profiles
#
################################################################################

Usage:
  ping-devops config                          # Configure Ping DevOps configuration
  ping-devops info                            # Current Ping DevOps configuration

Generate Kubernetes/Kustomize Resource:
  ping-devops generate devops-secret                    # Ping DevOps secret
  ping-devops generate tls-secret <domain>              # TLS Cert/Key (i.e. example.com)
  ping-devops generate ssh-id-secret <ssh id_rsa file>  # SSH ID Key (i.e. ~/.ssh/id_rsa)
  ping-devops generate license-secret <license file>    # License file (i.e. pingdirectory.lic)
  ping-devops generate kustomization.yaml               # Skeleton kustomization.yaml

Generate Ping Identity Server Profile:
  ping-devops generate-profile <product>       # Generates a server-profile for product
    --current-install    /path/to/current-inst # Default: create an empty profile template)
    --generated-profile  /path/to/gen-profile  # Default: current directory with product name)

Examples:
  ping-devops examples

Further help:
  ping-devops commands
  ping-devops help [COMMAND]
  https://github.com/pingidentity/ping-devops
```