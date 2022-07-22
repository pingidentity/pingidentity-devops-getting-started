---
title: Ping Identity Docker Image Support Policy
---
# Ping Identity Docker image support policy

## Overview

Unlike software delivered as an archive, Docker images include:

* Product artifacts
* OS shim
* An optimized Java virtual machine (JVM) build
* Miscellaneous tools/libraries (Git, SSH, SSL) to run the software and automation scripts

Because of the number of dependency updates and to ensure all patches are kept up to date, Ping Identity actively maintains product images semi-weekly (edge), releasing a stable build each month (sprint and latest).

The build process retrieves the latest versions of:

* Operating System Shim (Alpine)
* Optimized JVM
* Product files
* Supporting tools/libraries

## Actively Maintained Product Versions

The DevOps program actively maintains Docker images for:

* The two most recent feature releases (major and minor) of each product
* The latest patch release for each minor version

Examples:

* If we currently maintain images for PingFederate 10.0 and 10.1, when PingFederate 10.2 is released, Docker images with PingFederate 10.0 will no longer be actively maintained.
* If a patch is released for 10.1, it supersedes the previous patch. In other words, if we currently maintain an image for PingFederate 10.1.2, when PingFederate 10.1.3 is released, it replaces 10.1.2.

!!! Info "Active Build Product Versions"
    To view products and versions actively being built, see the most recent **Release Notes**.

## Docker Hub image removal

Security vulnerabilities that arise over time and the continued evolution of our products creates a situation in which older product images should be replaced with newer ones in your environment.  Images that have fallen out of Ping's active maintenance window **are removed from Docker Hub 1 year after they were last built**. If you need to keep images longer than this period, you will need to store them in a private repository.  The [Docker documentation](https://docs.docker.com/engine/reference/commandline/tag/) has instructions on this process.

## Supported OS shim

The DevOps program uses [Alpine](https://hub.docker.com/_/alpine) as its base OS shim. For the rationale, see [Evaluation of Docker Base Image Security](./dockerImageSecurity.md).

In rare scenarios where the consumer absolutely cannot run an Alpine based image, you can customize the base image. For more information, see [Build a Docker Product Image Locally](../reference/buildLocal.md).

!!! warning "Custom Built Images"
    Using other Linux distributions should not cause an issue, but it cannot be guaranteed that the products will function as expected because these are not verified for compatibility. Ping Identity Support on custom images _might_ be challenging and experience longer delays.
