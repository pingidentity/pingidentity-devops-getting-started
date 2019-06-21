# 03-pingaccess

Demonstrate how to stand up a PingAccess container without any framework.

## How to startup a PingAccess container...

### Using docker-run.sh

Have a look at the `env_vars` file. After you have made any changes you want to make, run `../docker-run.sh pingaccess` By default this will create a directory under `/tmp/Docker/pingaccess` to persist any mutated data.

Once you are done with the container, you can run `../docker-cleanup.sh pingaccess` to remove it.

