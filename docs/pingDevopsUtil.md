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
| `ping&#8209;devops` | Help. Displays all possible commands. |
| `ping&#8209;devops&nbsp;config` | Similar to the `pingidentity-devops-getting-started/setup` command, this prompts for environment variable settings for `~/.pingidentity/devops`, and `~/.bash_profile`. |
| `ping&#8209;devops&nbsp;info` | Displays the current DevOps environment variable settings. |
| `ping&#8209;devops&nbsp;examples` | Displays configuration help information for all of the DevOps examples. To display the information for specific example types, add `docker`, `kubernetes`, `aws`, `azure`, or `gcloud`. For example, `ping&#8209;devops&nbsp;examples&nbsp;docker`. |
| `ping&#8209;devops&nbsp;generate&nbsp;devops&#8209;secret` | Generates a new DevOps secret. |
| `ping&#8209;devops&nbsp;generate&nbsp;tls&#8209;secret&nbsp;<domain>` | Generates a Kubernetes patch for a new TLS certificate and key for the specified domain. |
| `ping&#8209;devops&nbsp;generate&nbsp;kustomization.yaml` | Generates a skeleton `kustomization.yaml` file for Kubernetes, if one doesn't already exist in the current directory. |

