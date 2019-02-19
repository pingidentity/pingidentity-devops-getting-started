# Docker Standalone
The objective of this directory is to demonostrate how to use the docker images in the PingIdentity lineup, 
independent of any other framework. It should be a journey, completed step-by-step in the order of the 
sub-directories.

## PingIdentity Docker Images

* 01-pingdirectory    - Standalone PingDirectory container with a nice configuration supplied
* 02-pingfederate     - Standalone PingFederate container
* 03-pingaccess       - Standalone PingAccess container
* 10-pingdataconsole  - Standalone PingDataConsole Container running in a Tomcat instance

## PingIdentity Utilities

* 00-pingdownloader   - Utility container used for downloading Ping Identity product artifacts
* 99-logging          - Sample technique to aggregate log logs across containers
* FF-shared           - Shared environment variables used in above containers

## HowTo

There are a 3 shell scripts that can be used to run, cleanup and stop docker containers for the PingIdentity
Docker Images.

### docker-run.sh
Used to run the docker images as individual standalone containers.

```
Usage: ./docker-run.sh { container name } [ --debug ]
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - runs all containers

             --debug : Provide debugging details and drop into container shell
                       This option is not used in conjunction with all
Examples

  Run a standalone PingDirectory container

    ./docker-run.sh pingdirectory

  Run a standalone PingFederate container, with debug.  This will start the container
  and drop the user into the container shell, rather than installing/running the
  PingFederate instance

    ./docker-run.sh pingfederate --debug
```

### docker-stop.sh
Used to stop the docker indiviudal containers.

```
Usage: ./docker-stop.sh { container name }
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - runs all containers

Examples

  Stop a standalone PingDirectory container

    ./docker-stop.sh pingdirectory

  Stop all containers

    ./docker-stop.sh all
```

### docker-cleanup.sh
Used to cleanup the docker indiviudal containers.

```
Usage: ./docker-cleanup.sh { container name } [ --force ]
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - runs all containers

             --force : Force Cleanup & Removal of IN/OUT directories

Examples

  Cleanup a standalone PingDirectory container

    ./docker-cleanup.sh pingdirectory

  Cleanup all containers and force the cleanup, no questions are asked

    ./docker-cleanup.sh all --force
```
