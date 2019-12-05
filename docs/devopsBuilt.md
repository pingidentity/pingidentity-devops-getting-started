# Use DevOps-built containers

If you're ready to do more thorough testing of Ping Identity solutions, and have some familiarity with containerization and Docker images, you can use our DevOps-built and configured containers. 

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

     
