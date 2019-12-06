# Build your own containers

If your organization has certain requirements that are not met by our DevOps-maintained containers, you can do either of the following:

  * Use any of our maintained Docker images as a baseline to create your own.
  * If your organization is currently using PingFederate, you can export your current PingFederate configuration and use it as a custom server profile.  

## Prerequisites

* Docker for macOS, Linux, or Windows. [For macOS and Windows](https://www.docker.com/products/docker-desktop). Most of our testing has been done on macOS.
* [Git](https://git-scm.com/downloads).

### Requirements for VMs

* External ports to expose: 443, 9000, 8080, 7443, 9031, 9999, 1636-1646, 1443-1453, 8443.
  > There are other ports used for communication between our solutions, but this will occur on the local Docker network. 
* Recommended resources: 30 Gb of storage, 2-4 CPU cores, 10+ Gb memory.
  > On a VM, Docker is allowed full access to machine resources by default. On macOS, because the OS runs docker-engine, you'll need to raise the default allocated resources (in Docker > Preferences > Advanced).
  
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
   
  5. Go to the `${HOME}/projects/devops/pingidentity-devops-getting-started` directory and run our `setup` script to quickly and easily set up your local DevOps environment for the Ping Identity solutions. For example, from `${HOME}/projects/devops` enter:

     ```text
     cd pingidentity-devops-getting-started
     ./setup
     ```
     > The setup script also adds command aliases to make running Docker and Kubernetes commands easier. 
     
  6. Refresh your OS shell to make the command aliases available. For example, enter:
     ```text
     source ~/.bash_profile
     ```
     After refreshing your OS shell, enter `dhelp` to see the listing of the command aliases.
     > If the `dhelp` command isn't working, see [Troubleshooting](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/docs/troubleshooting/BASIC_TROUBLESHOOTING.md)

  7. Look through our [Docker images](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images) to find a suitable Docker image to use as your baseline.
  
  8. Be familiar with the information in [Hooks](https://pingidentity-devops.gitbook.io/devops/docker-builds/docker_builds_hooks).
  
  9. Use the information for our [Docker standalone containers](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/10-docker-standalone) to customize your Docker container.
  
      If your organization is using PingFederate, you can export your current PingFederate configuration to use for the Docker container. See the [server-profiles Quickstart](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/docs/server-profiles/QUICKSTART.md) for more information.
      
  10. You can add your own configurations through the management consoles for the Ping Identity solutions as needed. However, your configuration changes will not be saved when you bring down or remove the Docker stack, unless you persist your data by [mounting the configuration changes to a local Docker volume](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data), or by using server profiles.
  
      Profiles are used to externalize configuration from our solution so the configurations can be pulled in a repeatable manner at container startup. The different use cases and documentation is collected in [Server profiles](https://pingidentity-devops.gitbook.io/devops/server-profiles).
