# Deploy an Example Stack

The `pingidentity-devops-getting-started` [repository](https://github.com/pingidentity/pingidentity-devops-getting-started) contains all of our working Docker and Kubernetes examples.

## What You'll Do

You'll use Git to clone the `pingidentity-devops-getting-started` repository, and Docker Compose to deploy the full stack example.

## Prerequisites

* You've already set up your DevOps environment. See [Get Started](getStarted.md).
* Installed [Git](https://git-scm.com/downloads)

## Clone the getting-started Repo

1. Clone the `pingidentity-devops-getting-started` repository to your local ${PING_IDENTITY_DEVOPS_HOME} directory:

    > The ${PING_IDENTITY_DEVOPS_HOME} environment variable was set when you ran `ping-devops config`.

    ```sh
    cd ${PING_IDENTITY_DEVOPS_HOME}
    git clone \
      https://github.com/pingidentity/pingidentity-devops-getting-started.git
    ```

## Deploy the Full Stack

1. Deploy the full stack of our product containers:

    > For your initial deployment of the stack, we recommend you make no changes to the `docker-compose.yaml` file to ensure you have a successful first-time deployment. Any configuration changes you make will not be saved when you bring down the stack. For subsequent deployments, see [Saving Your Configuration Changes](saveConfigs.md).

    1. To start the stack, go to your local `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

        ```sh
        docker-compose up -d
        ```

        The full set of our DevOps images is automatically pulled from our repository, if you haven't already pulled the images from [Docker Hub](https://hub.docker.com/u/pingidentity/).

    1. Use this command to display the logs as the stack starts:

        ```sh
        docker-compose logs -f
        ```

        Enter `Ctrl+C` to exit the display.

    1. Use either of these commands to display the status of the Docker containers in the stack:

      * `docker ps` (enter this at intervals)
      * `watch "docker container ls --format 'table {{.Names}}\t{{.Status}}'"`

      Refer to the [Docker Compose Documentation](https://docs.docker.com/compose/) for more information.

1. Log in to the management consoles for the products:

    * Ping Data Console for PingDirectory
        * Console URL: `https://localhost:8443/console`
        * Server: pingdirectory
        * User: Administrator
        * Password: 2FederateM0re

    * PingFederate
        * Console URL: `https://localhost:9999/pingfederate/app`
        * User: Administrator
        * Password: 2FederateM0re

    * PingAccess
        * Console URL: `https://localhost:9000`
        * User: Administrator
        * Password: 2FederateM0re

    * Ping Data Console for DataGovernance
        * Console URL: `https://localhost:8443/console`
        * Server: pingdatagovernance
        * User: Administrator
        * Password: 2FederateM0re

    * PingCentral
        * Console URL: `https://localhost:9022`
        * User: Administrator
        * Password: 2Federate

    * Apache Directory Studio for PingDirectory
        * LDAP Port: 1636
        * LDAP BaseDN: dc=example,dc=com
        * Root Username: cn=administrator
        * Root Password: 2FederateM0re

1. When you no longer want to run the stack, you can either stop or remove the stack.

    To stop the running stack (doesn't remove any of the containers or associated Docker networks or volumes), enter:

    ```sh
    docker-compose stop
    ```

    To stop the stack and remove all of the containers and associated Docker networks (preservers volumes), enter:

    ```sh
    docker-compose down
    ```
