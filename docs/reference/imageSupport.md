# Ping Identity Docker Image Support Policy

## Overview

Unlike software delivered as an archive, Docker Images include product artifacts, OS shim, an optimized JVM build
and miscellaneous tools/libraries (Git, SSH, SSL) to run the software and automation scripts.

Due to the number of dependency updates and to ensure all patches are kept up to date, Ping Identity actively maintains product images semi-weekly (edge), releasing a stable build each month (sprint and latest).

The build process retrieves the latest versions of:

* Operating System Shim (Alpine)
* Optimized Java VM
* Product files
* Supporting tools/libraries

## Actively Maintained Images

The DevOps program actively maintains docker images for:

* the two (2) most recent feature releases (major/minor) of each product
* the latest patch release for each minor version

Examples:

* If we currently maintain images for PingFederate 10.0 and 10.1, when PingFederate 10.2 is released, docker images with PingFederate 10.0 will no longer be actively maintained.
* If a patch is released for 10.1, it supersedes the previous patch. In other words, if we currently maintain an image for PingFederate 10.1.2, when PingFederate 10.1.3 is released it replaces 10.1.2.

!!! warning "Docker Hub Images"
    Image versions that have fallen out of Ping's image active maintenance window will be removed from DockerHub 3 months after it was last actively maintained.

**Current** matrix of actively maintained images:


| Product               | Actively Maintained Image |
| --- | --- |
| PingAccess            | <ul><li>6.2</li><li>6.1</li></ul> |
| PingCentral           | <ul><li>1.6</li><li>1.5</li></ul> |
| PingDataConsole       | <ul><li>8.2</li><li>8.1</li></ul> |
| PingDataGovernance    | <ul><li>8.2</li><li>8.1</li></ul> |
| PingDataGovernancePAP | <ul><li>8.2</li><li>8.1</li></ul> |
| PingDataSync          | <ul><li>8.2</li><li>8.1</li></ul> |
| PingDelegator         | <ul><li>4.4.0</li></ul> |
| PingDirectory         | <ul><li>8.2</li><li>8.1</li></ul> |
| PingDirectoryProxy    | <ul><li>8.2</li><li>8.1</li></ul> |
| PingFederate          | <ul><li>10.2</li><li>10.1</li></ul> |
| PingIntelligence      | <ul><li>4.4</li></ul> |

!!! info "Last Update  Dec 15, 2020"
