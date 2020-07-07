# Get started

You can quickly deploy Docker images of Ping Identity products. We use Docker, Docker Compose, and Kubernetes to deploy our Docker images in stable, network-enabled containers. Our Docker images are preconfigured to provide working instances of our products, either as single containers or as orchestrated sets of containers.  

## Prerequisites

* [Docker](https://docs.docker.com/install/)
* [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop on Mac and Windows)
* You've installed the [ping-devops utility](pingDevopsUtil.md#installation).

### Product license

You'll need a product license to run our Docker images. You can use either:

* An evaluation license obtained with a valid DevOps user key. See [DevOps registration](devopsRegistration.md) for more information.
  
* Although you'll first need to complete your [DevOps registration](devopsRegistration.md), you can subsequently use a valid product license available with a current Ping Identity customer subscription. 

## Set up your DevOps environment

1. Open a terminal and create a local DevOps directory named `${HOME}/projects/devops`.

   > We'll use this as the parent directory for all DevOps examples referenced in our documentation.

2. Configure your DevOps environment:  

    ```bash
    ping-devops config
    ``` 

   a. Respond to all Docker configuration questions, accepting the defaults if you're not sure.  You can accept the (empty) defaults for Kubernetes. Settings for custom variables aren't needed initially.

   b. All of your responses are stored as settings in your local `~/.pingidentity/devops` file. Allow the configuration script to source this file in your shell profile (for example, ~/.bash_profile).

3. To display your DevOps environment settings, enter:

   ```shell
   ping-devops info
   ```

4. You can use the ping-devops utility to run a quick demonstration of any of our products in your Docker environment. 
   
   a. To display information about the containers or stacks available using the ping-devops utility, enter:

   ```shell
   ping-devops docker info
   ```

   b. To display information about one of the listed containers or stacks, enter:

   ```shell
   ping-devops docker <name>
   ```

   Where &lt;name&gt; is one of the listed container or stack names.

5. To start one of the containers or stacks, enter:

    ```shell
    ping-devops docker start <name>
    ```

   Where &lt;name&gt; is one of the listed container or stack names.

     > The initial run will ensure dependencies are met (such as, Docker or Docker Compose).

6. When you're done:

   To stop the container or stack, enter:

    ```shell
    ping-devops docker stop <name>
    ```

    To remove the container or stack and all associated data, enter

    ```shell
    ping-devops docker rm  <name> 
    ```

## Next step

* [Deploy an example stack](getStartedWithGitRepo.md).

