# Docker Compose

This folder is intended to demonstrate how to use Docker Compose to assemble several images, each with their own role, into a functioning deployed set of containers. Docker Compose can be useful for local development as it does not require an external orchestrator such as Docker Swarm or Kubernetes. Unlike with Swarm or Kubernetes, Compose deploys containers locally, not on remote machines.

## Example Stacks

Here are some of the example stacks available to help understand Docker Compose

| Example | Description |
| :--- | :--- |
| [01-simple-stack](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/b9d580025bf8cd1cd403d21bc9888ef0431b4681/11-docker-compose/01-simple-stack/REDAME.md) | A simple stack with a PingFederate container and a PingDirectory container |
| [02-replicated-pair](02-replicated-pair.md) | An example of a replicated pair of PingDirectory instances |
| [03-full-stack](03-full-stack.md) | A stack with PingDirectory, PingFederate, PingAccess, PingDataConsole. |
| [04-simple-sync](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/b9d580025bf8cd1cd403d21bc9888ef0431b4681/11-docker-compose/04-simple-sync/README.md) | A stack with PingDirectory, PingDataSync. |

## Docker Compose Basics

An official Overview on Docker Compose can be found [here](https://docs.docker.com/compose/overview/).

It is **important to note** that the examples provided will not persist data between runs if the docker stack is brought up and down. Please see the section below on [Persisting Container State and Data](./#persisting-container-state-and-data)

When running any of the docker-compose commands, you **must be in the same directory** as the `docker-compose.yaml` file.

## Pulling latest images in a Docker Compose Stack

The images referred to in the examples are updated very frequently on [Docker Hub](https://hub.docker.com/u/pingidentity), the default location for obtaining images. Make sure you get the latest version of the images with the command \(and example output\):

```text
docker-compose pull

######OUTPUTS######
# Pulling pingaccess      ... done
# Pulling pingfederate    ... done
# Pulling pingdirectory   ... done
# Pulling pingdataconsole ... done
```

> Note: Starting a stack the first time without doing a pull will automatically get the latest version.

## Starting a Docker Compose Stack

To start the stack in the **forground**, seeing all the messages from the services in their full glory, just use the command:

`docker-compose up`

Note tha that if you stop with a `Ctrl-C`, the stack will be stopped.

If you want to see the services startup in **backgroud**, use the `--detach` or `-d` option.

`docker-compose up --detach`

This will startup the services in the backgroud. See below on how to [Monitor a Docker Compose Stack](./#monitor-a-docker-compose-stack)

## Monitor a Docker Compose Stack

Once a stack is running, you can see the **containers running** with the command \(and example output\):

```text
docker-compose ps

######OUTPUTS######
#              Name                            Command                  State                                        Ports
# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# 03-full-stack_pingaccess_1        entrypoint.sh wait-for pin ...   Up (healthy)   3000/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9000->9000/tcp
# 03-full-stack_pingdataconsole_1   catalina.sh run                  Up (healthy)   0.0.0.0:8080->8080/tcp, 0.0.0.0:8443->8443/tcp
# 03-full-stack_pingdirectory_1     entrypoint.sh start-server       Up (healthy)   389/tcp, 0.0.0.0:1443->443/tcp, 5005/tcp, 0.0.0.0:1636->636/tcp, 689/tcp
# 03-full-stack_pingfederate_1      entrypoint.sh wait-for pin ...   Up (healthy)   0.0.0.0:9031->9031/tcp, 0.0.0.0:9999->9999/tcp
###################
```

And using this example, you can watch the **logs from the entire stack** with the command \(and example output\):

```text
docker-compose logs

######OUTPUTS######
# Attaching to 03-full-stack_pingdataconsole_1, 03-full-stack_pingfederate_1, 03-full-stack_pingdirectory_1, 03-full-stack_pingaccess_1
# ...
###################
```

## Stopping and Starting a Docker Compose Stack

To stop and start a docker compose stack once it's brought up, the following commands:

`docker-compose stop`

`docker-compose start`

## Cleaning up a Docker Compose Stack

To clean up a Docker Compse Stack, use the following command:

`docker-compose down`

And if you had stopped your stack at some point, you can remove any of the stopped services with the command:

`docker-compose rm`

## Persisting Container State and Data

If you would like to persist state and data of the container between docker-compose up/down, this can be done with a the addition of a volumes section to the `docker-compose.yaml` file.

Simply chose a location to persist your data. For the example, assume `/tmp/compose/pingdirectory_1`

Then, add a `volumes` section to a service in your `docker-compose.yaml` file like:

```yaml
  pingdirectory:
    ...
    volumes:
       - /tmp/compose/pingdirectory_1:/opt/out
```

When the stack is running, this will mount `/tmp/compose/pingdirectory_1` to the `/opt/out` directory in the container, which is the location the applications/data are installed. In fact, once started you can see everything installed and look at logs, etc by going directly to the local directory, in this case `/tmp/compose/pingdirectory_1`

