# Evaluate our solutions

If you're unfamiliar with Ping Identity solutions or with containerization, Docker images or orchestration, we recommend you begin by evaluating a set of our containerized solutions:

  1. Get a Ping Identity DevOps [evaluation license](https://pingidentity-devops.gitbook.io/devops/prod-license#obtaining-a-ping-identity-devops-user-and-key). 
  2. Save your DevOps user and key in a text file. It'll look something like this:

     ```text
     PING_IDENTITY_DEVOPS_USER=jsmith@example.com
     PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
     ```

     > Be sure to use the exact variable names.

  3. If you don't already have these installed on your local machine, install:
     * Either [Docker CE for Windows](https://docs.docker.com/v17.12/install/) or [Docker for Mac OS](https://docs.docker.com/v17.12/docker-for-mac/install/)
     * [Git](https://git-scm.com/downloads), then run:

       `git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git`
   
  4. Download and deploy the [full Docker stack](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose/03-full-stack) of Ping Identity solutions.
  5. Persist your configuration changes by [mounting to a local volume.](https://pingidentity-devops.gitbook.io/devops/examples/11-docker-compose#persisting-container-state-and-data)
