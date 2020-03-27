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

## `ping-devops` commands

| Command | Description |
| --- | --- |
| `ping-devops` | Help. Displays all possible commands. |
| `ping-devops config` | Similar to the `pingidentity-devops-getting-started/setup` command, this prompts for environment variable settings for `~/.pingidentity/devops`, and `~/.bash_profile`. |
| `ping-devops info` | Displays the current DevOps environment variable settings. |
| `ping-devops examples` | Displays configuration help information for all of the DevOps examples. To display the information for specific example types, add `docker`, `kubernetes`, `aws`, `azure`, or `gcloud`. For example, `ping-devops examples docker`. |
| `ping-devops generate devops-secret` | Generates a Kubernetes Secret object `devops-secret` using a Base64 encoding of your DevOps `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY` values. |
| `ping-devops generate tls-secret <domain>` | Generates a Kubernetes Secret object `tls-secret` using a Base64 encoding of the TLS certificate and key for the specified domain. The certificate is self-signed using OpenSSL. |
| `ping-devops generate kustomization.yaml` | Generates a skeleton `kustomization.yaml` file for Kubernetes, if one doesn't already exist in the current directory. |

