---
title: Docker Builds Repository Overview
---
# Ping docker-builds Repository Summary

!!! note "Using the repository"
    This page only describes the repository structure for context and understanding. For instructions on using the repository to build an image, visit [this page](../how-to/buildLocal.md).

In the [docker-builds](https://github.com/pingidentity/pingidentity-docker-builds) Github repository, we share our Dockerfiles and automation scripts used for building Ping product container images.  You can use these scripts and supporting pieces found in the repository to build an image of your own locally.  For example, you can use this process to build an image for an older version we no longer provide on Docker Hub.

The image build process at Ping uses the [Docker multi-stage build](https://docs.docker.com/build/building/multi-stage/) process.  In summary, we build out image layers that are common to most or all of our products, and from those we add layers to refine and create the image for each product.  In doing so, we ensure that all of our product container images have a similar structure.  For example, all Ping products written in Java use the same Java runtime version in our images, since each product container image has the same JVM base image.

As you explore the repository, you will find directories for building each product and supporting image, each with a Dockerfile and supporting scripts.  As these are layered, they build out a complete product image for use in Kubernetes or another container orchestration environment.  For the most part, each directory represents the source for an image, whether a final product image or an intermediate layer.  

## Filesystem layout

The repository includes the following directories. This list is not comprehensive; it is focused on those folders of relevance to users:

!!! note "Highlighting"
    The template used for this portal renders a highlight when you hover on a row in a table.  This action is expected, but the rows are not linked in any fashion.


### Non-image directories
| Repository Directory | Description |
| :--- | :--- |
| ci_scripts | Files and scripts used for building container images, both in an automated build pipeline and local use |
| ldap-sdk-tools | LDAP SDK tools available for use with Ping Directory |

### Image directories
| Repository Directory | Description |
| :--- | :--- |
| pingbase | Base OS, default environment variables, volumes, healthcheck and entrypoint command definitions.  This image provides a base to all Ping Identity container images |
| pingcommon | Files and scripts used with all Ping Identity container images |
| pingdatacommon | Files and scripts used with all Ping Identity Data container images \(i.e. PingDirectory, PingDataSync\) |
| pingjvm | Files and scripts for creating the JVM image that is the foundation for most Ping product container images |
| pingaccess | Product-specific files and scripts for PingAccess container image|
| pingauthorize | Product-specific files and scripts for PingAuthorize container image |
| pingauthorizepap | Product-specific files and scripts for PingAuthorize Policy Editor container image |
| pingcentral | Product-specific files and scripts for PingCentral container image |
| pingdataconsole | Product-specific files and scripts for Ping Data Console container image |
| pingdatasync | Product-specific files and scripts for PingDataSync container image |
| pingdelegator | Product-specific files and scripts for PingDelegator container image |
| pingdirectory | Product-specific files and scripts for PingDirectory container image |
| pingdirectoryproxy | Product-specific files and scripts for PingDirectory Proxy container image |
| pingfederate | Product-specific files and scripts for PingFederate container image |
| pingintelligence | Product-specific files and scripts for PingIntelligence container image |
| pingtoolkit | Files and scripts for a utility image, typically used for an init or task-related container |
