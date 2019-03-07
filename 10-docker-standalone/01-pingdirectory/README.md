# Purpose
This folder provides scripts to make it easier to get started with a local PingDirectory Docker container.
When used on its own, the Docker run commands you need to fully customize your containers can get pretty complex.
Let's explore why.

## How to
### Simplest way
To run a simple PingDirectory, you could use the command below:
```Bash
docker run -d --publish 1389:389 \
    --env SERVER_PROFILE_URL=https://github.com/pingidentity/server-profile-pingidentity-getting-started.git \
    --env SERVER_PROFILE_PATH=pingdirectory \
    pingidentity/pingdirectory
```

### Using a local volume
Another approach you can take is to git clone the repository locally and provide the local files to your container at startup. Try this:
```Bash
mkdir -p /tmp/Docker/pd-basic
git clone https://github.com/pingidentity/server-profile-pingidentity-getting-started.git /tmp/Docker/pd-basic
docker run -d --publish 2389:389 \
    -v /tmp/Docker/pd-basic/pingdirectory:/opt/in \
    pingidentity/pingdirectory
```
### Using a data container
In this pattern, the volumes are created implicitly by associating the runtime container with a data container. The advantage is that the volumes can be delivered via a Docker registry, typically private.
We'll use the folder in the previous step
```Bash
docker create -v /opt --name pd-config busybox
docker cp /tmp/Docker/pd-basic/. pd-config:/opt/in
docker run -d --publish 3389:389 \
    --volumes-from pd-config \
    pingidentity/pingdirectory
```

### Using an output volume
Look at the `env_vars` file and the `docker-run.sh` script in the parent directory to see where and how the output volume is mapped.

In particular, in the `docker-run.sh` script you will see that a second volume is mounted to /opt/out.

Then run `../docker-run.sh pingdirectory`

By default this will create a directory under /tmp/Docker/pingdirectory/runtime to persist any mutated data.
Within the container, the instance is copied to /opt/out which is mounted to /tmp/Docker/pingdirectory/runtime.
This is useful when working with the product because you may want to have easy access to log files, install custom extensions or velocity templates. Persisting the instance runtime data also allows the container to restart and not reinstall from scratch every time.

In production, this pattern is useful to maintain good performance for very large databases and allow quick self-healing without the need to join the replication topology anew with every container restart.

Once you are done with the container, you can run `../docker-cleanup.sh pingdirectory` in the parent directory to remove everything safely.