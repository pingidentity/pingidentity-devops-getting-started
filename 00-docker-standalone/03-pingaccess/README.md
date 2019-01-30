# Purpose
Demonstrate how to stand up a PingAccess container without any framework

## How to
Have a look at the `env_vars` file, once you have made your changes run `./docker-run.sh`
By default this will create a directory under /tmp/Docker/pingaccess to persist any mutated data.

Once you are done with the container, you can run `docker-cleanup.sh` to remove 