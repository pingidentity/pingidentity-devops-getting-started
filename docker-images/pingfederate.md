# PingFederate

This docker image includes the Ping Identity PingFederate product binaries and associated hook scripts to create and run both PingFederate Admin and Engine nodes.

## Related Docker Images

* pingidentity/pingbase - Parent Image

  > **This image inherits, and can use, Environment Variables from** [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)

* pingidentity/pingcommon - Common Ping files \(i.e. hook scripts\)
* pingidentity/pingdownloader - Used to download product bits

## Ports Exposed

The following ports are exposed from the container. If a variable is used, then it may come from a parent container

* 9031
* 9999

## Environment Variables

In addition to environment variables inherited from [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase), the following environment `ENV` variables can be used with this image.

| ENV Variable | Default | Description |
| ---: | :--- | :--- |
| PING\_PRODUCT | PingFederate |  |
| LICENSE\_DIR | ${SERVER\_ROOT\_DIR}/server/default/conf |  |
| LICENSE\_FILE\_NAME | pingfederate.lic |  |
| LICENSE\_SHORT\_NAME | PF |  |
| LICENSE\_VERSION | 9.2 |  |
| OPERATIONAL\_MODE | STANDALONE |  |
| CLUSTER\_BIND\_ADDRESS | NON\_LOOPBACK |  |
| STARTUP\_COMMAND | ${SERVER\_ROOT\_DIR}/bin/run.sh |  |
| TAIL\_LOG\_FILES | ${SERVER\_ROOT\_DIR}/log/server.log |  |

## Running a PingFederate container

To run a PingFederate container:

```text
  docker run \
           --name pingfederate \
           --publish 9999:9999 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingfederate \
           pingidentity/pingfederate:edge
```

Follow Docker logs with:

```text
docker logs -f pingfederate
```

If using the command above with the embedded [server profile](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/585ffb631844d7aee2464059cecb6e50e8916c86/docs/docker-images/server-profiles/README.md), log in with:

* [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)
  * Username: Administrator
  * Password: 2FederateM0re

    **Docker Container Hook Scripts**

    Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingfederate/hooks/README.md) for details on all pingfederate hook scripts

This document auto-generated from [_pingfederate/Dockerfile_](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingfederate/Dockerfile)

Copyright \(c\) 2019 Ping Identity Corporation. All rights reserved.

