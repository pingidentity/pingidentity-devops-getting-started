# A PingFederate and PingDirectory stack using Docker Compose

## To deploy a PingFederate and PingDirectory stack using Docker Compose:

1. Go to your local `devops/pingidentity-devops-getting-started/11-docker-compose/01-simple-stack` directory (where the `docker-compose.yaml` file for the PingFederate and PingDirectory stack is located). To start the stack, enter:

  `docker-compose up -d`

2. Check that the solution pair is healthy and running:

  `docker-compose ps`

  See [Docker Compose](../11-docker-compose) for help using Docker Compose.

3. Log in to the management console for the solution:

* PingDataConsole for PingDirectory
      Console URL: https://localhost:8443/console
      Server: pingdirectory
      User: Administrator
      Password: 2FederateM0re

* PingFederate
      Console URL: https://localhost:9999/pingfederate/app
      User: Administrator
      Password: 2FederateM0re

4. When you no longer want to run this PingFederate and PingDirectory stack, you can either stop the running stack, or bring the stack down. Enter either:

  `docker-compose stop` or `docker-compose down`
