# Docker Compose

You can use Docker Compose as a lightweight orchestration tool to assemble several images, each with their own role, into a functioning deployed set of containers. Docker Compose can be useful for local development as it does not require an external orchestrator such as Docker Swarm or Kubernetes. Unlike Docker Swarm or Kubernetes, Docker Compose deploys containers locally, not on remote machines.

## DevOps example stacks

We've set up some example Docker stacks to help you better understand the uses of Docker Compose:

| Example | Description |
| :--- | :--- |
| [01-simple-stack](./01-simple-stack/README.md) | A simple stack with a PingFederate container and a PingDirectory container |
| [02-replicated-pair](./02-replicated-pair/README.md) | An example of a replicated pair of PingDirectory instances |
| [03-full-stack](./03-full-stack/README.md) | A stack with PingDirectory, PingFederate, PingAccess, PingDataGovernance and PingDataConsole |
| [04-simple-sync](04-simple-sync/README.md) | A stack with PingDirectory, and PingDataSync. |
| [05-pingfederate-cluster](05-pingfederate-cluster/README.md) | A stack with a clustered PingFederate admin console and engine. |

## Docker Compose fundamentals

This document provides useful Docker Compose operations for our Docker stacks. See the official [Docker Compose documentation](https://docs.docker.com/compose/overview/) for complete information.

The example configurations do not persist data when the Docker stack is stopped (brought down). See the [Persisting Container State and Data](./#persisting-container-state-and-data) section at the end of this document for more information.

When running any of the Docker Compose commands, you must be in the same directory as the `docker-compose.yaml` file.

## Getting the current images in a Docker Compose stack

The Docker images used in the example stacks are frequently updated. You can get the current images in any one of the following ways:

  * Start one of our example stacks using Docker Compose. This will automatically pull the current version of each image in the stack.
  * For any of our example stacks, in the example directory you'll be using (such as, `03-full-stack`), enter:

    ```text
    docker-compose pull

    ######Sample output######
    # Pulling pingaccess      ... done
    # Pulling pingfederate    ... done
    # Pulling pingdirectory   ... done
    # Pulling pingdataconsole ... done
    ```
  * Get the images on the Ping Identity [Docker Hub](https://hub.docker.com/u/pingidentity). This is the public location for obtaining our Docker images. 

## Starting a stack using Docker Compose

To start the stack and display all the messages from the startup services, use the command:

  `docker-compose up`

  > If you use `Ctrl+C`, the stack will be stopped.

To start the stack without displaying the startup services information, use the `--detach` or `-d` option:

  `docker-compose up --detach`

## Monitoring a stack using Docker Compose

You can display the status of the stack by entering:

```text
docker-compose ps
```

This will display information similar to this:

```text
#              Name                            Command                  State                                        Ports
# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# 03-full-stack_pingaccess_1        entrypoint.sh wait-for pin ...   Up (healthy)   3000/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:9000->9000/tcp
# 03-full-stack_pingdataconsole_1   catalina.sh run                  Up (healthy)   0.0.0.0:8443->8443/tcp
# 03-full-stack_pingdirectory_1     entrypoint.sh start-server       Up (healthy)   389/tcp, 0.0.0.0:1443->443/tcp, 5005/tcp, 0.0.0.0:1636->636/tcp, 689/tcp
# 03-full-stack_pingfederate_1      entrypoint.sh wait-for pin ...   Up (healthy)   0.0.0.0:9031->9031/tcp, 0.0.0.0:9999->9999/tcp
```

You can also view the logs for all containers in the stack using this command:

```text
docker-compose logs
```

## Stopping a stack using Docker Compose

To stop a running stack, enter:

`docker-compose stop`

## Cleaning up a stack using Docker Compose

To clean up all of the data for a stack, enter:

`docker-compose down`

You can also choose to remove any of the stopped services with the command:

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

