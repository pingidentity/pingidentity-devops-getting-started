# Deploy an Example Stack

The `pingidentity-devops-getting-started` [repository](https://github.com/pingidentity/pingidentity-devops-getting-started) contains all of our working Docker and Kubernetes examples.

## What You'll Do

You'll use Git to clone the `pingidentity-devops-getting-started` repository, and Docker Compose to deploy the full stack example.

## Prerequisites

* You've already set up your DevOps environment. See [Get Started](../get-started/getStarted.md).
* Installed [Git](https://git-scm.com/downloads)

## Clone the `getting-started` Repo

1. Clone the `pingidentity-devops-getting-started` repository to your local ${PING_IDENTITY_DEVOPS_HOME} directory:

    > The ${PING_IDENTITY_DEVOPS_HOME} environment variable was set when you ran `ping-devops config`.

    ```sh
    cd ${PING_IDENTITY_DEVOPS_HOME}
    git clone \
      https://github.com/pingidentity/pingidentity-devops-getting-started.git
    ```

## Deploy the Full Stack

1. Deploy the full stack of our product containers:

    !!! note "Initial Deployment"
        For your initial deployment of the stack, we recommend you make no changes to the `docker-compose.yaml` file to ensure you have a successful first-time deployment. For subsequent deployments, see [Saving Your Configuration Changes](../how-to/saveConfigs.md).

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

    | Product | Connection Details |
    | --- | --- |
    | [PingFederate](https://localhost:9999/pingfederate/app) | <ul> <li>URL: [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDirectory](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingdirectory:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAccess](https://localhost:9000) | <ul><li>URL: [https://localhost:9000](https://localhost:9000)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDataGovernance](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingdatagovernance:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDataSync](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingdatasync:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingCentral](https://localhost:9022) | <ul><li>URL: [https://localhost:9022](https://localhost:9022)</li><li>Username: administrator</li><li>Password: 2Federate</li></ul> |
    | Apache Directory Studio for PingDirectory |<ul> <li>LDAP Port: 1636</li><li>LDAP BaseDN: dc=example,dc=com</li><li>Root Username: cn=administrator</li><li>Root Password: 2FederateM0re</li></ul> |

1. When you no longer want to run the stack, you can either stop or remove the stack.

    To stop the running stack (doesn't remove any of the containers or associated Docker networks or volumes), enter:

    ```sh
    docker-compose stop
    ```

    To stop the stack and remove all of the containers and associated Docker networks (preservers volumes), enter:

    ```sh
    docker-compose down
    ```
