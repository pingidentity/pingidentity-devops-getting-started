# Docker Standalone
The objective of this directory is to demonstrate how to use the Docker images in the Ping Identity lineup, independent of any other framework. It should be completed step-by-step in the order of the sub-directories.

## Ping Identity Docker images

* 01-pingdirectory    - Standalone PingDirectory container with a nice configuration supplied
* 02-pingfederate     - Standalone PingFederate container
* 03-pingaccess       - Standalone PingAccess container
* 10-pingdataconsole  - Standalone PingDataConsole Container running in a Tomcat instance

## Ping Identity utilities

* 00-pingdownloader   - Utility container used for downloading Ping Identity product artifacts
* 99-logging          - Sample technique to aggregate logs across containers
* FF-shared           - Shared environment variables used in above containers

## How to

There are a 3 shell scripts that can be used to run, cleanup and stop docker containers for the Ping Identity
Docker Images.

### docker-run.sh
Used to run the Docker images as individual standalone containers.

```
Usage: ./docker-run.sh { container name } [ --debug ]
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - runs all containers

             --debug : Provide debugging details and drop into container shell
                       Note: This option should only be used when launching a single container.
Examples

  Run a standalone PingDirectory container

    ./docker-run.sh pingdirectory

  Run a standalone PingFederate container with debug.  This will start the container
  and drop the user into the container shell, rather than installing or running the
  PingFederate instance

    ./docker-run.sh pingfederate --debug
```

### docker-stop.sh
Used to stop the Docker individual containers.

```
Usage: ./docker-stop.sh { container name }
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - stops all containers

Examples

  Stop a standalone PingDirectory container

    ./docker-stop.sh pingdirectory

  Stop all containers

    ./docker-stop.sh all
```

### docker-cleanup.sh
Used to cleanup the Docker individual containers.

```
Usage: ./docker-cleanup.sh { container name } [ --force ]
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - cleanup all containers

             --force : Force Cleanup & Removal of IN/OUT directories

Examples

  Cleanup a standalone PingDirectory container

    ./docker-cleanup.sh pingdirectory

  Cleanup all containers and force the cleanup, no questions are asked

    ./docker-cleanup.sh all --force
```