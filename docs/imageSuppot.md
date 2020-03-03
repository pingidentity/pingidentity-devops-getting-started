# Ping Identity Docker Image Support

## Overview

Unlike traditionally delivered software, Docker Images package product artifacts, operating system, Java Development Kit (JDK)
and miscellaneous tools/libraries (Git, SSH, SSL) to run the software.

Due to the number of dependency updates and to ensure all patches are captured, Ping Identity will build
all supported product images daily (edge), releasing a stable build each month (sprint and latest).

The build process will retrieve the latest versions of:

* Operating System (Alpine)
* JDK
* Product files
* Supporting tools/libraries

## Supported Image Versions

The DevOps program supports:

* Current and previous major version
* Latest patch release for each minor version

Examples:

* Version 10.0 will stop being updated when 10.0.1 is released
* Once 10.0.2 is released, 10.0.1 will no longer be updated
* Once 10.1 is available, 10.0.X (Last updated patch release) will continue to be updated
* Once 11.0 is released, all version 9 images will no longer be built
