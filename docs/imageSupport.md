# Ping Identity Docker Image Support

## Overview

Unlike traditionally delivered software, Docker Images include product artifacts, operating system, Java Development Kit (JDK)
and miscellaneous tools/libraries (Git, SSH, SSL) to run the software.

Due to the number of dependency updates and to ensure all patches are captured, Ping Identity builds supported product images semi-weekly (edge), releasing a stable build each month (sprint and latest).

The build process retrieves the latest versions of:

* Operating System (Alpine)
* JDK
* Product files
* Supporting tools/libraries

## Actively Maintained Images

The DevOps program actively maintains docker images for :

* the two (2) most recent feature releases (major/minor) of each product
* the latest patch release for each minor version

Examples:

* If we currently maintain images for PingFederate 10.0 and 10.1, when PingFederate 10.2 is released, docker images with PingFederate 10.0 will no longer be actively maintained.
* If a patch is released for 10.1, it supercedes the previous patch. In other words, if we currently maintain an image for PingFederate 10.1.2, when PingFederate 10.1.3 is released it replaces 10.1.2.

>Note: Image versions that have fallen out of Ping's image active maintenance window will be removed from DockerHub 3 months after it was last actively maintained.

**Current** matrix of actively maintained images:

| Product               | Actively Maintained Image |
|-----------------------|---------------------------|
| PingAccess            | 6.1, 6.0                  |
| PingCentral           | 1.5, 1.4                  |
| PingDataConsole       | 8.1, 8.0                  |
| PingDataGovernance    | 8.1, 8.0                  |
| PingDataGovernancePAP | 8.1, 8.0                  |
| PingDataSync          | 8.1, 8.0                  |
| PingDelegator         | 4.4.0                     |
| PingDirectory         | 8.1, 8.0                  |
| PingDirectoryProxy    | 8.1, 8.0                  |
| PingIntelligence      | 4.3                       |
| PingFederate          | 10.0, 10.1                |
