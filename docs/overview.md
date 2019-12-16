# Overview

The DevOps resources include Ping Identity solution images for DevOps, deployment examples and configuration management tools. Refer to the documentation guides for how to use these resources.

When you're ready, begin with our [Getting started](evaluate.md) guide. Our documentation will help set you up and familiarize you with the use of the resources:

## DevOps images

We make available preconfigured images of Ping Identity solutions. Each solution is configured to be a working, immediately usable image for deployment to a Docker container. The solutions are also integrated, configured to interoperate with any of the other available solutions.

You'll find information about our available solutions in [Docker images](../../pingidentity-docker-builds) or on our [Docker Hub](https://hub.docker.com/u/pingidentity/) site.

The DevOps image or images are automatically pulled from our repository the first time you deploy a solution container or orchestrated set of containers. Alternatively, you can pull the images from [Docker Hub](https://hub.docker.com/u/pingidentity/).

## Deployment examples

We supply examples for deploying our solutions as standalone containers, as a container stack using Docker Compose, as a replicated pair of containers using Docker Compose, as an orchestrated set of containers using Docker Swarm, and as an orchestrated set of containers using Kubernetes.
You'll find the [example directories here](../README.md).

## Configuration management

For configuration management, we use:

  * Profiles, what we call server profiles, for runtime configuration of solution containers.
  * YAML files for runtime configuration of orchestrated solutions. YAML file configuration settings complement that used for server profiles.
  * Environment variables. These can be included in YAML files or called from external files.
  * Shell scripts (hooks) to automate certain operations for a solution.
  * Release tags to give you a choice between stable releases or the current (potentially unstable) builds.

## Custom images

When you're familiar with the deployment and configuration processes, you can choose to customize the DevOps images for your own purposes. Our documentation will guide you through this process.

## Licensing
