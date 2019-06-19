# PingAccess

This docker image includes the Ping Identity PingAccess product binaries and associated hook scripts to create and run both PingAccess Admin and Engine nodes.

## Related Docker Images

* `pingidentity/pingbase` - Parent Image

  > **This image inherits, and can use, Environment Variables from** [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)

* `pingidentity/pingcommon` - Common Ping files \(i.e. hook scripts\)
* `pingidentity/pingdownloader` - Used to download product bits

## Ports Exposed

The following ports are exposed from the container. If a variable is used, then it may come from a parent container

* 9000
* 3000
* ${HTTPS\_PORT}

## Environment Variables

In addition to environment variables inherited from [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase), the following environment `ENV` variables can be used with this image.

| ENV Variable | Default | Description |
| ---: | :--- | :--- |
| PING\_PRODUCT | PingAccess |  |
| LICENSE\_DIR | ${SERVER\_ROOT\_DIR}/conf |  |
| LICENSE\_FILE\_NAME | pingaccess.lic |  |
| LICENSE\_SHORT\_NAME | PA |  |
| LICENSE\_VERSION | 5.2 |  |
| STARTUP\_COMMAND | ${SERVER\_ROOT\_DIR}/bin/run.sh |  |
| TAIL\_LOG\_FILES | ${SERVER\_ROOT\_DIR}/log/pingaccess.log |  |

## Running a PingDirectory container

To run a PingAccess container:

```text
  docker run \
           --name pingaccess \
           --publish 9000:9000 \
           --publish 443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingaccess \
           pingidentity/pingaccess:edge
```

Follow Docker logs with:

```text
docker logs -f pingaccess
```

If using the command above with the embedded [server profile](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/585ffb631844d7aee2464059cecb6e50e8916c86/docs/docker-images/server-profiles/README.md), log in with:

* [https://localhost:9000](https://localhost:9000)
  * Username: Administrator
  * Password: 2Access

    **Docker Container Hook Scripts**

    Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingaccess/hooks/README.md) for details on all pingaccess hook scripts

This document auto-generated from [_pingaccess/Dockerfile_](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingaccess/Dockerfile)

Copyright \(c\) 2019 Ping Identity Corporation. All rights reserved.

