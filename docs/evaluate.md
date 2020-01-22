# Get started

You can quickly deploy DevOps images of Ping Identity solutions. These images are preconfigured to provide working instances of our solutions, either as single containers or an orchestrated set of containers. We use Docker to deploy the DevOps images in stable, network-enabled containers. For lightweight orchestration purposes, we use Docker Compose. For enterprise-level orchestration of containers, we use Kubernetes.

You'll need an evaluation license to use the DevOps resources. You'll clone our getting started repository, set up your DevOps environment, and deploy our full stack of solutions for DevOps using Docker Compose. When you first start the Docker stack, our full set of DevOps images is automatically pulled from our repository, if you haven't already pulled the images from [Docker Hub](https://hub.docker.com/u/pingidentity/). You can then choose to try out any one or more of the solutions, all preconfigured to interoperate.

## Prerequisites

  * Either [Docker CE for Windows](https://docs.docker.com/v17.12/install/) or [Docker for macOS](https://docs.docker.com/v17.12/docker-for-mac/install/).
  * [Git](https://git-scm.com/downloads).

## What you'll do

1. Create a Ping Identity account get a DevOps evaluation license, or sign on to your existing account and register for a DevOps user name and key.
2. Save your DevOps credentials in a local text file.
3. Make a local copy of the DevOps directory, `${HOME}/projects/devops`.
4. Clone the DevOps repository, `https://github.com/pingidentity/pingidentity-devops-getting-started.git` to your local `${HOME}/projects/devops` directory.
5. Run our `setup` script in `${HOME}/projects/devops/pingidentity-devops-getting-started` to quickly set up the DevOps environment.
6. Refresh your OS shell.
7. Use Docker Compose to deploy the full stack. This will run our [YAML configuration file](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/03-full-stack/docker-compose.yaml).
8. Log in to the management consoles for the solutions.
9. Stop or bring down the stack.

See **DevOps registration** and **Initial setup** for complete instructions.

When you've finished the initial setup and deployment, you can then choose to:

* Rerun the full stack evaluation. See **Saving your configuration changes**.
* [Deploy a solution as a standalone Docker container, or deploy a set of solutions using orchestration](deploy.md).
* [Manage container and stack configurations](configDeploy.md).
* [Customize the DevOps images](customImages.md).

## DevOps registration

When you register for our DevOps program, you are issued credentials that will automate the process of retrieving a DevOps evalution license. If you already have a product license or licenses for the Ping Identity products you'll be using, you can use your existing license instead of the DevOps evaluation license. In this case, see **Using your existing product license**.

  > Evalution licenses are short-lived and *not* intended for use in production deployments.

1. [Create a Ping Identity account, or sign on to your existing account](https://www.pingidentity.com/en/account/sign-on.html).
2. You'll need a DevOps user name and DevOps key. Your DevOps user name is the email address associated with your Ping Identity account. Request your DevOps key using this [form](https://docs.google.com/forms/d/e/1FAIpQLSdgEFvqQQNwlsxlT6SaraeDMBoKFjkJVCyMvGPVPKcrzT3yHA/viewform).

    Your DevOps user name and key will be sent to your email. This will generally take only a few business hours.

3. Save your DevOps user name and key in a text file. It'll look something like this:

   ```text
   PING_IDENTITY_DEVOPS_USER=jsmith@example.com
   PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
   ```

   > Be sure to use the exact variable names.

   When you initially deploy a product container or stack, the DevOps evaluation license will be automatically retrieved.

### Use an existing product license

If you have an existing, valid product license for the product or products you'll be running, you can use this instead of the DevOps evaluation license. Use either of these two methods to make an existing product license file available to your deployment:

* Copy each license file to the server profile location associated with the product. The default server profile locations are:
- PingFederate: `instance/server/default/conf/pingfederate.lic`
- PingAccess: `instance/conf/pingaccess.lic`
- PingDirectory: `instance/pingdirectory.lic`
- PingDataGovernance: `instance/pingdatagovernance.lic`
- PingDataSync: `instance/pingdatasync.lic`
- PingCentral: `instance/conf/pingcentral.lic`

* For our Docker stacks, copy each license file to the `/opt/in` volume that you've mounted. The `/opt/in` directory overlays files onto the products runtime filesystem, the license needs to be named correctly and mounted in the exact location the product checks for valid licenses.

 1. Add a `volumes` section to the container entry for each product for which you have a license file in the `docker-compose.yaml` file you're using for the stack:

   * For the Workforce stack, the `docker-compose.yaml` file is in the [Solution-WorkForce](../Solution-WorkForce) directory.
   * For the Customer stack, the `docker-compose.yaml` file is in the [Solution-BaselineCustomer](../Solution-BaselineCustomer) directory.

 2. Under the `volumes` section, add a location to mount `opt/in`. For example:

    ```yaml
    pingfederate:
    .
    .
    .
    volumes:
      - <path>/pingfederate.lic:/opt/in/instance/server/default/conf/pingfederate.lic
    ```

    Where <path> is the location of your existing PingFederate license file.

    When the container starts, this will bind mount `<path>/pingfederate.lic` to this location in the container`/opt/in/instance/server/default/conf/pingfederate.lic`. The mount paths must match the expected license path for the product. These are:

    * PingFederate
      - Expected license file name: `pingfederate.lic`
      - Mount Path: `/opt/in/instance/server/default/conf/pingfederate.lic`

    * PingAccess
      - Expected license file name: `pingaccess.lic`
      - Mount Path: `opt/in/instnce/conf/pingaccess.lic`

    * PingDirectory
      - Expected License file name: `PingDirectory.lic`
      - Mount Path: `/opt/in/instance/PingDirectory.lic`

    * PingDataSync
      - Expected license file name: `PingDirectory.lic`
      - Mount Path: `/opt/in/instance/PingDirectory.lic`

    * PingDataGovernance
      - Expected license file name: `PingDataGovernance.lic`
      - Mount Path: `/opt/in/instance/PingDataGovernance.lic`

    * PingCentral
      - Expected license file name: `pingcentral.lic`
      - Mount Path: `/opt/in/instance/conf/pingcentral.lic`

 3. Repeat this process for the remaining container entries for which you have an existing license.

* For one of our single containers, use this syntax to make the license file available to the deployment:

   ```
   docker run \
       --name pingfederate \
       --volume <path>/pingfederate.lic>:/opt/in/instance/server/default/conf/pingfederate.lic
       pingidentity/pingfederate:edge
   ```

   Where <path> and the `/opt/in` mount path are as specified for our Docker stacks above.

## Initial setup

1. Make a local copy of the DevOps repository in this location: `${HOME}/projects/devops`. For example, enter:

    ```text
    mkdir -p ${HOME}/projects/devops
    cd ${HOME}/projects/devops
    ```
  > A common location will make it easier for us to help you if issues occur.

2. Clone the DevOps repository to the `${HOME}/projects/devops` directory on your local machine:

     `git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git`

3. Go to the `${HOME}/projects/devops/pingidentity-devops-getting-started` directory and run our `setup` script to quickly and easily set up your local DevOps environment for the Ping Identity solutions. For example, enter:

   ```text
   cd pingidentity-devops-getting-started
   ./setup
   ```
   > The setup script also adds command aliases to make running Docker and Kubernetes commands easier.

4. Refresh your OS shell to make the command aliases available. For example, enter:

   ```text
   source ~/.bash_profile
   ```
   After refreshing your OS shell, enter `dhelp` to see the listing of the command aliases.

  > If the `dhelp` command isn't working, see [Troubleshooting](docs/troubleshooting/BASIC_TROUBLESHOOTING.md)

## Deploy the stack

1. Deploy the full stack of solutions:

  > For your initial deployment of the stack, we recommend you make no changes to the `docker-compose.yaml` file to ensure you have a successful first-time deployment. Any configuration changes you make will not be saved when you bring down the stack. For subsequent deployments, see **Saving your configuration changes**.

     a. To start the stack, on your local machine, go to the `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

      `docker-compose up -d`

      The full set of DevOps images is automatically pulled from our repository, if you haven't already pulled the images from [Docker Hub](https://hub.docker.com/u/pingidentity/).

     b. Use this command to display the logs as the stack starts:

      `docker-compose logs -f`

      Enter `Ctrl+C` to exit the display.

     c. Use either of these commands to display the status of the Docker containers in the stack:

      * `docker ps` (enter this at intervals)
      * `watch "docker container ls --format 'table {{.Names}}\t{{.Status}}'"`

     See the [Docker Compose overview](../11-docker-compose/README.md) for help with starting, stopping, and cleaning up our Docker stacks. You can also refer to the Docker Compose documentation [on the Docker site](https://docs.docker.com/compose/).

2. Log in to the management consoles for the products:

   * PingDataConsole for PingDirectory
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

   * PingDataConsole for DataGovernance
    - Console URL: https://localhost:8443/console
    - Server: pingdatagovernance
    - User: Administrator
    - Password: 2FederateM0re

   * Apache Directory Studio for PingDirectory
    - LDAP Port: 1389
    - LDAP BaseDN: dc=example,dc=com
    - Root Username: cn=administrator
    - Root Password: 2FederateM0re

3. When you no longer want to run this full stack evaluation, you can either stop the running stack, or bring the stack down.

    Entering:

     `docker-compose stop`

    will stop the running stack without removing any of the containers or associated Docker networks.

    Entering:

     `docker-compose down`

     will remove all of the containers and associated Docker networks.

You can now choose to:

  * Rerun the full stack evaluation (`docker-compose up -d`). See **Save your configuration changes**.
  * [Deploy a solution as a standalone Docker container, or deploy a set of solutions using orchestration](deploy.md).
  * [Manage container and stack configurations](configDeploy.md).
  * [Customize the DevOps images](customImages.md).

## Save your configuration changes

To save any configuration changes you make when using the products in the stack, you need to set up a local Docker volume to persist state and data for the stack. If you don't do this, whenever you bring the stack down your configuration changes will be lost.

You'll bind mount a Docker volume location to the Docker `/opt/out` directory for the container. The location must be to a directory you've not already created. Our Docker containers use the `/opt/out` directory to store application data.

> Make sure the local directory is not already created. Docker needs to create this directory for the bind mount to `/opt/out`.

You can bind mount a Docker volume for containers in a stack or for single containers:

  * For a stack:

    1. Add a `volumes` section under the container entry for each product in the `docker-compose.yaml` file you're using for the stack.
    2. Under the `volumes` section, add a location to persist your data. For example:

       ```yaml
       pingfederate:
       .
       .
       .
       volumes:
        - /tmp/compose/pingfederate_1:/opt/out
       ```

    3. In the `environment` section, comment out the `SERVER_PROFILE_PATH` setting. The container will then use your `volumes` entry to supply the product state and data, including your configuration changes.

       When the container starts, this will bind mount `/tmp/compose/pingfederate_1` to the `/opt/out` directory in the container. You're also able to view the product logs and data in the `/tmp/compose/pingfederate_1` directory.

    4. Repeat this process for the remaining container entries in the stack.

  * For a single container, add a `volume` entry to the `docker run` command:

    ```
    docker run \
        --name pingfederate \
        --volume <local-path>:/opt/out
        pingidentity/pingfederate:edge
    ```
