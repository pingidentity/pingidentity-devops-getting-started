---
title: Using DevOps Hooks
---
# Using DevOps hooks

Our DevOps hooks are build-specific scripts that are called, or can be called, by the `entrypoint.sh` script used to start our product containers.

!!! error "Advanced usage"
    Use of the hook scripts is intended only for DevOps professionals familiar with the products.

The available hooks are built into the product images and can be found in the `hooks` subdirectory of each product directory in the [Docker Builds](https://github.com/pingidentity/pingidentity-docker-builds) repository.

In the `entrypoint.sh` startup script, there is an example (stub) provided for the available hooks for all products.

!!! warning
    It is **critical** that the supplied hook names be used if you modify `entrypoint.sh`. For example, they can be used to make subtle changes to a server profile.

## Using .pre and .post hooks

When the hook scripts are called during the `entrypoint.sh` initialization, any corresponding `.pre` and `.post` hooks are also called.

The `.pre` and `.post` extensions allow you to define custom scripts to be executed before or after any hook that is run in the container. You can include any custom `.pre` and `.post` hooks in the `hooks` directory of your server profile.

Hooks with a `.pre` extension are run before the corresponding hook, and hooks with a `.post` extension are run after the corresponding hook.

For example, a script named `80-post-start.sh.pre` will execute immediately before the `80-post-start.sh` hook and a script named `80-post-start.sh.post` will be run immediately after that hook completes.
