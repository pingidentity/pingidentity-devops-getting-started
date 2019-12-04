# Use DevOps-built containers

If you're ready to do more thorough testing of Ping Identity solutions, and have some familiarity with containerization and Docker images, you can use our DevOps-built and configured containers. You'll need to have both Docker and Git installed on your local machine.

  1. Get a Ping Identity DevOps [evaluation license](https://pingidentity-devops.gitbook.io/devops/prod-license#obtaining-a-ping-identity-devops-user-and-key). 
  2. Save your DevOps user and key in a text file. It'll look something like this:

     ```text
     PING_IDENTITY_DEVOPS_USER=jsmith@example.com
     PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
     ```

     > Be sure to use the exact variable names.

  3. Go to the pingidentity-devops-getting-started directory and run our `setup` script to quickly and easily set up your local DevOps environment for the Ping Identity solutions:

     ```text
     cd pingidentity-devops-getting-started
     ./setup
     ```
     > The setup script also adds aliases to make running Docker and Kubernetes commands easier. Enter `dhelp` to see the listing of aliases.
     
     
  6. Persist your configuration changes by [mounting to a local volume.](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data)
     
