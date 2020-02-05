# Standalone deployment scripts

You can use our shell scripts to run, stop and cleanup our product images. These scripts are located in your `${HOME}/projects/devops/pingidentity-devops-getting-started/10-docker-standalone` directory:

* `docker-run.sh`
* `docker-stop.sh`
* `docker-cleanup.sh`

## `docker-run.sh`

Starts the product images as individual (standalone)containers.

Usage:

```text
./docker-run.sh { container name } [ --debug ]
  container_name: pingdirectory
                  pingfederate
                  pingaccess
                  pingdataconsole
                  pingcentral
                  all
  --debug
```

> Use the `--debug` option only when launching a single container. This option drops you into a container shell and displays debug details.

The `all` option runs all product images in the `10-docker-standalone` directory.

### Examples

Run a standalone PingDirectory container:

```bash
./docker-run.sh pingdirectory
```

Run a standalone PingFederate container with the `--debug` option. This will display the container operations in your shell, rather than starting the PingFederate instance:

```bash
./docker-run.sh pingfederate --debug
```

## `docker-stop.sh`

Stops the standalone containers.

Usage:

```text
./docker-stop.sh { container name }
  container_name: pingdirectory
                  pingfederate
                  pingaccess
                  pingdataconsole
                  pingcentral
                  all
```

> Use the `--debug` option only when launching a single container. This option drops you into a container shell and displays debug details.

The `all` option stops all product containers.

### Examples

Stop a standalone PingDirectory container:

```bash
./docker-run.sh pingdirectory
```

Stop all containers:

```bash
./docker-stop.sh all
```

## `docker-cleanup.sh`

Cleans up the standalone containers.

Usage:

```text
./docker-run.sh { container name } [ --force ]
  container_name: pingdirectory
                  pingfederate
                  pingaccess
                  pingdataconsole
                  pingcentral
                  all
  --force
```

> The `--force` option forces clean up and removal of the directories bind mounted to the `/opt/out` and `/opt/in` volumes. See the *Save your configuration changes* topic in [Get started](getStarted.md) for more information about these volumes.

The `all` option cleans up all product containers.

### Examples

Clean up a standalone PingDirectory container:

```bash
./docker-cleanup.sh pingdirectory
```

Force the clean up all containers (no prompt for confirmation):

```bash
./docker-cleanup.sh all --force
```