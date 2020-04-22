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
#  Ping Identity DevOps (version 0.5.3)
#
#  Documentaion: https://pingidentity-devops.gitbook.io/devops/
#
#  GitHub Repos: https://github.com/pingidentity/pingidentity-devops-getting-started
#                https://github.com/pingidentity/pingidentity-server-profiles
#
################################################################################

Usage:
  ping-devops config                          # Configure Ping DevOps
  ping-devops info [-v]                       # Config Information
  ping-devops version                         # Version Details and Check

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

Running Docker Getting Started Containers:
  ping-devops docker info                      # Lists all available use-cases/products
  ping-devops docker info <product>            # Information on user-case/product
  ping-devops docker start <product>           # Starts services  (i.e. docker-compose up)
  ping-devops docker stop <product>            # Stops services   (i.e. docker-compose stop)
  ping-devops docker rm <product>              # Removes services (i.e. docker-compose down)
  ping-devops docker clean                     # Cleans all ping_devops docker services

Further help:
  https://github.com/pingidentity/ping-devops
```