# Docker Builds - Hooks

**Audience** - Operators of DevOps Cloud environments. Not intended for Developers and admins of the Ping Identity products. Those documents are available via the [server-profile](https://pingidentity-devops.gitbook.io/devops/server-profiles)

**Description** - This document describes the many number of scripts that are called in during the lifecyle of a Ping Identity docker image from the initial `entrypoint.sh` script.

Included with the base docker images, there is an example/stub provided for all possible hooks. It is **very important** that these names be used if a developer wishes to make subtle changes to their [server-profile](https://pingidentity-devops.gitbook.io/devops/server-profiles)

The full ordered list of scripts that are called depending on what type of image \(i.e. pingdirectory or pingdatasync\) are:

![](../images/docker_builds_hooks_1.png)

## Hooks Details
Details on hooks can be found within the code of each hook in the [docker-builds repo](https://github.com/pingidentity/pingidentity-docker-builds) as well in `pingidentity-devops-getting-started/docs/docker-images/<image_name>/hooks` for each of the products images. 

