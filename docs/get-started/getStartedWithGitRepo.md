---
title: Deploy an Example Stack
---
# Deploy an Example Stack


!!! info "Orchestration note"
    While this example uses Docker Compose, our recommended platform for running Ping products in containers is Kubernetes. This example will be updated in the near future to use Helm charts and a default server profile collection.


The `pingidentity-devops-getting-started` [repository](https://github.com/pingidentity/pingidentity-devops-getting-started) contains working Docker and Kubernetes examples.

## What You'll Do

Use Git to clone the `pingidentity-devops-getting-started` repository, and Docker Compose to deploy the full stack example.

## Prerequisites

You have:

* Set up your DevOps environment.
* Installed [Git](https://git-scm.com/downloads).

## Clone the `getting-started` Repo

1. Clone the `pingidentity-devops-getting-started` repository to your local `${PING_IDENTITY_DEVOPS_HOME}` directory.

    > The `${PING_IDENTITY_DEVOPS_HOME}` environment variable was set when you ran `pingctl config`.

    ```sh
    cd "${PING_IDENTITY_DEVOPS_HOME}"
    git clone \
      https://github.com/pingidentity/pingidentity-devops-getting-started.git
    ```

## Deploy the Full Stack

1. Deploy the full stack of our product containers.

    !!! note "Initial Deployment"
        For the initial deployment of the stack, avoid making changes to the `docker-compose.yaml` file to ensure a successful first-time deployment. For subsequent deployments, see [Saving Your Configuration Changes](../how-to/saveConfigs.md).

    1. To start the stack, go to your local `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

        ```sh
        docker-compose up -d
        ```

        The full set of our product images is automatically pulled from our repository if they have not previously been pulled from [Docker Hub](https://hub.docker.com/u/pingidentity/).

    1. To display the logs as the stack starts, run:

        ```sh
        docker-compose logs -f
        ```

        Enter `Ctrl+C` to exit displaying the logs.

    1. To display the status of the Docker containers in the stack:

           * Run `docker ps` (manually run this at intervals)  OR
           * Run `watch "docker container ls --format 'table {{.Names}}\t{{.Status}}'"`.

           For more information, see the [Docker Compose Documentation](https://docs.docker.com/compose/).

1. These are the URLs and credentials to sign on to the management consoles for the products:

    | Product | Connection Details |
    | --- | --- |
    | [PingFederate](https://localhost:9999/pingfederate/app) | <ul> <li>URL: [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDirectory](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingdirectory:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAccess](https://localhost:9000) | <ul><li>URL: [https://localhost:9000](https://localhost:9000)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAuthorize](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingauthorize:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDataSync](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingdatasync:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingCentral](https://localhost:9022) | <ul><li>URL: [https://localhost:9022](https://localhost:9022)</li><li>Username: administrator</li><li>Password: 2Federate</li></ul> |
    | Apache Directory Studio for PingDirectory |<ul> <li>LDAP Port: 1636</li><li>LDAP BaseDN: dc=example,dc=com</li><li>Root Username: cn=administrator</li><li>Root Password: 2FederateM0re</li></ul> |

1. When you no longer want to run the stack, you can either stop or remove it:

    * To stop the running stack without removing any of the containers, associated Docker networks, or volumes, run:

        ```sh
        docker-compose stop
        ```

    * To stop the stack and remove the containers and associated Docker networks (volumes are still preserved), run:

        ```sh
        docker-compose down
        ```
## Next Steps

Now that you have deployed a set of our product images using the provided profiles, you can move on to deployments using configurations that more closely reflect use cases to be explored.

Options for this exploration include:

* Continue working with the full-stack server profile in your local `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory.
* Try other server profiles in your local `pingidentity-devops-getting-started` directory to quickly deploy typical use cases.
* Clone the [`pingidentity-server-profiles`](https://github.com/pingidentity/pingidentity-server-profiles) repository to your local `${HOME}/projects/devops` directory and learn about the setup of specific product configurations.

For further examples and more details on deploying using `docker compose` or `Kubernetes` see the [Deployment Section](../deployment/introduction.md) of this site.
