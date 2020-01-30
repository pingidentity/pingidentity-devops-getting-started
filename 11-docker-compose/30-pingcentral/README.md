# 30-pingcentral

<a name="contents"></a>
## Contents ##
- [Getting Started](#getting-started)
- [Docker Compsoe Commands](#docker-compose-commands)
- [Verify Container](#verify-container)
- [Using the Container](#using-the-container)
- [Cleaning Up](#cleaning-up)
- [Preserving the Database](#preserving-the-database)
- [Configuring Trust in Docker PingCentral](#configuring-trust-in-docker)
  - [Configuring Trust using Environment Variables](#configuring-trust-env-variables)
  - [Configuring Trust using Properties Files](#configuring-trust-env-variables)
- [Configuring SSO in Docker PingCentral](#configuring-sso-in-docker)
  - [Configuring SSO using Properties Files](#configuring-sso-env-variables)
  - [Configuring SSO using Environment Variables](#configuring-sso-env-variables)
  
<a name="getting-started"></a>
## Getting started

Please refer to the [Docker Compose Overview](./) for details on how to start, stop, cleanup stacks.

<a name="docker-compose-commands"></a>
## Docker Compose Commands

To start the stack, from this directory run:

`docker-compose up -d`

Watch the directories initialize with:

`docker-compose logs -f`

<a name="verify-container"></a>
## Verify Container
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

<a name="using-the-container"></a>
## Using the containers

Once you see that the containers are healthy in `docker ps`

To see the PingCentral management console

* Go to [https://localhost:9022](https://localhost:9022)
* Log in with `Administrator / 2Federate`

<a name="cleaning-up"></a>
## Cleaning up

To bring PingCentral down:

`docker-compose down`

<a name="preserving-the-database"></a>
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


You can retrieve and save the hostkey by copying off the `pingcentral.jwk` file with the command: `docker cp pingcentral:/opt/out/instance/conf/pingcentral.jwk .`

<a name="configuring-trust-in-docker"></a>
## Configuring Trust in Docker

By default, PingCentral in Docker is insecure. This is due to setting the environment variable `PING_CENTRAL_BLIND_TRUST=true` in the docker-compose.yaml file, which tells PingCentral to trust all certificates by default.
This is great for Proof of Concepts as it enables a quick setup, but should not be used for production purposes.
Setting `PING_CENTRAL_BLIND_TRUST` to false will only allow public certificates to be used by your environments (such as PingFederate), unless you setup the trust store and configure PingCentral to use this truststore.

In order to setup the trust in your docker container, first create your trust store following the [documentation](https://docs.pingidentity.com/bundle/pingcentral/page/fqd1571866743761.html).
You will then need to inject your truststore into your docker container:

With docker compose, use `volumes`:
```
services:
  pingcentral:
    volumes:
      - ./conf/keystore.jks:/opt/in/instance/conf/keystore.jks
```

Or with docker commands:
```
docker run --volume ./conf/keystore.jks:/opt/in/instance/conf/keystore.jks
```

You then have two options for configuring PingCentral to use the created trust:

<a name="configuring-trust-env-variables"></a>
#### Configuring Trust in Docker Using Environment Variables

With docker compose, specify the following environment variables:
```
services:
  pingcentral:
    environment:
      - server.ssl.trust-any=false
      - server.ssl.https.verify-hostname=false
      - server.ssl.delegate-to-system=false
      - server.ssl.trust-store=/opt/in/instance/conf/keystore.jks
      - server.ssl.trust-store-password=InsertTruststorePasswordHere
```
Or with docker commands:
```
docker run --env server.ssl.trust-any=false --env server.ssl.https.verify-hostname=false --env server.ssl.delegate-to-system=false --env server.ssl.trust-store=/opt/in/instance/conf/keystore.jks --env server.ssl.trust-store-password=InsertTruststorePasswordHere
```

<a name="configuring-trust-env-variables"></a>
#### Configuring Trust in Docker Using Properties File

Update the following properties in your `application.properties` file:
```
server.ssl.trust-any
server.ssl.https.verify-hostname
server.ssl.delegate-to-system
server.ssl.trust-store
server.ssl.trust-store-password
```

<a name="configuring-sso-in-docker"></a>
## Configuring SSO in Docker PingCentral
Enabling SSO can be done through editing the properties file (`application.properties`) or by using environment variables. 
Whichever way you choose to implement SSO with docker, you may also need to edit the hosts file within docker.  
For example, with docker-compose, you can update the /etc/hosts file using the following example configuration:
```
services:
  pingcentral:
    extra_hosts:
      - "pingfedenvironment.ping-eng.com:12.105.33.333"
      - "pingcentral-sso-domain.com:127.0.0.1"
```

<a name="configuring-sso-env-variables"></a>
#### Configuring SSO Using Properties File
To enable SSO in your docker PingCentral instance, update the default `application.properties` in accordance with [this document](https://docs.pingidentity.com/bundle/pingcentral/page/orc1570565605492.html).
You will then need to inject this `application.properties` file into the path `/opt/in/instance/conf/application.properties` of your Docker Container by adding the following volume to the docker-compose file under the `pingcentral` service:
```
volumes:
    - ./conf/application.properties:/opt/in/instance/conf/application.properties
```

<a name="configuring-sso-env-variables"></a>
#### Configuring SSO Using Environment Variables
Enabling SSO through environment variables involves injecting the correct environment variables into your docker container.
You can do this via docker compose:
```
services:
  pingcentral:
    environment:
      - pingcentral.sso.oidc.enabled=true
      - pingcentral.sso.oidc.issuer-uri=https://pingfedenvironment.ping-eng.com:9031
      - pingcentral.sso.oidc.client-id=ac_oic_client_id
      - pingcentral.sso.oidc.client-secret=ClientSecretHere
      - pingcentral.sso.oidc.oauth-jwk-set-uri=https://pingfedenvironment.ping-eng.com:9031/ext/oauth/pingcentral/jwks
```
or with docker commands:
```
docker run --env pingcentral.sso.oidc.enabled=true --env pingcentral.sso.oidc.issuer-uri=https://pingfedenvironment.ping-eng.com:9031 --env pingcentral.sso.oidc.client-id=ac_oic_client_id --env pingcentral.sso.oidc.client-secret=ClientSecretHere --env pingcentral.sso.oidc.oauth-jwk-set-uri=https://pingfedenvironment.ping-eng.com:9031/ext/oauth/pingcentral/jwks
```

