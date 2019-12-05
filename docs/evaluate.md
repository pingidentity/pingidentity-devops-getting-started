# Evaluate our solutions

If you're unfamiliar with Ping Identity solutions or with containerization, Docker images or orchestration, we recommend you begin by evaluating a set of our containerized solutions.

## Prerequisites

* Either [Docker CE for Windows](https://docs.docker.com/v17.12/install/) or [Docker for Mac OS](https://docs.docker.com/v17.12/docker-for-mac/install/).
* [Git](https://git-scm.com/downloads).
* Some familiarity with command line operation for your OS. Our instructions and the Docker and Kubernetes operations are all command line-driven.

## Procedures

  1. Get a Ping Identity DevOps [evaluation license](https://pingidentity-devops.gitbook.io/devops/prod-license#obtaining-a-ping-identity-devops-user-and-key). 
  2. Save your DevOps user and key in a text file. It'll look something like this:

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

  5. Deploy the [full Docker stack](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose/03-full-stack) of Ping Identity solutions using Docker Compose for lightweight orchestration. Our Docker images are preconfigured with the basic configurations needed to run and interoperate. 
  6. You can add your own configurations through the management consoles for the Ping Identity solutions as needed. However, your configuration changes will not be saved when you stop or remove the Docker stack, unless you persist your data by [mounting the configuration changes to a local Docker volume](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data).
    > If you remove any of the existing configurations for a solution, the solution may no longer interoperate with other solutions in the Docker stack.
  
  
