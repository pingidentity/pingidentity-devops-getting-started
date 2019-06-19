# PingDirectory

This docker image includes the Ping Identity PingDirectory product binaries and associated hook scripts to create and run a PingDirectory instance or instances.

## Related Docker Images

* pingidentity/pingbase - Parent Image

  > **This image inherits, and can use, Environment Variables from** [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)

* pingidentity/pingdatacommon - Common PingData files \(i.e. hook scripts\)
* pingidentity/pingdownloader - Used to download product bits

## Environment Variables

In addition to environment variables inherited from [**pingidentity/pingbase**](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase), the following environment `ENV` variables can be used with this image.

| ENV Variable | Default | Description |
| ---: | :--- | :--- |
| PING\_PRODUCT | PingDirectory | Ping product name |
| LICENSE\_FILE\_NAME | PingDirectory.lic | Name of License File |
| LICENSE\_SHORT\_NAME | PD | Shortname used when retrieving license from License Server |
| LICENSE\_VERSION | 7.2 | Version used when retrieving license from License Server |
| REPLICATION\_PORT | 8989 | Default PingDirectory Replication Port |
| ADMIN\_USER\_NAME | admin | Replication administrative user |
| STARTUP\_COMMAND | ${SERVER\_ROOT\_DIR}/bin/start-server |  |
| STARTUP\_FOREGROUND\_OPTS | --nodetach |  |
| ROOT\_USER\_PASSWORD\_FILE | ${SECRETS\_DIR}/root-user-password |  |
| ADMIN\_USER\_PASSWORD\_FILE | ${SECRETS\_DIR}/admin-user-password |  |
| ENCRYPTION\_PASSWORD\_FILE | ${SECRETS\_DIR}/encryption-password |  |
| TAIL\_LOG\_FILES | ${SERVER\_ROOT\_DIR}/logs/access | Files tailed once container has started |
| MAKELDIF\_USERS | 0 | Number of users to auto-populate using make-ldif templates |

## Ports Exposed

The following ports are exposed from the container. If a variable is used, then it may come from a parent container

* ${LDAP\_PORT}
* ${LDAPS\_PORT}
* ${HTTPS\_PORT}
* ${JMX\_PORT}
* 5005

## Running a PingDirectory container

The easiest way to test test a simple standalone image of PingDirectory is to cut/paste the following command into a terminal on a machine with docker.

```text
  docker run \
           --name pingdirectory \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
          pingidentity/pingdirectory:edge
```

You can view the Docker logs with the command:

```text
  docker logs -f pingdirectory
```

You should see the ouptut from a PingDirectory install and configuration, ending with a message the the PingDirectory has started. After it starts, you will see some typical access logs. Simply `Ctrl-C` afer to stop tailing the logs.

## Running a sample 100/sec search rate test

With the PingDirectory running from the pevious section, you can run a `searchrate` job that will send load to the directory at a rate if 100/sec using the following command.

```text
docker exec -it pingdirectory \
        /opt/out/instance/bin/searchrate \
                -b dc=example,dc=com \
                --scope sub \
                --filter "(uid=user.[1-9])" \
                --attribute mail \
                --numThreads 2 \
                --ratePerSecond 100
```

## Connecting with an LDAP Client

Connect an LDAP Client \(such as Apache Directory Studio\) to this container using the default ports and credentials

|  |  |
| ---: | :--- |
| LDAP Port | 1389 \(mapped to 389\) |
| LDAP Base DN | dc=example,dc=com |
| Root Username | cn=administrator |
| Root Password | 2FederateM0re |

## Connection with a REST Client

Connection a REST client from Postman or a browser using the default ports and credentials

|  |  |
| ---: | :--- |
| URL | [https://localhost:8443/scim/Users](https://localhost:8443/scim/Users) |
| Username | cn=administrator |
| Password | 2FederateM0re |

## Stopping/Removing the container

To stop the container:

```text
  docker container stop pingdirectory
```

To remove the container:

```text
  docker container rm -f pingdirectory
```

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdirectory/hooks/README.md) for details on all pingdirectory hook scripts

This document auto-generated from [_pingdirectory/Dockerfile_](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectory/Dockerfile)

Copyright \(c\) 2019 Ping Identity Corporation. All rights reserved.

