---
title: Kubernetes Get Started
---
# Get Started

This documentation provides a method to quickly deploy containerized images of Ping Identity products via this documentation. Ping Identity images should be compatible across a variety of container platforms including Docker and [Kubernetes](https://www.cncf.io/certification/software-conformance/) (Including via [Helm Charts](https://helm.pingidentity.com/)). Our getting started configurations are designed to provide working instances of our products either as standalone containers or in orchestrated sets.

To quickly try Ping products, you will need an environment to deploy to. [Rancher Desktop](https://rancherdesktop.io) provides a great platform to get started with local Kubernetes development is compatible with Linux, MacOS, and Windows (using WSL). Rancher Desktop also supports the [docker container runtime](https://docs.rancherdesktop.io/preferences#container-runtime), which provides support for running docker commands without installing individual docker components or Docker Desktop.

### Required Utilities

* You have access to a Kubernetes cluster. For local Kubernetes work, [Rancher Desktop](https://rancherdesktop.io) can provide a local Kubernetes cluster.

    !!! info "Kubernetes alternative"
          Alternatively, you may install `kubectl` and `helm` using brew or your preferred package manager:
          ```sh
          brew install helm
          brew install kubectl
          ```
          Installing helm and kubectl individually assumes you have a Kubernetes cluster available, either on a cloud platform such as AWS, Azure, GCP, or other or locally via Minikube, Kind, CodeReady Containers, etc.


* [Homebrew](https://brew.sh) for package installation and management.
    ```sh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

* [pingctl](pingctlUtil.md#installation)

    ```sh
    brew install pingidentity/tap/pingctl
    ```

### Recommended Additional Utilities
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

    !!! info "docker-compose installation note"
          Installing docker-compose is only necessary to deploy [Docker containers](getStartedWithGitRepo.md) when using docker with Rancher Desktop. See [Rancher preferences](https://docs.rancherdesktop.io/preferences#container-runtime) to switch from containerd to dockerd (moby).

### Product license

You must have a product license to run our images. You may either:

* Generate an evaluation license obtained with a valid DevOps user key. For more information, see [DevOps Registration](devopsRegistration.md).

* Use a valid product license available with a current Ping Identity customer subscription after [DevOps Registration](devopsRegistration.md) completion.

## Set Up Your DevOps Environment

1. Open a terminal and create a local DevOps directory named `${HOME}/projects/devops`.

    !!! info "Parent Directory"
        is the parent directory for all DevOps examples referenced in our documentation.

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

5. To run a quick demonstration of any of our products in your environment, check out our [Helm Basics](HelmBasics.md) or [Kubernetes Basics](k8sBasics.md) documentation.

6. For more information on the variables available in ```pingctl``` see [Configuration & Environment Variables](configVars.md).
