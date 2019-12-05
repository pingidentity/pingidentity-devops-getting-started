# 03-full-stack

This will deploy a full Docker stack of the Ping Identity solutions: PingAccess, PingFederate, PingDirectory, PingDataGovernance, and PingDataConsole, using Docker Compose for lightweight orchestration. The solutions in the stack are preconfigured using basic configurations to run and interoperate.

  > If you remove any of the existing configurations for a Ping Identity solution, the solution may no longer interoperate with other solutions in the Docker stack.


The user credentials needed for each solution are preset and provided in this document. You can change these credentials, however, it may make it more difficult for us to help you if you encounter issues.

See [Docker Compose Overview](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose) for help with starting, stoppping, cleaning up our Docker stacks. You can also refer to the Docker Compose documentation [on the Docker site](https://docs.docker.com/compose/).

## Starting the stack

  1. To start the stack, on your local machine, go to the `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

    `docker-compose up -d`

  This will run our [Docker Compose YAML configuration file](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/03-full-stack/docker-compose.yaml) for the full Docker stack. 

  2. You can watch the startup process. Use this command to display the logs as the stack starts:

    `docker-compose logs -f`

  Enter `Ctrl+C` to exit the display.
  
  Use either of these commands to display the status of the Docker containers in the stack:

  * `docker ps` (enter this at intervals)
  * `watch "docker container ls --format 'table {{.Names}}\t{{.Status}}'"`  
    
## Using the containers

### PingDirectory

When the status of the PingDirectory instance shows that it is healthy and running, you can use any of the following solutions or methods to connect to PingDirectory:

* Use OAuthPlayground:

  1. In a browser, enter [https://localhost:9031/OAuthPlayground](https://localhost:9031/OAuthPlayground).
  2. Click the `implicit` link.
  3. Click `Submit`.
  4. Log in with these credentials: 
  
    * User: `user.0`
    * Password: `2FederateM0re`

* Use PingDataConsole to manage PingDirectory:

  1. In a browser, enter [https://localhost:8443/console](https://localhost:8443/console)
  2. Log in using these credentials:
  
    * Server: `pingdirectory` 
    * User: `Administrator` 
    * Password: `2FederateM0re`

* Use Apache Directory Studio:

  * LDAP Port: 1389
  * LDAP BaseDN: dc=example,dc=com
  * Root Username: cn=administrator
  * Root Password: 2FederateM0re

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

When you stop or remove the stack, you'll lose any of your configuration changes unless you persist your data by [mounting the configuration changes to a local Docker volume](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data).

To bring the stack down, enter:

`docker-compose down`

