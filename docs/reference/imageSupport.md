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
| PingAccess            | <ul><li>6.1</li><li>6.0</li></ul> |
| PingCentral           | <ul><li>1.5</li><li>1.4</li></ul> |
| PingDataConsole       | <ul><li>8.1</li><li>8.0</li></ul> |
| PingDataGovernance    | <ul><li>8.1</li><li>8.0</li></ul> |
| PingDataGovernancePAP | <ul><li>8.1</li><li>8.0</li></ul> |
| PingDataSync          | <ul><li>8.1</li><li>8.0</li></ul> |
| PingDelegator         | <ul><li>4.4.0</li></ul> |
| PingDirectory         | <ul><li>8.1</li><li>8.0</li></ul> |
| PingDirectoryProxy    | <ul><li>8.1</li><li>8.0</li></ul> |
| PingFederate          | <ul><li>10.0</li><li>10.1</li></ul> |
| PingIntelligence      | <ul><li>4.3</li></ul> |

!!! info "Last Update  Dec 15, 2020"
