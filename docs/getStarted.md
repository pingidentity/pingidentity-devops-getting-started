# Get started

You can quickly deploy Docker images of Ping Identity products. We use Docker to deploy the Docker images in stable, network-enabled containers. For lightweight orchestration purposes, we use Docker Compose. For enterprise-level orchestration, we use Kubernetes. The Docker images are preconfigured to provide working instances of our products, either as single containers or as orchestrated sets of containers. 

You'll need an evaluation license to use the DevOps resources. You'll clone our getting started repository, set up your DevOps environment, and deploy our full stack of product containers using Docker Compose. When you first start the Docker stack, each of the Docker images is automatically pulled from our repository, unless you've already pulled the images from our [Docker Hub](https://hub.docker.com/u/pingidentity/) site. You can then choose to try out any one or more of our products, all preconfigured to interoperate.

## Prerequisites

* Either [Docker CE for Windows](https://docs.docker.com/v17.12/install/) or [Docker for macOS](https://docs.docker.com/v17.12/docker-for-mac/install/).
* [Git](https://git-scm.com/downloads).

## What you'll do

1. Create a Ping Identity account get a DevOps evaluation license, or sign on to your existing account and register for a DevOps user name and key.
2. Create the local DevOps directory, `${HOME}/projects/devops`.

   > We'll use this as the parent directory for all DevOps examples referenced in our documentation.

3. Clone the DevOps repository, `https://github.com/pingidentity/pingidentity-devops-getting-started.git` to your local `${HOME}/projects/devops` directory.
4. Run our `setup` script in `${HOME}/projects/devops/pingidentity-devops-getting-started` to quickly set up the DevOps environment. Your entries in the file `${HOME}/.pingidentity/devops`. You can also add to this file the license variable assignment `PING_IDENTITY_ACCEPT_EULA=YES`.
5. Use Docker Compose to deploy the full stack located in your local `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory.
6. Log in to the management consoles for the products.
7. See [Saving your configuration changes](saveConfigs.md) to persist data to a local Docker volume.
8. Stop or bring down the stack.

See the [DevOps registration](#devopsReg) and [Initial setup](#initSetup) topics below for complete instructions.

When you've finished the initial setup and deployment, you can then choose to:

* Rerun the full stack evaluation. 
* [Configure and deploy our other examples](deploy.md).
* [Customize the container and stack configurations](config.md).

<a name="devopsReg"></a>
## DevOps registration

Registering for our DevOps program grants you credentials that can be provided as variables to PingIdentity containers. This streamlines license issues by allowing the container to automatically retrieve an evaluation license upon container startup. 

  > Evaluation licenses are short-lived and *not* intended for use in production deployments.

1. [Create a Ping Identity account, or sign on to your existing account](https://www.pingidentity.com/en/account/sign-on.html).
2. You'll need a DevOps user name and DevOps key. Your DevOps user name is the email address associated with your Ping Identity account. Request your DevOps key using this [form](https://docs.google.com/forms/d/e/1FAIpQLSdgEFvqQQNwlsxlT6SaraeDMBoKFjkJVCyMvGPVPKcrzT3yHA/viewform).

    Your DevOps user name and key will be sent to your email. This will generally take only a few business hours.

> It is recommended (due to ease of use) to use the devop user/key approach for evaluating Ping Identity container use-cases. However, if you'd rather use an existing Ping Identity product license, see [Use an existing license](existingLicense.md) for instructions before proceeding.

<a name="initSetup"></a>
## Initial setup

1. Create a local DevOps directory in this location: `${HOME}/projects/devops`. For example, enter:

    ```bash
    mkdir -p ${HOME}/projects/devops
    cd ${HOME}/projects/devops
    ```

   > We'll use this as the parent directory for all DevOps examples referenced in our documentation. A common location will make it easier for us to help you if issues occur.

2. Clone the DevOps repository to the `${HOME}/projects/devops` directory on your local machine:

   ```bash
   git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git
   ```

3. Go to the `${HOME}/projects/devops/pingidentity-devops-getting-started` directory and run our `setup` script.
This script will ask some questions then create an environment on the host machine. 

For example, enter:

   ```bash
   cd pingidentity-devops-getting-started
   ./setup
   ```
   > The setup script also offers to add command aliases to make running Docker and Kubernetes commands easier.

   The setup script stores your entries in the file `${HOME}/.pingidentity/devops`. Many of the examples in `${HOME}/projects/devops/pingidentity-devops-getting-started` will either source the `devops` file as variables into the container, or expect the file to be sourced in the current shell. So:


4. Refresh your OS shell to make the command aliases available. For example, enter:

   ```bash
   source ~/.bash_profile
   ```

   After refreshing your OS shell, enter `dhelp` to see the listing of the command aliases.

   > If the `dhelp` command isn't working, see [Troubleshooting](troubleshooting/BASIC_TROUBLESHOOTING.md)

## Deploy the stack

1. Deploy the full stack of product containers:

   > For your initial deployment of the stack, we recommend you make no changes to the `docker-compose.yaml` file to ensure you have a successful first-time deployment. Any configuration changes you make will not be saved when you bring down the stack. For subsequent deployments, see [Saving your configuration changes](saveConfigs.md).

   a. To start the stack, on your local machine, go to the `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

   ```bash
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

   See the [Docker Compose overview](../11-docker-compose/README.md) for help with starting, stopping, and cleaning up our Docker stacks. You can also refer to the Docker Compose documentation [on the Docker site](https://docs.docker.com/compose/).

2. Log in to the management consoles for the products:

   * Ping Data Console for PingDirectory
     - Console URL: https://localhost:8443/console
     - Server: pingdirectory
     - User: Administrator
     - Password: 2FederateM0re

   * PingFederate
     - Console URL: https://localhost:9999/pingfederate/app
     - User: Administrator
     - Password: 2FederateM0re

   * PingAccess
     - Console URL: https://localhost:9000
     - User: Administrator
     - Password: 2FederateM0re

   * Ping Data Console for DataGovernance
     - Console URL: https://localhost:8443/console
     - Server: pingdatagovernance
     - User: Administrator
     - Password: 2FederateM0re

   * PingCentral
     - Console URL: https://localhost:9022
     - User: Administrator
     - Password: 2Federate

   * Apache Directory Studio for PingDirectory
     - LDAP Port: 1389
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

