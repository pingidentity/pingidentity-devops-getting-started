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

## Supported Image Versions

The DevOps program supports:

* Support most recent 2 feature releases (major/minor)
* Latest patch release for each minor version

Examples:

* Version 10.0 will stop being updated when 10.0.1 is released
* Once 10.0.2 is released, 10.0.1 will no longer be updated
* Once 10.1 is available, 10.0.X (Last updated patch release) will continue to be updated
* Once 10.2 is released, the latest version 9.X images will no longer be built

!!! warning "DockerHub Images"
    Image versions that have fallen out of Ping's support window will be removed from DockerHub 3 months after support has ended.

Current matrix of actively maintained images:

| Product               | Actively Maintained Image |
| --- | --- |
| PingAccess            | 6.1, 6.0                  |
| PingCentral           | 1.5, 1.4                  |
| PingDataConsole       | 8.1, 8.0                  |
| PingDataGovernance    | 8.1, 8.0                  |
| PingDataGovernancePAP | 8.1, 8.0                  |
| PingDataSync          | 8.1, 8.0                  |
| PingDelegator         | 4.4.0                     |
| PingDirectory         | 8.1, 8.0                  |
| PingDirectoryProxy    | 8.1, 8.0                  |
| PingFederate          | 10.0, 10.1                |
| PingIntelligence      | 4.3                       |

!!! info "Last Update  Dec 14, 2020"
