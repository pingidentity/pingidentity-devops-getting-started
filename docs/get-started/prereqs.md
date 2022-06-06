---
title: Prerequisites
---
# Prerequisites

In order to leverage our resources, you will need the following components, software, or other information.

## Product license

You must have a product license to run our images. You may either:

* Generate an evaluation license obtained with a valid DevOps user key. For more information, see [DevOps Registration](../how-to/devopsRegistration.md).

* Use a [valid product license](../how-to/existingLicense.md) available with a current Ping Identity customer subscription after completing the DevOps Registration process.

## Runtime environment

To try Ping products, you will need an environment in which to deploy. [Rancher Desktop](https://rancherdesktop.io) provides a platform to get started with local Kubernetes development. Rancher Desktop is compatible with Linux, MacOS, and Windows (using WSL). It also supports the [docker container runtime](https://docs.rancherdesktop.io/preferences#container-runtime), which provides support for running docker commands without installing individual docker components or Docker Desktop.  

Other local Kubernetes environments include [kind](https://kind.sigs.k8s.io/), [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Kubernetes enabled, and [minikube](https://minikube.sigs.k8s.io/docs/).

For running Docker Compose deployments, any Docker Desktop installation or Linux system with Docker installed can be used.

## Applications / Utilities
* [Helm](https://helm.sh/docs/intro/install/) cli
* [kubectl](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
* [Homebrew](https://brew.sh) for package installation and management.  Homebrew can be used to install k9s, kubectl, helm, and other programs.
    ```sh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
* [pingctl](../tools/pingctlUtil.md#installation)

    ```sh
    brew install pingidentity/tap/pingctl
    ```

## Recommended Additional Utilities

* [k9s](https://k9scli.io/)
    ```sh
    brew install derailed/k9s/k9s
    ```
* [kubectx](https://github.com/ahmetb/kubectx)
    ```sh
    brew install kubectx
    ```
* [docker-compose](https://docs.docker.com/compose/install/)
    ```sh
    brew install docker-compose
    ```

    !!! info docker-compose installation note
          Installing docker-compose is only necessary to deploy Docker containers when using Docker with Rancher Desktop. It is included with the Docker Desktop installation.
 See [Rancher preferences](https://docs.rancherdesktop.io/preferences#container-runtime) to switch from containerd to dockerd (moby).



## Set Up Your DevOps Environment

1. Open a terminal and create a local DevOps directory named `${HOME}/projects/devops`.

    !!! info Parent Directory
        ${HOME}/projects/devops is the parent directory for all DevOps examples referenced in our documentation.

2. Configure your DevOps environment as follows.

      ```sh
      pingctl config
      ```

      1. Respond to all configuration questions, accepting the defaults if uncertain. Settings for custom variables aren't needed initially but may be necessary for additional capabilities. 
   
      2. All of your responses are recorded in your local `~/.pingidentity/config` file. Allow the configuration script to source this file in your shell profile (for example, `~/.bash_profile` in a bash shell).
   
3. [Optional] Export configured pingctl variables as environment variables

      1. Modify your shell profile (for example, `~/.bash_profile` in a bash shell) so that the generated `source ~/.pingidentity/config` command is surrounded by `set -a` and `set +a` statements.

      ```sh
      set -a
      # Ping Identity - Added with 'pingctl config' on Fri Apr 22 13:57:04 MDT 2022
      test -f '${HOME}/.pingidentity/config' && source '${HOME}/.pingidentity/config'
      set +a
      ```

      2. Verify configured variables are exported in your environment.

            1. Restart your shell or source your shell profile.

            2. Run `env | grep 'PING'`

4. To display your DevOps environment settings, enter:

      ```sh
      pingctl info
      ```

5. To run a quick demonstration of any of our products in your environment, check out our [Helm Basics](../reference/HelmBasics.md) or [Kubernetes Basics](../reference/k8sBasics.md) documentation.

6. For more information on the variables available in ```pingctl``` see [Configuration & Environment Variables](configVars.md).
