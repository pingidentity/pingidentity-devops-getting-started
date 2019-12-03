# Proof of Concept Quick Start

This document aims to quickly stand up a demo/proof-of-concept environment using the available Ping Identity Docker Images.

The intent is to help get a running set of Ping Identity components on a single machine in a containerized enviornment. As such, all the containers will communicate with each other over a local docker network. 

The deployed products will be: 
  * PingDirectory
  * PingDataConsole (PingDirectory/DataGovernance admin UI)
  * PingFederate
  * PingAccess
  * PingDataGovernance

Configurations will be provided to the products via the `baseline` [profile](./server-profiles/README.md). This configuration will have the products integrated and running a small demo use-case.

> [Persisting data and configurations](#dont-lose-your-work) will be discussed after setting up the environment. 

## Pre-Requisites

In order to successfully run this quickstart, the following pre-requisites should be completed.
> Note: The quickstart guide and tools were built and tested only on Mac OSX.

**Required**

* Linux OS (any Linux variant should also work, however most testing has been on Mac OSX)
* Docker ([link to download](https://hub.docker.com/editions/community/docker-ce-desktop-mac))
* Docker Compose (https://docs.docker.com/compose/install/)
* Git ([link to download](https://git-scm.com/downloads))
* [Obtain a DevOps User and Key](https://pingidentity-devops.gitbook.io/devops/prod-license#obtaining-a-ping-identity-devops-user-and-key)

**Requirements for VM**

* External Ports: 443, 9000, 8080, 7443, 9031, 9999, 1636-1646, 1443-1453, 8443 should be exposed
  > There are other ports used for communication between apps, but it will happen on a local Docker network. 
* Recommended resources: 30GB storage, 2-4 cores, 10+ GB ram
  > On a VM, docker is allowed full access to machine resources by default. Mac OSX runs docker-engine, and so you will need to raise the default allocated resources. Open Docker App>Preferences>Advanced.
* Complete [Docker post-installation steps for Linux](https://docs.docker.com/install/linux/linux-postinstall/). 


**Optional**

* Install Apache Directory Studio \([link to download](https://directory.apache.org/studio/download/download-macosx.html)\)
* Postman \([link to download](https://www.getpostman.com/downloads/)\)

## Setup you environment for Ping Identity DevOps projects

Some environment pre-work is _highly recommended_ to provide conventions that will be helpful later in the document as well as other examples:

### Clone Github pingidentity-devops-getting-started

All the scripts and examples used in this quick-start are provided in the [pingidentity-devops-getting-started Github repo](https://github.com/pingidentity/pingidentity-devops-getting-started.git).

Make a local copy of the repo on your machine in this location:
`${HOME}/projects/devops`

```text
mkdir -p ${HOME}/projects/devops
cd ${HOME}/projects/devops

git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git

#Cloning into 'pingidentity-devops-getting-started'...
```

You should now see a directory called `pingidentity-devops-getting-started`.

An interactive `setup` script is used to help you make quick and easy use of the Ping Identity DevOps projects.

```text
cd pingidentity-devops-getting-started
./setup
#...
```

```
#refresh to get the new aliases
source ~/.bash_profile
```

Now you can use run `dhelp` or `khelp` to get help with your DevOps Docker and Kubernetes commands.

> `dhelp ` [not working?](./troubleshooting/BASIC_TROUBLESHOOTING.md#issue-bad-bash_profile-setup)

## Deploy the Ping Identity Docker Fullstack
To continue setting up the proof-of-concept, deploy the Ping Software Fullstack. 

```
cd 11-docker-compose/03-full-stack
docker-compose up -d
```

Follow logs as the containers spin up: `docker-compose logs -f`

`Ctrl+C` to exit the logs.

Watch and wait for containers to be healthy: 
- run `docker ps` over and over, or:
- `watch "docker container ls --format 'table {{.Names}}\t{{.Status}}'"`

Once a container is healthy, you can see and log-in to it's admin UI. 
> If on VM, use IP instead of localhost

PingDataConsole - For Directory
  Console URL: https://localhost:8443/console
  Server: pingdirectory
  User: Administrator
  Password: 2FederateM0re

PingFederate:
  Console URL: https://localhost:9999/pingfederate/app
  User: Administrator
  Password: 2FederateM0re

PingAccess
  Console URL: https://localhost:9000
  User: Administrator
  Password: 2FederateM0re

PingDataConsole - For DataGovernance
  Console URL: https://localhost:8443/console
  Server: pingdatagovernance
  User: Administrator
  Password: 2FederateM0re

To connect to directory with Apache Directory Studio:
LDAP Port: 1389
LDAP BaseDN: dc=example,dc=com
Root Username: cn=administrator
Root Password: 2FederateM0re

### Try the Built-In Demo

The stack that you've stood up has the products integrated together, and a demo use-case to show this. The instructions for use are found on the [fullstack README](../11-docker-compose/03-full-stack/README.md#using-the-containers)

## Don't Lose Your Work!

Now that you see everything is up and running, you may want to start building _in_ the products.

Before jumping in, realize that upon stopping and removing a container, all configurations beyond the demo data will be lost. 

There are two ways to prevent this:
- Externalize configurations
- Persist changes via mounted volumes

**Externalize Configurations** - In an ideal production scenario, we should strive to never mutate containers. Achieving this is done through externalizing server configutations into [profiles](./server-profiles/README.md). For a quick proof-of-concept and getting used to Docker, it is easier to start by treating containers like VMs... 

**Persisting changes via mounts**

We can essentially "treat containers like VMs" by mounting their storage to an external location. Once this is done, you can turn stop, remove, and start your containers without losing any changes. Additionally, you can ship the location to someone else and have them run it in their environment. 

To achieve this, we must first tear down our current stack:

```
docker-compose down
```

First, let's do the steps, then we'll explain it:

  1. Open `docker-compose.yaml` in a text editor. 
  2. Uncomment the line `volumes:` and the line ending in `/opt/out` for each product.
  3. Save the file and run `docker-compose up -d`
  4. Return to `docker-compose.yaml` in a text editor. 
  5. Comment out the entire `environment:` section for each product and save the file. 

What this does:

> The following information explains features that are standardized in all Ping Identity Docker Images. 

Ping Identity images are all set to use `/opt/out` as the runtime directory on the container. Uncommenting the volume lines (step 2) "binds" the container's live working directory to the location defined in front of the colon (e.g. `${HOME}/projects/devops/volumes/full-stack.pingdirectory`). 

Step 3 starts the containers and uses the `environment` information to pull an externalized configuration (profile) into the container from a Github URL. Since we are treating the container like a VM, we only need to pull this configuration on the very first container start, and thus step 5 leads to commenting out `environment:`. With the environment commented out, we can be sure the container will not pull in an external configuration and potentially overwrite our work. 

**Additional Notes** 
You can now run `docker-compose down` and `docker-compose up` to "shut down" an "start up" your environment. Keep in mind that your configurations are persisted to the specified location. If you need to delete your configurations, just delete the location.

## Cleanup

`docker-compose down` will stop and remove all the containers. 

`docker image rm  -f $(docker image ls "pingidentity/*")` will remove all pingidentity images. (must not have any running containers)

If you have followed the persistence steps, you can also `rm -rf` the `${HOME}/projects/devops/volumes` directory to delete everything. 