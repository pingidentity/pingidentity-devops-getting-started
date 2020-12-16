# Overview

The DevOps resources include Docker Images of Ping Identity products, deployment examples and configuration management tools.

When you're ready, begin with our [Get Started](get-started/getStarted.md) guide. Our documentation will help set you up and familiarize you with the use of the resources.

## DevOps Docker Images

<div class="iconbox" onclick="window.open('https://hub.docker.com/u/pingidentity','');">
    <img class="assets" src="../images/logos/docker.png" />
    <span class="caption">
        <a class="assetlinks" href="https://hub.docker.com/u/pingidentity" target=”_blank”>Docker Images</a>
    </span>
</div>
<div class="iconbox" onclick="window.open('https://github.com/pingidentity/pingidentity-devops-docker-builds','');">
    <img class="assets" src="../images/logos/github.png"/>
    <span class="caption">
        <a class="assetlinks" href="https://github.com/pingidentity/pingidentity-devops-docker-builds" target=”_blank”>Docker Builds</a>
    </span>
</div>

We make available preconfigured Docker Images of our products in Docker containers. Each of our containers is a complete working product instance, immediately usable when deployed. Our Docker stacks are integrated collections of these containers, preconfigured to interoperate with the containers in the stack.

You'll find information about our available Docker Images in the [pingidentity-docker-builds](https://github.com/pingidentity/pingidentity-docker-builds) repository or on our [Docker Hub](https://hub.docker.com/u/pingidentity/) site.

The Docker images are automatically pulled from our repository the first time you deploy a product container or orchestrated set of containers. Alternatively, you can pull the images from our [Docker Hub](https://hub.docker.com/u/pingidentity/) site.

## Deployment Examples

<div class="iconbox" onclick="window.open('https://github.com/pingidentity/pingidentity-devops-getting-started','');">
    <img class="assets" src="../images/logos/github.png"/>
    <span class="caption">
        <a class="assetlinks" href="https://github.com/pingidentity/pingidentity-devops-getting-started" target=”_blank”>DevOps Getting Started</a>
    </span>
</div>

We supply examples for deploying our products as standalone containers, as a Docker Compose stack, or as an orchestrated set using Kubernetes.

Use Docker Compose for development, demonstrations, and lightweight orchestration. Use Kubernetes for enterprise-level orchestration.

## Configuration Management

For configuration management, we use:

- Server profiles, for runtime configuration of containers.
- YAML files for runtime configuration of stacks. YAML file configuration settings complement that used for server profiles.
- Environment variables. These can be included in YAML files or called from external files.
- Shell scripts (hooks) to automate certain operations for a product.
- Release tags to give you a choice between stable builds or the current (potentially unstable) builds.

By default, our Docker images run as root within the container. For instructions on how to change this, see [Securing the Containers](how-to/secureContainers.md).

## Licensing

See [Licensing](license.md) for information.
