# Deploy a Replicated PingDirectory Pair

You'll use Docker Compose to deploy a replicated pair of PingDirectory containers.

## What You'll Do

* Deploy the replicated pair.
* Test the deployment.
* Bring down or stop the stack.

## Prerequisites

* You've already been through [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## Deploy Stack

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/02-replicated-pair` directory. Enter:

      ```sh
      docker-compose up -d
      ```

      This kicks off a PingDirectory instance that will stand up, become healthy, and then go into a loop looking for other directories.

1. Scale up instances

      ```sh
      docker-compose up -d --scale pingdirectory=2
      ```

1. At intervals, check to see when the containers are healthy and running:

      ```sh
      docker-compose ps
      ```

      You can also display the startup logs:

      ```sh
      docker-compose logs -f
      ```

      To see the logs for a particular product container at any point, enter:

      ```sh
      docker-compose logs <product-container-name>
      ```

    !!! note "DevOps Aliases"
        Enter `dhelp` for a listing of the DevOps command aliases. See the [Docker Compose Command Line Reference](https://docs.docker.com/compose/reference/overview/) for the Docker Compose commands.

1. To view the running instance, log in to PingDirectory using the Ping Data Console:

      | Product | Connection Details |
    | --- | --- |
    | [PingDirectory](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: pingdirectory</li><li>Username: administrator</li><li>Password: 2FederateMore</li></ul> |

## Test Deployment

1. Verify that data is replicating between the pair by adding a description entry for the first container. First, exec into the container.

      ```sh
      docker container exec -it \
         02-replicated-pair_pingdirectory_1 \
         /opt/out/instance/bin/ldapmodify

      ...
      # Successfully connected to localhost:636
      ```

      Then copy and paste this entire block:

      ```sh
      dn: uid=user.0,ou=people,dc=example,dc=com
      changetype: modify
      replace: description
      description: Made this change on the first container.

      <Ctrl-D>
      ```

      > The blank line followed by the `<Ctrl-D>` is important. It's how entries are separated in the LDAP Data Interchange Format (LDIF).

1. Check that the second container in the pair now has a matching entry for the description. Enter:

      ```text
      docker container exec -it \
         02-replicated-pair_pingdirectory_2 \
         /opt/out/instance/bin/ldapsearch \
         -b uid=user.0,ou=people,dc=example,dc=com \
         -s base '(&)' description
      ```

      The result should show the description that you specified for the first container, similar to this:

      ```text
      # dn: uid=user.0,ou=people,dc=example,dc=com
      # description: Made this change on the first container.
      ```

## Clean Up

When you no longer want to run this stack, bring the stack down.

To remove all of the containers and associated Docker networks, enter:

```sh
docker-compose down
```

To stop the running stack without removing any of the containers or associated Docker networks, enter:

```sh
docker-compose stop
```

To remove attached Docker Volumes

```sh
docker volume prune
```
