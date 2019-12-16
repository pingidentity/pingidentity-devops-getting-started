# Data synchronization for PingDirectory using Docker Compose

## To deploy PingDirectory using PingDataSync and Docker Compose:

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/04-simple-sync` directory (where the `docker-compose.yaml` file for the PingDirectory and PingDataSync example is located). Enter:

  `docker-compose up --detach`

  The containers for PingDirectory and PingDataSync will start up.

2. Check that PingDirectory and PingDataSync are healthy and running:

  `docker-compose ps`

  See [Docker Compose](../11-docker-compose) for help using Docker Compose.

<!-- 3. Verify that data is replicating between the pair by adding a description entry for the first container. Enter:

  ```text
  docker container exec -it 02-replicated-pair_pingdirectory_1 /opt/out/instance/bin/ldapmodify
  dn: uid=user.0,ou=people,dc=example,dc=com
  changetype: modify
  replace: description
  description: Made this change on the first container.

  <Ctrl-D>
  ```

  > The blank line followed by the `<Ctrl-D>` is important. It's how entries are separated in the LDAP Data Interchange Format (LDIF).

  Check that the second container in the pair now has a matching entry for the description. Enter:

  ```text
  docker container exec -it 02-replicated-pair_pingdirectory_2 /opt/out/instance/bin/ldapsearch -b uid=user.0,ou=people,dc=example,dc=com -s base '(&)' description
  ```
  The result should show the description that you specified for the first container, similar to this:

  ```text
  # dn: uid=user.0,ou=people,dc=example,dc=com
  # description: Made this change on the first container.
  ``` -->

4. When you no longer want to run this replicated pair stack, you can either stop the running stack, or bring the stack down. Enter either:

  `docker-compose stop` or `docker-compose down`
