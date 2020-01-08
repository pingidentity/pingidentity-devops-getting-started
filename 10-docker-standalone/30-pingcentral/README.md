# 30-pingcentral

Demonstrate how to stand up a PingCentral container without any framework.

## How to startup a PingCentral container...

### Using docker-run.sh

Have a look at the `env_vars` file. After you have made any changes you want to make, run `../docker-run.sh pingcentral` By default this creates a directory under `/tmp/Docker/pingcentral` to persist any mutated data.

Once you are done with the container, you can run `../docker-cleanup.sh pingcentral` to remove everything.
