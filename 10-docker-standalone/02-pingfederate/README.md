# 02-pingfederate

Demonstrate how to stand up a PingFederate container without any framework.

## How to startup a PingFederate container...

### Using docker-run.sh

Have a look at the `env_vars` file. After you have made any changes you want to make, run `../docker-run.sh pingfederate` By default this creates a directory under `/tmp/Docker/pingfederate` to persist any mutated data.

Once you are done with the container, you can run `../docker-cleanup.sh pingfederate` to remove everything.
