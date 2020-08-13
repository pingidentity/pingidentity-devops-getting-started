# Using DevOps hooks

Our DevOps hooks are build-specific scripts that are called or can be called by the `entrypoint.sh` script that is used to start up our product containers. 

> Use of our DevOps hooks is intended only for DevOps professionals.

The available hooks are built with the DevOps images, and can be found in the `hooks` subdirectory of each product directory in the [Docker builds](https://github.com/pingidentity/pingidentity-docker-builds) repository. 

In the `entrypoint.sh` startup script, there is an example (stub) provided for the available hooks for all products.

> It's **critical** that the supplied hook names be used if a you modify `entrypoint.sh` (for example, to make subtle changes to a server profile).

## Using .pre and .post hooks

When DevOps hooks are called during the `entrypoint.sh` script process, any corresponding `.pre` and `.post` hooks will also be called.

The `.pre` and `.post` extensions allow you to define custom scripts to be executed before or after any hook that is run in the container. You can include any custom `.pre` and `.post` hooks in the `hooks` directory of your server profile.

Hooks with a `.pre` extension are run before the corresponding hook, and hooks with a `.post` extension are run after the corresponding hook. For example, a script named `80-post-start.sh.pre` will be run just before the `80-post-start.sh` hook starts, and a script named `80-post-start.sh.post` will be run just after that hook completes.

