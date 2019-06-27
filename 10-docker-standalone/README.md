# Docker Standalone

A great way to learn about the most simple steps of running a Ping Identity Docker image is to run them as individual containers. A good plan is to run through each of these images in a step-by-step order.

## Ping Identity Docker images

| Image | Description |
| :--- | :--- |
| 01-pingdirectory | Standalone PingDirectory container with a basic config |
| 02-pingfederate | Standalone PingFederate container |
| 03-pingaccess | Standalone PingAccess container |
| 10-pingdataconsole | Standalone PingDataConsole Container running in a Tomcat instance |

## Ping Identity utilities

| Image | Description |
| :--- | :--- |
| 00-pingdownloader | Utility container used for downloading Ping Identity product artifacts |
| 99-logging | Sample technique to aggregate logs across containers |
| FF-shared | Shared environment variables used in above containers |

## Easy Scripts to Run Images

There are 3 shell scripts that can be used to run, stop and cleanup docker containers for the Ping Identity Docker Images.

### docker-run.sh

Used to run the Docker images as individual standalone containers.

```text
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

```text
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

```text
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

