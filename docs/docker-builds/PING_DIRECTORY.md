# Ping Identity PingDirectory Docker Image

## Running a PingDirectory container
The easiest way to test test a simple standalone image of PingDirectory is to cut/paste the following command into a terminal on a machine with docker.

```
  docker run \
           --name pingdirectory \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/server-profile-pingidentity-getting-started.git \
           --env SERVER_PROFILE_PATH=pingdirectory \
           pingidentity/pingdirectory
```

You can view the Docker logs with the command:

```
  docker logs -f pingdirectory
```

You should see the ouptut from a PingDirectory install and configuration, ending with a message the the PingDirectory has started.  After it starts, you will see some typical access logs.  Simply ``Ctrl-C`` afer to stop tailing the logs.

## Running a sample 100/sec search rate test
With the PingDirectory running from the pevious section, you can run a ``searchrate`` job that will send load to the directory at a rate if 100/sec using the following command.

```
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
Connect an LDAP Client (such as Apache Directory Studio) to this container:

|                 |                                   |
| --------------: | --------------------------------- |
| LDAP Port       | 1389 (mapped to 389)              |
| HTTPS Port      | 8443 (mapped to 843)              |
| LDAP Base DN    | dc=example,dc=com                 |
| Root Username   | cn=administrator                  |
| Root Password   | 2FederateM0re                     |

## Connection with a REST Client
Connection a REST client from Postman or a browser.

|                 |                                   |
| --------------: | --------------------------------- |
| URL             | https://localhost:8443/scim/Users |
| Username        | cn=administrator                   |
| Password        | 2PingDirectory                    |

## Stopping/Removing the container
To stop the container:

```
  docker container stop pingdirectory
```

To remove the container:

```
  docker container rm -f pingdirectory
```
