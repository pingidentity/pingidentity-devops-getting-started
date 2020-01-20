# Configure deployments

You can configure deployments using:

  * [Server profiles](profiles.md)

  The server profiles supply configuration, data, and environment information to the product containers at startup. You can use our server profiles, or use them as a baseline for creating your own. You'll find these in [Server Profiles](server-profiles/README.md).

  * [YAML files for orchestrated solutions](yamlFiles.md)

  In the orchestration-related directories for the deployment examples, you'll find the YAML files used to configure the Docker stack deployment. The YAML files can contain startup configuration settings or references to startup configuration settings (such as, environment variables) for the stack. You can try different configuration settings using these YAML files, or use them as a baseline for creating your own.

  * [Shell scripts (hooks)](hooks.md)

  Hooks are DevOps shell scripts, generally specific to a product, that you can use to automate certain operations. You'll find the hooks for a product in the [Docker builds product directories](../../pingidentity-docker-builds).

  * [Release tags](releaseTags.md)

  We use sets of tags for each released DevOps image. These tags identify whether the image is a specific stable release, the latest stable release, or current (potentially unstable) builds. You'll find the release tag information in [Docker images](docker-images/README.md). You can try different tags in either the standalone startup scripts for the deployment examples, or the YAML files for the orchestrated deployment examples.

> If you remove any of the existing configurations for a Ping Identity product instance in a stack, it may no longer interoperate with other products in the Docker stack.
