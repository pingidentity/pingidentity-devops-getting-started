# 03-full-stack

This will deploy a full Docker stack of PingAccess, PingFederate and PingDirectory, using Docker Compose for lightweight orchestration.

See [Docker Compose Overview](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose) for help with starting, stoppping, cleaning up our Docker stacks. You can also refer to the Docker Compose documentation [on the Docker site](https://docs.docker.com/compose/).

## Starting the stack

To start the stack, on your local machine, go to the `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

`docker-compose up -d`

This will run our [Docker Compose YAML configuration file](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/03-full-stack/docker-compose.yaml) for the full Docker stack. 

Use this command to display the startup process for the stack:

`docker-compose logs -f`

Use this command to display the status of the Docker containers in the stack:

`docker ps`

## Using the containers

### PingDirectory

When the status of the PingDirectory instance shows that it is healthy and running, you can do either of the following:

* Use OAuthPlayground:

  1. In a browser, enter [https://localhost:9031/OAuthPlayground](https://localhost:9031/OAuthPlayground).
  2. Click the `implicit` link.
  3. Click `Submit`.
  4. Log in with these credentials: `user.0 / 2FederateM0re`

* Use PingDataConsole to manage PingDirectory:

  1. In a browser, enter [https://localhost:8443/console](https://localhost:8443/console)
  2. Log in using these credentials:
     server: `pingdirectory` 
     user: `Administrator` 
     password: `2FederateM0re`

* View the LDAP traffic for PingDirectory. This is exposed on LDAP port 1636:

  * In a browser, enter [https://localhost:1636/dc=example,dc=com](https://localhost:1636/dc=example,dc=com).

### PingFederate

When the status of the PingFederate instance shows that it is healthy and running, you can display the PingFederate management console:

  1. In a browser, enter [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app).
  2. Log in with these credentials: `Administrator / 2FederateM0re`

### PingAccess

When the status of the PingFederate instance shows that it is healthy and running, you can display the PingAccess management console:

  1. In a browser, enter [https://localhost:9000](https://localhost:9000).
  2. Log in with these credentials: `Administrator / 2FederateM0re`
  
  > You will be asked to accept the license agreement and to change the password.

## Cleaning up

To bring the stack down:

`docker-compose down`

