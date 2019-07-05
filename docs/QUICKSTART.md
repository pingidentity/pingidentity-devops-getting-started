# Quick Start

This document aims to help with a quick-start demo of the available Ping Identity Docker Images and basic 'getting started' server profiles.

The intent is to help get a running set of Ping Identity components on your local machine in a docker enviornment.

Note: The quickstart guide and tools were built and tested on Mac OSX.

## Pre-Requisites

In order to successfully run this quickstart, the following pre-requisites should be completed.

**Required**

* Mac OSX Host \(any Linux varient should also work, however little testing\)
* Install Docker \([link to download](https://hub.docker.com/editions/community/docker-ce-desktop-mac)\)
* Install GitHub \([link to download](https://git-scm.com/downloads)\)

**Optional**

* Install Apache Directory Studio \([link to download](https://directory.apache.org/studio/download/download-macosx.html)\)
* Postman \([link to download](https://www.getpostman.com/downloads/)\)

## Clone Github pingidentity-devops-getting-started

All the scripts and examples used in this quick-start are provided in the [pingidentity-devops-getting-started Github repo](https://github.com/pingidentity/pingidentity-devops-getting-started.git).

Make a local copy of the repo on your machine

```text
$ git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git

Cloning into 'pingidentity-devops-getting-started'...
```

You should now see a directory called `pingidentity-devops-getting-started`.

## Setup you environment for Ping Identity DevOps projects

A `setup` script is available to help you get your envionment to make quick and easy use of the Ping Identity DevOps projects.

To do this simply run `setup`

```text
cd pingidentity-devops-getting-started
./setup
```

Now, you can use the `dhelp` alias to get help with your DevOps Docker commands.

## Run a Docker Standalone Image - PingFederate

Now, we will run a standalone image in a docker container. In other words, we will run one of the Ping Identity docker images locally in a docker container on your local machine.

In a terminal window run, see the example below to navigate to the proper directory and startup the PingFederate image.

```text
$ cd pingidentity-devops-getting-started
$ cd 10-docker-standalone
$ ./docker-run.sh pingfederate

Using default tag: latest
latest: Pulling from pingidentity/pingfederate
8e402f1a9c57: Pull complete
4866c822999c: Pull complete
205f26e90552: Pull complete
b964f0e13c41: Pull complete
e95e0be61e06: Pull complete
a968bb575de2: Pull complete
Digest: sha256:81b73d9621908bb204d0fddb257f5126d115b8f205423508a8d8ac4d4fcf53f2
Status: Downloaded newer image for pingidentity/pingfederate:latest
13453a0512950d8ddd7ff74523feda6801b13fe81f58186fb2779b2e8cfcd290

# For live logs, execute:

docker container logs -f pingfederate

# For a terminal into the container, execute:

docker container exec -it pingfederate /bin/sh



# After server starts, go to:

     Admin Console:  https://localhost:9999/pingfederate/app
```

The `docker-run.sh` script is a helper script to run a standalone docker image locally. It also creates a `/tmp/Docker/*` set of directories for the different products where the runtime of the container is persisted. This will allow for the image to be stopped and re-started keeping the last known state.

In the example above, the image is first pulled down from Docker Hub and cached in your local docker registry. The container is then started, followed by some sample commands to view the application logs.

To see the `health` status of your containers run:

```text
> docker container ls -a
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS                   PORTS                                            NAMES
13453a051295        pingidentity/pingfederate   "entrypoint.sh start…"   4 minutes ago       Up 4 minutes (healthy)   0.0.0.0:9031->9031/tcp, 0.0.0.0:9999->9999/tcp   pingfederate
```

Once you see a `(healthy)` PingFederate continer you can navigate in your web browser to:

* [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)
  * Username: Administrator
  * Password: 2FederateM0re

## Run a Docker Standalone Image - PingDirectory

Now, let's run a second docker container for PingDirectory. Simply follow the example below.

```text
$ ./docker-run.sh pingdirectory

Using default tag: latest
latest: Pulling from pingidentity/pingdirectory
8e402f1a9c57: Already exists
4866c822999c: Already exists
205f26e90552: Already exists
b964f0e13c41: Already exists
157333328c59: Pull complete
d40de9676665: Pull complete
Digest: sha256:faa997a15d06d7989d957d181cb7b272fed6ee785b2921594187de0c9d1b0ca0
Status: Downloaded newer image for pingidentity/pingdirectory:latest
24b2a6e4ddcc885266efcd9dc7e0aad3346a999ed7277de0e7ab3934f0bbde39

# For live logs, execute:

docker container logs -f pingdirectory

# For a terminal into the container, execute:

docker container exec -it pingdirectory /bin/sh



# After server starts, run:

  docker exec pingdirectory /opt/server/bin/ldapsearch -p 389 -b "" -s base  objectclass=*

# or go to Directory REST API

  https://localhost:1443/directory/v1/ou=people,dc=example,dc=com/subtree?searchScope=wholesubtree
```

Once you have started the PingDirectory container, the same can be done for the PingDataconsole and PingAccess.

For more information on these docker images, you can review the [Ping Identity Docker Images](../docker-builds/) documentation.

## Removing and Cleaning up Standalone Images

Once you are finished with your docker containers, you can stop/start the continers, and ultimately remove them.

To stop the container, use the example below.

```text
> ./docker-stop.sh pingdirectory

Removing container pingdirectory
pingdirectory
```

To start the container backup, use the example below. Notice that we are using the `docker-run.sh` command again, but running it the second time, it will notice that you have a `/tmp/Docker/pingdirectory` runtime avaiable, and use that.

```text
$ ./docker-run.sh pingdirectory

Using default tag: latest
latest: Pulling from pingidentity/pingdirectory
Digest: sha256:faa997a15d06d7989d957d181cb7b272fed6ee785b2921594187de0c9d1b0ca0
Status: Image is up to date for pingidentity/pingdirectory:latest
eb7af521606c698ed086839db346d2587147d1ee8a25c93a2ef96463dc548d04
...
```

And to finally cleanup the running containers and remove them entirely, the script `docker-cleanup.sh` can be run with the product name. And passing the argment `all --force` will cleanup all running standalone containers and remove their persisted state. It's good to run this at the end of this quickstart to clean everything up.

```text
$ ./docker-cleanup.sh all --force

Running ./docker-cleanup.sh pingdirectory --force...
pingdirectory
Running ./docker-cleanup.sh pingfederate --force...
pingfederate
Running ./docker-cleanup.sh pingaccess --force...
Running ./docker-cleanup.sh pingdataconsole --force...
```