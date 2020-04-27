# Get Started

You can quickly deploy Docker images of Ping Identity products. We use docker, docker-compose and kubernetes to deploy the Ping Identity Docker images in stable, network-enabled containers.  The Ping Identity Docker images are preconfigured to provide working instances of our products, either as single containers or as orchestrated sets of containers.  To choose which is right for you:

* docker/docker-compose - Demo, development and lightweight orchestration purposee
* kubernetes - Enterprise-level orchestration.

## Tools Prerequisites

* [Docker](https://docs.docker.com/install/)
* [Docker Compose](https://docs.docker.com/compose/install/) (already inluded with Docker Desktop on Mac and Windows)
* [ping-devops tool](pingDevopsUtil.md#installation)

## Product License

You will need a product license to run the product docker images.  Options include:

* An evaluation license obtained with a valid DevOps user key.  [Register Here](devopsRegistration.md)
* A valid product license available with a current Ping Identity customer subscription.

## Let's Start

1. Obtain a DevOps user and key.  If you don't alredy have one [Register Here](devopsRegistration.md)
2. Open a terminal and create a local DevOps directory, `${HOME}/projects/devops`.

   > We'll use this as the parent directory for all DevOps examples referenced in our documentation.

3. Install all prerequisites above if you haven't already.
4. Configure your environment for Ping DevOps.  

    ```bash
    ping-devops config
    ``` 

    > Answer all Docker configuration items at a minimum, taking defaults if not sure.  You can take defaults (empty) for Kubernetes and custom variables aren't needed initially.

    > All answers are kept in `~/.pingidentity/devops` file.  Allow the config script to source this file in your shell profile (i.e. ~/.bash_profile). 
  
5. Use ping-devops tool to run a quick demo of any of our products (i.e. pingfederate) in your docker environment.  Follow directions from start command to login to management console once started.

    ```bash
    ping-devops docker info
    ping-devops docker info  pingfederate
    ping-devops docker start pingfederate
    ```
     > The first time, will ensure several dependencies (i.e. docker, docker-compose), so resolve these, if needed.

6. Use ping-devops tool to stop or cleanup after you finish.

    ```bash
    ping-devops docker stop pingfederate   # Stops the instance
    ping-devops docker rm   pingfederate   # Removes instance and all data
    ```
     > Be aware that any data created in these demos goes away when removed or the ping-devops instances are cleaned.  See [Saving your config/data changes](saveConfigs.md) to persist data to a local Docker volume.

## Next Steps
* [Ping Identity Getting Started Git repos](getStartedWithGitRepo.md)

