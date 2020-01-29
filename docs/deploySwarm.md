# Orchestrate deployments using Docker Swarm

These examples automate the manual steps needed for Docker standalone directories. They include:

* Using volumes bind mounted to the `/opt/in` directory for pulling server profile configurations locally, rather than from Github repositories, as well as 
* Using volumes bind mounted to the `/opt/out` directory for persisting state and data for running containers.

See the topic *Modify a server profile using local directories* in [Customizing server profiles](profiles.md) for more information about bind mounted volumes. See [Customizing YAML files](yamlFiles.md) for more information about our YAML file format.

## Prerequisites

* You've started Docker Swarm at some point before deploying the stack by running: `docker swarm init`. You only need to run `docker swarm init` once.
* You've already been through [Getting Started](evaluate.md) to set up your DevOps environment and run a test deployment of the products.

## What you'll do

* Deploy the PingDirectory stack in the swarm using the `basic1.yaml` file.
* Deploy the PingDirectory stack in the swarm using the `basic2.yaml` file.
* Deploy the full stack in the swarm using the `fullstack.yaml` file.

## The deployment files

The Docker Swarm deployment files are located in the [Docker Swarm](../12-docker-swarm) directory. The YAML files are:

| Example | Description |
| :--- | :--- |
| basic1.yaml | Deploy PingDirectory in a stack with mounted out volume |
| basic2.yaml | Deploy PingDirectory in a stack with mounted in/out volumes |
| basic3.yaml | Deploy PingDirectory in a stack with externally mounted volumes |
| fullstack.yaml | Deploy PingFederate, PingDirectory, Ping Data Console and PingAccess in a networked stack |
| simple-sync.yaml | Deploy PingDirectory, PingDataSync and Ping Data Console in a networked stack |

You can use the YAML files to deploy a stack with the command: `docker stack deploy -c <stack.yaml> <stack-name>`.

### Deploy using the `basic1.yaml` file

This YAML file deploys a PingDirectory configuration using a volume bind mounted to the `/opt/out` directory for persisting container state and data. The `volumes:` definition mounts the container's `/opt/out` directory to `/tmp/Swarm/basic1/pingdirectory`. The `/tmp/Swarm/basic1/pingdirectory` directory must be empty before using the `basic1.yaml` file to start the swarm.

1. Use this command sequence to ensure the directories are properly set up, and to start up the swarm:
   ```bash
   rm -rf /tmp/Swarm/basic1
   mkdir -p /tmp/Swarm/basic1/pingdirectory
   docker stack deploy -c basic1.yaml basic1
   ```

   The resulting output will be similar to this: 
   ```bash
   Creating network basic1_pingnet
   Creating service basic1_pingdirectory
   ```

   You can display the logs using:

   `docker container logs -f <container-id>`

   Use the comand `docker container ls` to see the \<container-id>.

2. To stop the swarm, you need to remove the swarm. Removing the container only stops that running container, and when the Docker Swarm identifies that the container isn't running, it creates new one. To remove the swarm, remove the stack. For example:
   ```bash
   docker stack rm basic1
   ```

   The resulting output will be similar to this: 
   ```bash
   Removing service basic1_pingdirectory
   Removing network basic1_pingnet
   ```

   Stopping the swarm leaves intact the persisted state and data in the container's volume bind mounted to the `/opt/out` directory (`/tmp/Swarm/basic1/pingdirectory`). When you restart the swarm, it will start up PingDirectory using the configuration data in `/tmp/Swarm/basic1/pingdirectory`. 

   To remove the persisted state and data, simply remove the directory:

   `rm -rf /tmp/Swarm/basic1`

### Deploy using the `basic2.yaml` file

This YAML file deploys PingDirectory configuration using a volume bind mounted to the `/opt/out` directory for persisting container state and data. The `volumes:` definition mounts the container's `/opt/out` directory to `/tmp/Swarm/basic1/pingdirectory`, and the container's `/opt/in` directory to `/tmp/Swarm/pingidentity-server-profiles/getting-started/pingdirectory`. Both the `/tmp/Swarm/basic1/pingdirectory` and the /tmp/Swarm/pingidentity-server-profiles/getting-started/pingdirectory directory must be empty before using the `basic2.yaml` file to start the swarm.

For this example, we'll clone our Github server profile repository to the local directory `/tmp/Swarm/pingidentity-server-profiles`, and use that directory as the mount point for the container's `/opt/in` directory.

1. Use this command sequence to ensure the directories are properly set up, and to start up the swarm:
   ```bash
   rm -rf /tmp/Swarm/basic2
   mkdir -p /tmp/Swarm/basic2/pingdirectory
   rm -rf /tmp/Swarm/pingidentity-server-profiles
   git clone https://github.com/pingidentity/pingidentity-server-profiles.git /tmp/Swarm/pingidentity-server-profiles
   docker stack deploy -c basic2.yaml basic2
   ```

   The resulting output will be similar to this: 
   ```bash
   Creating network basic2_pingnet
   Creating service basic2_pingdirectory
   ```

2. To stop the swarm and clean up the configuration for this example, use the following sequence of commands:
   ```bash
   docker stack rm basic2
   rm -rf /tmp/Swarm/basic2
   rm -rf /tmp/Swarm/pingidentity-server-profiles
   ```

<!-- ### Deploy using the `basic3.yaml` file

This example is the same as for `basic2.yaml`, with the exception that in this case the YAML file references a `docker volume` that you create, and bind mounts it to the `/opt/in` volume. You'll also use the Docker volume you created to share the our Github repository that you'll clone.

You'll create a `docker volume` named `pingdirectory-config`. This will create a Docker external volume that can be used by any container in a stack. In this case, it will be used by the `/opt/in` (internal, container-specific) volume definition.
clone our Github server profile repository to the `pingdirectory-config` local directory, then you'll mount `/tmp/Swarm/pingidentity-server-profiles` to the `pingdirectory-config` Docker volume you created. 

1. Use this command sequence to ensure the directories are properly set up, and to start up the swarm:
   ```bash
   rm -rf /tmp/Swarm/basic3
   mkdir -p /tmp/Swarm/basic3/pingdirectory
   rm -rf /tmp/Swarm/pingidentity-server-profiles
   docker volume pingdirectory-config
   git clone https://github.com/pingidentity/pingidentity-server-profiles.git /tmp/Swarm/pingidentity-server-profiles
   docker stack deploy -c basic2.yaml basic2
   ```

   The resulting output will be similar to this: 
   ```bash
   Creating network basic2_pingnet
   Creating service basic2_pingdirectory
   ```

2. To stop the swarm and clean up the configuration for this example, use the following sequence of commands:
   ```bash
   docker stack rm basic2
   rm -rf /tmp/Swarm/basic2
   rm -rf /tmp/Swarm/pingidentity-server-profiles
   ``` -->

### Deploy using the fullstack.yaml file

This example deploys a full, integrated stack of these PingIdentity services:

* PingFederate \(Admin\)
* PingFederate \(Engine\)
* PingAccess
* PingDirectory
* Ping Data Console

1. The configuration in `fullstack.yaml` doesn't any mounted `/opt/in` or `/opt/out` volumes as in previous examples. You can deploy the stack using either:

* The helper script `swarm-start.sh`. See the **Helper scripts** topic below for more information.
* The command `docker stack deploy -c fullstack.yaml fullstack`.

2. You can stop the swarm using:

   `docker stack rm fullstack`

## Helper scripts

There are two shell scripts you can use to start and cleanup the example Swarms. These scripts will also create and clean up any `/opt/out` volumes in `/tmp/Swarm/<stack-name>/<product name>`.

### `swarm-start.sh`

Use the `swarm-start.sh` script to start the stack in the Docker Swarm environment.

Usage: `swarm-start.sh <stack-name>.yaml`

For example, `swarm-start.sh basic1.yaml`

### `swarm-cleanup.sh`

Use the `swarm-cleanup.sh` script to clean up the stack in the Docker Swarm environment.

Usage: `swarm-cleanup.sh <stack-name>.yaml`

For example, `swarm-cleanup.sh basic1.yaml`

## Console application

If you're using the Ping Data Console container with the examples, you can log in to Ping Data Console using:

`https://localhost:8443/console/`

From the Ping Data Console, use the following information to log in to PingDirectory or PingDataSync:

* PingDirectory
    - Server: pingdirectory
    - Username: administrator
    - Password: 2FederateM0re
  
* PingDirectorySync
    - Server: pingdirectorysync
    - Username: administrator
    - Password: 2FederateM0re

