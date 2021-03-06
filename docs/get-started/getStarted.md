---
title: Get Started
---
# Get Started

You can quickly deploy Docker images of Ping Identity products. We use Docker, Docker Compose, and Kubernetes to deploy our Docker images in stable, network-enabled containers. Our Docker images are preconfigured to provide working instances of our products, either as single containers or in orchestrated sets.

## Prerequisites

* You have access to [Docker](https://docs.docker.com/install/).
* You have access to [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop on Mac and Windows).
* Your terminal configuration is set to use the Bash shell.

    !!! info "Default Shell"
        With Apple macOS Catalina, the Z shell (zsh) is the default shell, rather than Bash. To set your default terminal shell to Bash, enter `chsh -s /bin/bash`.

* You've installed the [ping-devops](pingDevopsUtil.md#installation) utility.

### Product license

You must have a product license to run our Docker images. You can use either:

* An evaluation license obtained with a valid DevOps user key. For more information, see [DevOps Registration](devopsRegistration.md).

* A valid product license available with a current Ping Identity customer subscription after you complete your DevOps Registration.

## Set Up Your Devops Environment

1. Open a terminal and create a local DevOps directory named `${HOME}/projects/devops`.

    !!! info "Parent Directory"
        is the parent directory for all DevOps examples referenced in our documentation.

1. Configure your DevOps environment as follows.

      ```sh
      ping-devops config
      ```

      1. Respond to all Docker configuration questions, accepting the defaults if you're not sure. You can accept the (empty) defaults for Kubernetes. Settings for custom variables aren't needed initially.

      1. All of your responses are stored as settings in your local `~/.pingidentity/devops` file. Allow the configuration script to source this file in your shell profile (for example, ~/.bash_profile).

1. To display your DevOps environment settings, enter:

      ```sh
      ping-devops info
      ```

1. To run a quick demonstration of any of our products in your Docker environment, use the ping-devops utility.

      1. To display information about the containers or stacks available using the ping-devops utility, enter: 

      ```sh
      ping-devops docker info
      ```

      2. To display information about one of the listed containers or stacks, enter:

      ```shell
      ping-devops docker info <name>
      ```

      Where &lt;name&gt; is one of the listed container or stack names.

1. To start one of the containers or stacks, enter:

      ```sh
      ping-devops docker start <name>
      ```

      Where &lt;name&gt; is one of the listed container or stack names.

      > The initial run will ensure dependencies are met (such as, Docker or Docker Compose).

1. When you have completed set-up:

      To stop the container or stack, enter:

      ```sh
      ping-devops docker stop <name>
      ```

      To remove the container or stack and all associated data, enter:

      ```sh
      ping-devops docker rm  <name>
      ```
