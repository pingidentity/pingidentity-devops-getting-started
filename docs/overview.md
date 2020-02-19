# Overview

The DevOps resources include Docker images of Ping Identity products, deployment examples and configuration management tools.

When you're ready, begin with our [Get started](getStarted.md) guide. Our documentation will help set you up and familiarize you with the use of the resources.

## DevOps Docker images

We make available preconfigured Docker images of our products in Docker containers. Each of our containers is a complete working product instance, immediately usable when deployed. Our Docker stacks are integrated collections of these containers, preconfigured to interoperate with the containers in the stack.

You'll find information about our available Docker images in the [Docker images](../../pingidentity-docker-builds) repository or on our [Docker Hub](https://hub.docker.com/u/pingidentity/) site.

The Docker images are automatically pulled from our repository the first time you deploy a product container or orchestrated set of containers. Alternatively, you can pull the images from our [Docker Hub](https://hub.docker.com/u/pingidentity/) site.

## Deployment examples

We supply examples for deploying our products as standalone containers, as a stack, as an orchestrated set using Docker Swarm, and as an orchestrated set using Kubernetes.

## Configuration management

For configuration management, we use:

  * Server profiles, for runtime configuration of containers.
  * YAML files for runtime configuration of stacks. YAML file configuration settings complement that used for server profiles.
  * Environment variables. These can be included in YAML files or called from external files.
  * Shell scripts (hooks) to automate certain operations for a product.
  * Release tags to give you a choice between stable builds or the current (potentially unstable) builds.

By default, our Docker images run as root within the container. For instructions on how to change this, see [Securing the containers](docs/secureContainers.md).

## Licensing

See the [Licensing page](../LICENSE.md) for information.
