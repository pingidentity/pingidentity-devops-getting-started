# Build Your Own Docker Images

This document explains the Ping Identity Docker images and how they are built.

There are several image builds provided, including `Dockerfile`, `README.md` and scripts \(i.e. `entrypoint.sh`\) for each docker build. Some images are used as foundations to build other images.

| Docker Image | Description |
| :--- | :--- |
| pingbase | Base OS, default enviroment variables, volumes, healthcheck and entrypoint command defintions.  This image provides a base to all Ping Identity docker images |
| pingcommon | Files and scripts used with all Ping Identity docker images |
| pingdatacommon | Files and scripts used with all Ping Identity Data docker images \(i.e. PingDirectory, PingDataSync\) |
| pingfederate | Product details for PingFederate |
| pingaccess | Product details for PingAccess |
| pingdirectory | Product details for PingDirectory |
| pingdatasync | Product details for PingDataSync |
| pingdownloader | Product bits download service |
| ldap-sdk-tools | LDAP SDK tools availble of use with Ping Directory |

## Hook Scripts Used by Docker Builds

There are several hook scripts used by the docker builds. Full details on these hooks are included in the [Docker Builds Hooks Document](docker_builds_hooks.md)

