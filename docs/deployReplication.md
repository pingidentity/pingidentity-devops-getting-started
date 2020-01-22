# Deploy a replicated pair of PingDirectory containers

You'll use Docker Compose to deploy a replicated pair of PingDirectory containers.

## What you'll do

  * Deploy the replicated pair.
  * Log in to the management consoles.
  * Bring down or stop the stack.

## Prerequisites

  * You've already been through [Get started](evaluate.md) to set up your DevOps environment and run a test deployment of the products.

## To deploy a replicated pair of PingDirectory containers:

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/02-replicated-pair` directory. Enter:

  `docker-compose up -d --scale <product>=2`

  Where <product> is one of the supported solutions for replication (pingfederate, pingdirectory, pingaccess).

2. At intervals, check to see when the containers are healthy and running:

  `docker-compose ps`

  > Enter `dhelp` for a listing of the DevOps command aliases. See the [Docker Compose command line reference](https://docs.docker.com/compose/reference/overview/) for the Docker Compose commands.

## Test the deployment

1. Verify that data is replicating between the pair by adding a description entry for the first container. Enter:

  ```text
  docker container exec -it 02-replicated-pair_pingdirectory_1 /opt/out/instance/bin/ldapmodify
  dn: uid=user.0,ou=people,dc=example,dc=com
  changetype: modify
  replace: description
  description: Made this change on the first container.

  <Ctrl-D>
  ```

  > The blank line followed by the `<Ctrl-D>` is important. It's how entries are separated in the LDAP Data Interchange Format (LDIF).

2. Check that the second container in the pair now has a matching entry for the description. Enter:

    ```text
    docker container exec -it 02-replicated-pair_pingdirectory_2 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,dc=example,dc=com -s base '(&)' description
    ```
  The result should show the description that you specified for the first container, similar to this:

    ```text
    # dn: uid=user.0,ou=people,dc=example,dc=com
    # description: Made this change on the first container.
    ```

When you no longer want to run this full stack evaluation, you can either stop the running stack, or bring the stack down.

Entering:

 `docker-compose stop`

will stop the running stack without removing any of the containers or associated Docker networks.

Entering:

 `docker-compose down`

 will remove all of the containers and associated Docker networks.
