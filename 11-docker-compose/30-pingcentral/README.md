# 30-pingcentral

## Getting started

Please refer to the [Docker Compose Overview](./) for details on how to start, stop, cleanup stacks.

## Compose Commands

To start the stack, from this directory run:

`docker-compose up -d`

Watch the directories initialize with:

`docker-compose logs -f`

## Verify
Once the admin is up, you can check PingCentral status with:
```shell
docker ps
```
You should see similar to:
```
CONTAINER ID        IMAGE                     COMMAND                  CREATED              STATUS                        PORTS                               NAMES
bb366900188b        ping/pingcentral:latest   "./bootstrap.sh wait…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:9022->9022/tcp              pingcentral
dbc21438833a        mysql:latest              "docker-entrypoint.s…"   About a minute ago   Up About a minute             0.0.0.0:3306->3306/tcp, 33060/tcp   mysql
```

## Using the containers

Once you see that the containers are healthy in `docker ps`

To see the PingCentral management console

* Go to [https://localhost:9022](https://localhost:9022)
* Log in with `Administrator / 2Federate`

## Cleaning up

To bring PingCentral down:

`docker-compose down`

## Preserving the Database
In order to preserve the MySQL database, you will need to mount a volume in your `docker-compose.yml` file under `pingcentral-db`:
```
volumes:
      - ./conf/mysql/data:/var/lib/mysql
```

A database hostkey file (pingcentral.jwk) is also required to access the preserved database.
Upon first-time startup of PingCentral with a new database, a hostkey is created. This hostkey needs to be preserved and injected with each startup.  
You can accomplish this by adding a volume in your `docker-compose.yml` file under the `pingcentral` service:
```
volumes:
      - ./conf/pingcentral.jwk:/opt/server/conf/pingcentral.jwk
```


You can preserve the hostkey by copying off the `pingcentral.jwk` file with the command: `docker cp pingcentral:/opt/out/instance/conf/pingcentral.jwk .`

## Enabling SSO in Docker PingCentral
Enabling SSO can be done through editing property files (`application.properties`). 
To enable SSO in your docker PingCentral instance, update the default `application.properties` in accordance with [this document](https://docs.pingidentity.com/bundle/pingcentral/page/orc1570565605492.html).
You will then need to inject this `application.properties` file into the path `/opt/in/instance/conf/application.properties` of your Docker Container by adding the following volume to the docker-compose file under the `pingcentral` service:
```
volumes:
    - ./conf/application.properties:/opt/in/instance/conf/application.properties
```

## Configuring Trust in Docker

By default, PingCentral in Docker is insecure. This is due to setting the environment variable `PING_CENTRAL_BLIND_TRUST=true` in the docker-compose.yaml file.
Setting this value to false will secure your Docker container, but only allow public certificates to be used by your environments (such as PingFederate).

There is an upcoming task aiming to make it easier to configure customer specific trust stores in docker containers: [PASS-3131](https://jira.pingidentity.com/browse/PASS-3131).



