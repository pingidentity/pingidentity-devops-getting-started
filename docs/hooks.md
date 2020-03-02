# Using DevOps hooks

Our DevOps hooks are build-specific scripts that are called or can be called by the `entrypoint.sh` script that is used start up our product containers. 

    > Use of our DevOps hooks is intended only for DevOps professionals.

The available hooks are built with the DevOps images, and can be found in the `hooks` subdirectory of each product directory in the [Docker builds](https://github.com/pingidentity/pingidentity-docker-builds) repository. 

In the `entrypoint.sh` startup script, there is an example (stub) provided for the available hooks for all products.

    > It is **critical** that the supplied hook names be used if a you modify `entrypoint.sh` (for example, to make subtle changes to a server profile).

