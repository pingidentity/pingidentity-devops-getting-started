# Deploy PingCentral

This use case employs the `pingidentity-server-profiles/baseline/pingcentral` server profile. This server profile contains a MySQL database engine located in `pingidentity-server-profiles/baseline/pingcentral/external-mysql-db`.

## Prerequisites

* You've already been through [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Either:
  * Clone the [`pingidentity-server-profiles`](https://github.com/pingidentity/pingidentity-server-profiles) repository to your local `${HOME}/projects/devops` directory.
  * Fork the [`pingidentity-server-profiles`](https://github.com/pingidentity/pingidentity-server-profiles) repository to your Github repository, then clone this repository to a local directory.

## What You'll Do

* Deploy the stack.
* Log in to the management consoles.
* Bring down or stop the stack.
* Preserve the database.
* Configure trust for PingCentral.
* Configure SSO for PingCentral

## Deploy Stack

You'll use the `docker-compose.yaml` file in your local `pingidentity-devops-getting-started/11-docker-compose/30-pingcentral` directory to deploy the cluster.

1. Go to your local `pingidentity-devops-getting-started/11-docker-compose/30-pingcentral` directory. Enter:

      ```sh
      docker-compose up -d
      ```

1. Check that the containers are healthy and running:

      ```sh
      docker-compose ps
      ```

      You can also display the startup logs:

      ```sh
      docker-compose logs -f
      ```

      To see the logs for a particular product container at any point, enter:

      ```sh
      docker-compose logs <product-container-name>
      ```

1. Log in to the management consoles:

    | Product | Connection Details |
    | --- | --- |
    | [PingCentral](https://localhost:9022) | <ul><li>URL: [https://localhost:9022](https://localhost:9022)</li><li>Username: administrator</li><li>Password: 2Federate</li></ul> |

1. Copy the MySQL database hostkey created on initial startup in `./conf/pingcentral.jwk` to your local `/tmp` directory. You'll need the hostkey in a subsequent step.

1. When you no longer want to run this stack, you can either stop the running stack, or bring the stack down.

      To stop the running stack without removing any of the containers or associated Docker networks, enter:

      ```sh
      docker-compose stop
      ```

      To remove all of the containers and associated Docker networks, enter:

      ```sh
      docker-compose down
      ```

## Preserve Database

To preserve any updates to the MySQL database, you need to mount the `./conf/mysql/data` directory to the `/var/lib/mysql` volume. You also need to mount `./conf/pingcentral.jwk` to `/opt/server/conf/pingcentral.jwk` to save the hostkey file created on initial startup of the PingCentral container. You'll need the saved hostkey to access the database.

1. If the stack is running, bring it down:

      ```sh
      docker-compose down
      ```

1. Open the `pingidentity-devops-getting-started/11-docker-compose/30-pingcentral/docker-compose.yml` file and mount `./conf/mysql/data` to the `/var/lib/mysql` volume under `pingcentral-db`. For example:

      ```yaml
      pingcentral-db:
          image: mysql
          command: --default-authentication-plugin=mysql_native_password
          environment:
            MYSQL_ROOT_PASSWORD: 2Federate
          volumes:
            - ./conf/mysql/data:/var/lib/mysql
          ports:
            - "3306:3306"
          networks:
            - pingnet
      ```

      Keep the `docker-compose.yml` file open.

1. In the `pingidentity-devops-getting-started/11-docker-compose/30-pingcentral/docker-compose.yml` file, also mount `./conf/pingcentral.jwk` to the `/opt/server/conf/pingcentral.jwk` volume under the `pingcentral` service. For example:

      ```yaml
        pingcentral:
          image: pingidentity/pingcentral:${PING_IDENTITY_DEVOPS_TAG}
          command: wait-for pingcentral-db:3306 -t 7200 -- entrypoint.sh start-server
          environment:
            - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
            - SERVER_PROFILE_PATH=baseline/pingcentral/external-mysql-db
            - PING_IDENTITY_ACCEPT_EULA=YES
            - PING_CENTRAL_BLIND_TRUST=true
            - PING_CENTRAL_VERIFY_HOSTNAME=false
            - MYSQL_USER=root
            - MYSQL_PASSWORD=2Federate
          env_file:
            - ~/.pingidentity/devops
          volumes:
            - ./conf/pingcentral.jwk:/opt/server/conf/pingcentral.jwk
          ports:
            - "9022:9022"
          depends_on:
            - "pingcentral-db"
          networks:
            - pingnet
      ```

1. Save `docker-compose.yml` and start the stack:

      ```sh
      docker-compose up -d
      ```

1. Copy the hostkey `pingcentral.jwk` file you saved to your local `/tmp` in a prior step to the `/opt/out/instance/conf` volume. Enter:

      ```sh
      docker cp /tmp/pingcentral.jwk:/opt/out/instance/conf
      ```

      The hostkey will now be persisted and available at each startup.

## Configure Trust

By default, for the purposes of quick setup, the PingCentral container is insecure. This is due to the environment variable `PING_CENTRAL_BLIND_TRUST=true` setting in the `docker-compose.yml` file. By default, all certificates are trusted.

> **Caution**: Remember to change this setting for production environments.

Setting `PING_CENTRAL_BLIND_TRUST=false` allows public certificates to be used only by your Ping Identity environments (such as PingFederate), unless you set up the trust store and configure PingCentral to use this trust store.

1. To set up the trust in the container, first create your trust store according to the [PingCentral documentation](https://docs.pingidentity.com/bundle/pingcentral-14/page/fqd1571866743761.html).

1. Inject the trust store into the PingCentral container:

   * For stacks, inject the trust store using the `volumes` definition in the `docker-compose.yml` file to mount `./conf/keystore.jks` to `/opt/in/instance/conf/keystore.jks`. For example:

     ```yaml
     services:
       pingcentral:
         volumes:
           - ./conf/keystore.jks:/opt/in/instance/conf/keystore.jks
     ```

   * For standalone PingCentral containers, use:

     ```sh
     docker run --volume \
      ./conf/keystore.jks:/opt/in/instance/conf/keystore.jks
     ```

1. Configure PingCentral to use the created trust either by using environment variables or the properties file:

   * Using environment variables

     * For stacks, specify these environment variables in the `environment` definition of the `docker-compose.yml` file:

       ```yaml
       services:
         pingcentral:
           environment:
             - server.ssl.trust-any=false
             - server.ssl.https.verify-hostname=false
             - server.ssl.delegate-to-system=false
             - server.ssl.trust-store=/opt/in/instance/conf/keystore.jks
             - server.ssl.trust-store-password=InsertTruststorePasswordHere
       ```

     * For standalone PingCentral containers:

       ```sh
       docker run --env server.ssl.trust-any=false \
        --env server.ssl.https.verify-hostname=false \
        --env server.ssl.delegate-to-system=false \
        --env server.ssl.trust-store=/opt/in/instance/conf/keystore.jks \
        --env server.ssl.trust-store-password=<InsertTruststorePasswordHere>
       ```

   * Using properties files

     * Update the following properties in your `pingidentity-server-profiles/baseline/pingcentral/external-mysql-db/instance/conf/application.properties.subst` file:

       ```text
       server.ssl.trust-any
       server.ssl.https.verify-hostname
       server.ssl.delegate-to-system
       server.ssl.trust-store
       server.ssl.trust-store-password
       ```

## Configure SSO

You can enable SSO by either:

* Editing the properties file `pingidentity-server-profiles/baseline/pingcentral/external-mysql-db/instance/conf/application.properties.subst`.
* Using environment variables.

You may also need to edit the hosts file used by the container. For stacks, you can update the container's `/etc/hosts` file by adding `extra_hosts` definitions to the `docker-compose.yml` file. For example:

```yaml
services:
  pingcentral:
    extra_hosts:
      - "pingfedenvironment.ping-eng.com:12.105.33.333"
      - "pingcentral-sso-domain.com:127.0.0.1"
```

* Using the properties file

  1. Update the `pingidentity-server-profiles/baseline/pingcentral/external-mysql-db/instance/conf/application.properties.subst` file according to the [PingCentral documentation](https://docs.pingidentity.com/bundle/pingcentral-14/page/hbh1575916943828.html).

  1. Inject the `application.properties.subst` file into the container using the `volumes` definition in the `docker-compose.yml` file to mount `./conf/application.properties` to the `/opt/in/instance/conf/application.properties` volume under the `pingcentral` service of the `docker-compose.yml` file :

     ```yaml
     pingcentral:
        volumes:
          - ./conf/application.properties:/opt/in/instance/conf/application.properties
     ```

* Using environment variables

      To enable SSO using environment variables, add `environment` definitions for these environment variables.

      For stacks, add the definitions to the `docker-compose.yml` file. For example:

      ```yaml
      services:
        pingcentral:
          environment:
            - pingcentral.sso.oidc.enabled=true
            - pingcentral.sso.oidc.issuer-uri=https://pingfedenvironment.ping-eng.com:9031
            - pingcentral.sso.oidc.client-id=ac_oic_client_id
            - pingcentral.sso.oidc.client-secret=ClientSecretHere
            - pingcentral.sso.oidc.oauth-jwk-set-uri=https://pingfedenvironment.ping-eng.com:9031/ext/oauth/pingcentral/jwks
      ```

      For standalone PingCentral containers:

      ```sh
      docker run --env pingcentral.sso.oidc.enabled=true \
        --env pingcentral.sso.oidc.issuer-uri=https://pingfedenvironment.ping-eng.com:9031 \
        --env pingcentral.sso.oidc.client-id=ac_oic_client_id \
        --env pingcentral.sso.oidc.client-secret=ClientSecretHere \
        --env pingcentral.sso.oidc.oauth-jwk-set-uri=https://pingfedenvironment.ping-eng.com:9031/ext/oauth/pingcentral/jwks
      ```
