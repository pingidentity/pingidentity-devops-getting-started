# Getting started

You can quickly deploy DevOps images of Ping Identity solutions. These images are preconfigured to provide working instances of our solutions, either as single containers or an orchestrated set of containers. We use Docker to deploy the DevOps images in stable, network-enabled containers. For lightweight orchestration purposes, we use Docker Compose. For enterprise-level orchestration of containers, we use Kubernetes.  

For this evaluation, you'll deploy our full stack of solutions for DevOps using Docker Compose. You can then choose to try out any one or more of the solutions, all preconfigured to interoperate.

  > If you remove any of the existing configurations for a Ping Identity solution, the solution may no longer interoperate with other solutions in the Docker stack.

What you'll need to do:

  1. Check the prerequisites.
  2. Create a Ping Identity account, or sign on to your existing account and get a DevOps [evaluation license](docs/PROD-LICENSE.md).
  3. Save your DevOps credentials in a local text file.
  4. Make a local copy of the DevOps directory, `${HOME}/projects/devops`, on your local machine.
  5. Clone the DevOps repository, `https://github.com/pingidentity/pingidentity-devops-getting-started.git` to your local `${HOME}/projects/devops` directory.
  6. Run our `setup` script in `${HOME}/projects/devops/pingidentity-devops-getting-started` to quickly set up the DevOps environment.
  7. Use Docker Compose to deploy the full stack. This will run our [YAML configuration file](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/03-full-stack/docker-compose.yaml).
  8. If you want to persist any of your configuration changes, [mount the configuration changes to a local Docker volume](../tree/master/11-docker-compose#persisting-container-state-and-data)

See the procedures for complete information.

## Prerequisites

* Either [Docker CE for Windows](https://docs.docker.com/v17.12/install/) or [Docker for Mac OS](https://docs.docker.com/v17.12/docker-for-mac/install/).
* [Git](https://git-scm.com/downloads).

## Procedures

  1. [Create a Ping Identity account, or sign on to your existing account](https://www.pingidentity.com/en/account/sign-on.html).
  2. You'll need a DevOps user name and DevOps key. Your DevOps user name is the email address associated with your Ping Identity account. Request your DevOps key using this [form](https://docs.google.com/forms/d/e/1FAIpQLSdgEFvqQQNwlsxlT6SaraeDMBoKFjkJVCyMvGPVPKcrzT3yHA/viewform).
  
      Your DevOps user name and key will be sent to your email. This will generally take only a few business hours.
    
  2. Save your DevOps user name and key in a text file. It'll look something like this:

     ```text
     PING_IDENTITY_DEVOPS_USER=jsmith@example.com
     PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
     ```

     > Be sure to use the exact variable names.

  3. Make a local copy of the DevOps repository on your local machine in this location: `${HOME}/projects/devops`.  
  For example, enter:
    
      ```text
      mkdir -p ${HOME}/projects/devops
      cd ${HOME}/projects/devops
      ```
    > A common location will make it easier for us to help you if issues occur.  

  4. Clone the DevOps repository to the `${HOME}/projects/devops` directory on your local machine:

       `git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git`
   
  4. Go to the `${HOME}/projects/devops/pingidentity-devops-getting-started` directory and run our `setup` script to quickly and easily set up your local DevOps environment for the Ping Identity solutions. For example, from `${HOME}/projects/devops` enter:

     ```text
     cd pingidentity-devops-getting-started
     ./setup
     ```
     > The setup script also adds command aliases to make running Docker and Kubernetes commands easier. 
     
  5. Refresh your OS shell to make the command aliases available. For example, enter:
     ```text
     source ~/.bash_profile
     ```
     After refreshing your OS shell, enter `dhelp` to see the listing of the command aliases.
     > If the `dhelp` command isn't working, see [Troubleshooting](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/docs/troubleshooting/BASIC_TROUBLESHOOTING.md)

  5. Deploy the full stack of solutions:
  
       a. To start the stack, on your local machine, go to the `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory and enter:

        `docker-compose up -d` 

       b. You can watch the startup process. Use this command to display the logs as the stack starts:

        `docker-compose logs -f`

        Enter `Ctrl+C` to exit the display.
  
        Use either of these commands to display the status of the Docker containers in the stack:

        * `docker ps` (enter this at intervals)
        * `watch "docker container ls --format 'table {{.Names}}\t{{.Status}}'"`  
    
       See [Docker Compose Overview](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose) for help with starting, stoppping, cleaning up our Docker stacks. You can also refer to the Docker Compose documentation [on the Docker site](https://docs.docker.com/compose/).
    
  6. You can add your own configurations through the management consoles for the Ping Identity solutions as needed. However, your configuration changes will not be saved when you bring down or remove the Docker stack, unless you persist your data by [mounting the configuration changes to a local Docker volume](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data).
  
  7. When you no longer want to run this full stack evaluation, you can bring the stack down by entering:

    `docker-compose down`


