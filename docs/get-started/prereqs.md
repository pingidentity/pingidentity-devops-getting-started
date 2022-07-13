---
title: Prerequisites
---
# Prerequisites

In order to use our resources, you will need the following components, software, or other information.

## Product license

You must have a product license to run our images. You may either use an evaluation license or existing license.
### Evaluation License

Generate an evaluation license obtained with a [valid DevOps user key](../how-to/devopsRegistration.md).  

When you register for Ping Identity's DevOps program, you are issued credentials that automate the process of retrieving an evaluation product license.
!!! note "DevOps User and Key"
    For more information about using your DevOps program user and key in various ways (including Kubernetes and with stand-alone containers) see this how-to guide: [Using Your Devops User and Key](../how-to/devopsUserKey.md)

!!! warning "Evaluation License"
    Evaluation licenses are short-lived (30 days) and **must not** be used in production deployments.

Evaluation licenses can only be used with images published in the last 90 days.  If you want to continue to use an image that was published more than 90 days ago, you must obtain a product license.

### Existing License

If you possess a product license for the product, you can use it with supported versions of the image (including those over 90 days old mentioned above) by following these instructions to [mount the product license](../how-to/existingLicense.md).

!!! note "Mount paths"
    The mount points and name of the license file vary by product.  The link above provides the proper location and name for these files.

## Local runtime environment

The initial example uses Kubernetes under Docker Desktop because it does not require a lot of configuration to use.

In order to try Ping products in a manner most similar to typical production installations, you should consider using a Kubernetes environment. [Kind](https://kind.sigs.k8s.io/) (**K**ubernetes **in** **D**ocker) provides a platform to get started with local Kubernetes development.  Instructions for setting up a Kind cluster are [here](../deployment/deployLocalK8sCluster.md).

Other local Kubernetes environments include [Rancher Desktop](https://rancherdesktop.io), [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Kubernetes enabled, and [minikube](https://minikube.sigs.k8s.io/docs/).

!!! note "Rancher Desktop"
    Rancher Desktop is compatible with Linux, MacOS, and Windows (using WSL). It also supports the [docker container runtime](https://docs.rancherdesktop.io/preferences#container-runtime), which provides support for running docker commands without installing individual docker components or Docker Desktop.  

For running Docker Compose deployments of single products, any Docker Desktop installation or Linux system with Docker and `docker compose` installed can be used.

## Applications / Utilities
* [Helm](https://helm.sh/docs/intro/install/) cli
* [kubectl](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
* [Homebrew](https://brew.sh) for package installation and management.  Homebrew can be used to install k9s, kubectl, helm, and other programs.
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
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

## Configure the Environment

1. Open a terminal and create a local DevOps directory named `${HOME}/projects/devops`.

    !!! info Parent Directory
        ${HOME}/projects/devops is the parent directory for all examples referenced in our documentation.

2. Configure the environment as follows.

      ```sh
      pingctl config
      ```

      1. Respond to all configuration questions, accepting the defaults if uncertain. Settings for custom variables aren't needed initially but may be necessary for additional capabilities.
   
      2. All responses are captured in your local `~/.pingidentity/config` file. Allow the configuration script to source this file in your shell profile (for example, `~/.bash_profile` in a bash shell).
   
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

4. To display your environment settings, run:

      ```sh
      pingctl info
      ```

5. For more information on the options available for ```pingctl``` see [Configuration & Environment Variables](configVars.md).
