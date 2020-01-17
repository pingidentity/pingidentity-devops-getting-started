# Overview

The DevOps resources include Docker images of Ping Identity products, deployment examples and configuration management tools. Refer to the documentation guides for how to use these resources.

When you're ready, begin with our [Get started](evaluate.md) guide. Our documentation will help set you up and familiarize you with the use of the resources.

## DevOps images

We make available preconfigured Docker images of our products. Each of our Docker containers is a complete working product instance, immediately usable when deployed. Our Docker stacks are integrated collections of these containers, preconfigured to interoperate with the containers in the stack.

You'll find information about our available solutions in [Docker images](../../pingidentity-docker-builds) or on our [Docker Hub](https://hub.docker.com/u/pingidentity/) site.

The DevOps image or images are automatically pulled from our repository the first time you deploy a solution container or orchestrated set of containers. Alternatively, you can pull the images from [Docker Hub](https://hub.docker.com/u/pingidentity/).

## Deployment examples

We supply examples for deploying our solutions as standalone containers, as a container stack using Docker Compose, as a replicated pair of containers using Docker Compose, as an orchestrated set of containers using Docker Swarm, and as an orchestrated set of containers using Kubernetes.
You'll find the [example directories here](../README.md).

## Configuration management

For configuration management, we use:

  * Server profiles, for runtime configuration of containers.
  * YAML files for runtime configuration of orchestrated containers. YAML file configuration settings complement that used for server profiles.
  * Environment variables. These can be included in YAML files or called from external files.
  * Shell scripts (hooks) to automate certain operations for a solution.
  * Release tags to give you a choice between stable releases or the current (potentially unstable) builds.

## Custom images

When you're familiar with the deployment and configuration processes, you can choose to customize the DevOps images for your own purposes. Our documentation will guide you through this process.

## Licensing

See the [Licensing page](../LICENSE.md) for information.
