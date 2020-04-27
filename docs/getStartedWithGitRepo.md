# Using Getting Started Git Repo

This provides help in getting started with the Ping Identity Getting Started Git repository.  It will require an understanding of `git` as well as use of the `docker` and `docker-compose` commands.
> It is recommended that you review all [Getting Started](gettingStarted.md) document if you haven't already.


## Tools Prerequisites

* [Git](https://git-scm.com/downloads)



## Clone the Ping Identity Devops Getting Started Repo

1. Clone the DevOps repository to the `${HOME}/projects/devops` directory on your local machine:

   ```bash
   cd ${PING_IDENTITY_DEVOPS_HOME}   # Created during 'ping-devops config'
   git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git
   ```

## Deploy the full stack

1. Deploy the full stack of product containers:

   > For your initial deployment of the stack, we recommend you make no changes to the `docker-compose.yaml` file to ensure you have a successful first-time deployment. Any configuration changes you make will not be saved when you bring down the stack. For subsequent deployments, see [Saving your configuration changes](saveConfigs.md).

   a. To start the stack, on your local machine, go to the `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

   ```bash
   cd ${PING_IDENTITY_DEVOPS_HOME}
   cd pingidentity-devops-getting-started/11-docker-compose/03-full-stack
   docker-compose up -d
   ```

   The full set of DevOps images is automatically pulled from our repository, if you haven't already pulled the images from [Docker Hub](https://hub.docker.com/u/pingidentity/).

   b. Use this command to display the logs as the stack starts:

   ```bash
   docker-compose logs -f
   ```

   Enter `Ctrl+C` to exit the display.

   c. Use either of these commands to display the status of the Docker containers in the stack:

   * `docker ps` (enter this at intervals)
   * `watch "docker container ls --format 'table {{.Names}}\t{{.Status}}'"`

   Refer to the Docker Compose documentation [on the Docker site](https://docs.docker.com/compose/).

2. Log in to the management consoles for the products:

   * Ping Data Console for PingDirectory
     - Console URL: `https://localhost:8443/console`
     - Server: pingdirectory
     - User: Administrator
     - Password: 2FederateM0re

   * PingFederate
     - Console URL: `https://localhost:9999/pingfederate/app`
     - User: Administrator
     - Password: 2FederateM0re

   * PingAccess
     - Console URL: `https://localhost:9000`
     - User: Administrator
     - Password: 2FederateM0re

   * Ping Data Console for DataGovernance
     - Console URL: `https://localhost:8443/console`
     - Server: pingdatagovernance
     - User: Administrator
     - Password: 2FederateM0re

   * PingCentral
     - Console URL: `https://localhost:9022`
     - User: Administrator
     - Password: 2Federate

   * Apache Directory Studio for PingDirectory
     - LDAP Port: 1636
     - LDAP BaseDN: dc=example,dc=com
     - Root Username: cn=administrator
     - Root Password: 2FederateM0re

<!-- TODO: add instructions pertaining to the use cases with fullstack
  1. OAuth Playground
  2. httpbin
  3. datagov? Pingcentral? -->

3. When you no longer want to run this full stack evaluation, you can either stop the running stack, or bring the stack down.

   To stop the running stack without removing any of the containers or associated Docker networks, enter:

   ```bash
   docker-compose stop
   ```

   To remove all of the containers and associated Docker networks, enter:

   ```bash
   docker-compose down
   ```

