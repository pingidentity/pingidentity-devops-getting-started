# Docker Swarm

This directory contains examples that automate the manual steps taken in the Docker standalone directories.

Ensure that you have started Docker Swarm \(this only needs to be done one time\) before deploying the stack by running: `docker swarm init`

## Example Docker Swarm Stack Deployment Files

Included are the following stack deployment yaml files that can be used in the following command: `docker stack deploy -c stack.yaml stack-name`

> Note: Many of these examples include mounted local volumes to as examples of how to pull in configurations from files, rather than git repos, as well as persisting the resulting running configurations to an out volume.

| Example | Description |
| :--- | :--- |
| basic1.yaml | Deploy PingDirectory in a stack with mounted out volume |
| basic2.yaml | Deploy PingDirectory in a stack with mounted in/out volumes |
| basic3.yaml | Deploy PingDirectory in a stack with externally mounted volumes |
| fullstack.yaml | Deploy PingFederate, PingDirectory, PingDataConsole and PingAccess in a networked stack |
| simple-sync.yaml | Deploy PingDirectory, PingDataSync and PingDataConsole in a networked stack |

## Example - basic1.yaml

This example deploys a PingDirectory with a mounted `out` volume that will persist the deployed PingDirectory. You will see a `volumes:` definition that will mount the contianer's `/opt/out` directory to `/tmp/Swarm/basic1/pingdirectory`. It is important to have an empty directory at that location before you startup the swarm.

Follow these steps to startup the swarm for this example \(with output\):

```text
rm -rf /tmp/Swarm/basic1
mkdir -p /tmp/Swarm/basic1/pingdirectory
docker stack deploy -c basic1.yaml basic1

######OUTPUTS######
# Creating network basic1_pingnet
# Creating service basic1_pingdirectory
###################
```

You can watch the image startup by viewing the logs using \(with example\):

`docker container logs -f <container-id>`

> Remember, to see find the container-id, use the comand `docker container ls`

To stop the swarm, you need to remove the swarm. Removing the container will only stop that running container, and once the swarm sees that it's not running a new one will get created. To remove it, remove the stack using the example \(with output\):

```text
docker stack rm basic1

######OUTPUTS######
# Removing service basic1_pingdirectory
# Removing network basic1_pingnet
###################
```

It is important to understand that stopping the swarm will still leave the persisted directory created intact on the host machine in the directory that we created earlier. If you restarted the swarm again, it would simply startup the PingDirectory with the same configuration. To wipe out the created directory on the host machine, simply remove that directory:

`rm -rf /tmp/Swarm/basic1`

## Example - basic2.yaml

This example deploys a PingDirectory with a mounted `out` volume that will persist the deployed PingDirectory, as well as a mounted `in` volume. Much like the first example this deployment will add a mount to a location used as the input configuration of the PingDirectory, instead of a git repo that was used in the first example.

Since we need to get the configuration to a local directory, you will need to `git clone` the configuration locally, and use that as the mount point for the container's `/opt/in` directory.

Follow these steps to startup the swarm for this example \(with output\):

```text
rm -rf /tmp/Swarm/basic2
mkdir -p /tmp/Swarm/basic2/pingdirectory
rm -rf /tmp/Swarm/pingidentity-server-profiles
git clone https://github.com/pingidentity/pingidentity-server-profiles.git /tmp/Swarm/pingidentity-server-profiles
docker stack deploy -c basic2.yaml basic2

######OUTPUTS######
# Creating network basic2_pingnet
# Creating service basic2_pingdirectory
###################
```

The remainder of the steps to watch the logs and stop the container are similar to the first example. To stop and cleanup for this example:

```text
docker stack rm basic2
rm -rf /tmp/Swarm/basic2
rm -rf /tmp/Swarm/pingidentity-server-profiles
```

## Example - basic3.yaml

This example is the exact same one as before, however it shows how to use a `docker volume`, in this case with the `in` volume.

We will need to `git clone` to a local directory and the create a `docker volume` for that directory that will be used by the `basic3.yaml` definition.

## Example - fullstack.yaml

This example provides a full integrated stack of all the PingIdentity serives including:

* PingFederate \(Admin\)
* PingFederate \(Engine\)
* PingAccess
* PingDirectory
* PingDataConsole

The default `fullstack.yaml` doesn't require any mounted `in` or `out` volumes as in previous examples, so they can be started wit the helper `swarm-start.sh` script as explained below, or by simply deploying the stack with:

`docker stack deploy -c fullstack.yaml fullstack`

and be stopped with:

`docker stack rm fullstack`

## Helper scripts to run Swarm examples

There are two shell scripts that can be used to start and cleanup the example Swarms. These will also create and cleanup any `out` volumes under a generic location of `/tmp/Swarm/<stack-name>/<product name>`.

### swarm-start.sh

Used to start the stack in Docker Swarm environment.

```text
Usage: swarm-start.sh <stack-name>.yaml

Example:

   swarm-start.sh basic1.yaml
```

### swarm-cleanup.sh

Used to cleanup the Docker stack in Docker Swarm environment.

```text
Usage: swarm-cleanup.sh <stack-name>.yaml

Example:

   swarm-cleanup.sh basic1.yaml
```

## Console Application

If you are using the PingDataConsole container from these swarm images, you should be able to login with

[http://localhost:8080/console/](http://localhost:8080/console/)

### PingDirectory

```text
     Server: pingdirectory
   Username: administrator
   Password: 2FederateM0re
```

### PingDirectorySync

```text
     Server: pingdirectorysync
   Username: administrator
   Password: 2FederateM0re
```

