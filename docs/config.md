# Customizing the containers

You can customize our product containers by:

* [Customizing server profiles](profiles.md)

  The server profiles supply configuration, data, and environment information to the product containers at startup. You can use our server profiles, or use them as a baseline for creating your own. You'll find these in [Baseline server profiles](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline).

* [Customizing YAML files](yamlFiles.md)

  In the stack-related directories for the deployment examples, you'll find the YAML files used to configure the Docker stack deployment. The YAML files can contain startup configuration settings or references to startup configuration settings (such as, environment variables) for the stack. You can try different configuration settings using these YAML files, or use them as a baseline for creating your own.

* [Using DevOps hooks](hooks.md)

  Hooks are DevOps shell scripts, generally specific to a product, that you can use to automate certain operations. You'll find the hooks for our builds in the [Docker builds product directories](docker-builds/README.md).

* [Changing release tags](releaseTags.md)

  We use sets of tags for each released build image. These tags identify whether the image is a specific stable release, the latest stable release, or current (potentially unstable) builds. You'll find the release tag information in [Docker images](releaseTags.md). You can try different tags in either the standalone startup scripts for the deployment examples, or the YAML files for the orchestrated deployment examples.

* [Securing the containers](secureContainers.md)

  By default, our Docker images run as root within the container. Refer to this topic for instructions in changing this.

* [Adding a message of the day (MOTD)](addMOTD.md)
  
  You can use a `motd.json` file to add message of the day information that will be used by the DevOps images.