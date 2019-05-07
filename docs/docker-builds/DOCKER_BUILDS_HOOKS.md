# Docker Builds - Hooks

**Audience** - 
Operators of DevOps Cloud environments.  Not intended for 
Developers and admins of the Ping Identity products.  Those documents are 
available via the server-profile `need link here to server-profile doc`.

**Description** - 
This document describes the many number of scripts that are called in during the lifecyle of a Ping Identity docker image from the initial `entrypoint.sh` script.

Included with the base docker images, there is an example/stub provided for all possible hooks.  It is **very important** that these names be used if a developer wishes to make subtle changes to their server-profile `need link here to server-profile doc`.

The full ordered list of scripts that are called depending on what type of image (i.e. pingdirectory or pingdatasync) are:

![images/DOCKER_BUILDS_HOOKS_1.png]

[images/DOCKER_BUILDS_HOOKS_1.png]: ../images/DOCKER_BUILDS_HOOKS_1.png

## List of Hooks

## 01-start-server

**Description:**
This stub is called on the first start of the container AND every other start
This may be useful to "call home" or send a notification of startup to a command and control center

