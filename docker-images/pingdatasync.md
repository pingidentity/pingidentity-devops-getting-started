# PingDataSync

This docker image includes the Ping Identity PingDataSync product binaries and associated hook scripts to create and run a PingDataSync instance.

## Related Docker Images

* pingidentity/pingbase - Parent Image

  > **This image inherits, and can use, Environment Variables from** [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)

* pingidentity/pingdatacommon - Common PingData files \(i.e. hook scripts\)
* pingidentity/pingdownloader - Used to download product bits

## Environment Variables

In addition to environment variables inherited from [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase), the following environment `ENV` variables can be used with this image.

| ENV Variable | Default | Description |
| ---: | :--- | :--- |
| TAIL\_LOG\_FILES | ${SERVER\_ROOT\_DIR}/logs/sync |  |
| LICENSE\_FILE\_NAME | PingDirectory.lic |  |
| LICENSE\_SHORT\_NAME | PD |  |
| LICENSE\_VERSION | 7.2 |  |
| PING\_PRODUCT | PingDataSync |  |
| STARTUP\_COMMAND | ${SERVER\_ROOT\_DIR}/bin/start-server |  |
| STARTUP\_FOREGROUND\_OPTS | --nodetach |  |
| ROOT\_USER\_PASSWORD\_FILE | ${SECRETS\_DIR}/root-user-password |  |

## Ports Exposed

The following ports are exposed from the container. If a variable is used, then it may come from a parent container

* ${LDAP\_PORT}
* ${LDAPS\_PORT}
* ${HTTPS\_PORT}
* ${JMX\_PORT}

## Running a PingDataSync container

\`\`\` docker run  --name pingdatasync  --publish 1389:389  --publish 8443:443  --detach  --env SERVER\_PROFILE\_URL=[https://github.com/pingidentity/pingidentity-server-profiles.git](https://github.com/pingidentity/pingidentity-server-profiles.git)  --env SERVER\_PROFILE\_PATH=simple-sync/pingdatasync  pingidentity/pingdatasync

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdatasync/hooks/README.md) for details on all pingdatasync hook scripts

This document auto-generated from [_pingdatasync/Dockerfile_](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatasync/Dockerfile)

Copyright \(c\) 2019 Ping Identity Corporation. All rights reserved.

