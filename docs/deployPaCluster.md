# Deploy a PingAccess cluster

This use case employs the `pingidentity-server-profiles/pa-clustering` server profile. This server profile contains an H2 database engine located in `pingidentity-server-profiles/pa-clustering/pingaccess/instance/data/PingAccess.mv.db`. H2 is configured to reference the PingAccess Admin engine at `pingaccess:9090`. 

> Remember to include this if you create your own server profile. This setting is not contained in an exported PingAccess configuration archive. 

## Prerequisites

* You've already been through [Getting Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Clone the [`pingidentity-server-profiles`](../../pingidentity-server-profiles) repository to your local `${HOME}/projects/devops` directory.

## What you'll do

* Deploy the PingAccess cluster.
<!-- * Verify the cluster status. -->
* Replicate the cluster configuration.
* Scale the PingAccess engines.

## Deploy the PingAccess cluster

You'll use the `docker-compose.yaml` file in your local `pingidentity-devops-getting-started/11-docker-compose/06-pingaccess-cluster` directory to deploy the cluster.

1. From the `pingidentity-devops-getting-started/11-docker-compose/06-pingaccess-cluster` directory, start the stack. Enter:

   ```bash
   docker-compose up -d
   ```

2. Check that the containers are healthy and running:

   ```bash
   docker-compose ps
   ```

   You can also display the startup logs:

   ```bash
   docker-compose logs -f
   ```

   To see the logs for a particular product container at any point, enter:

   ```bash
   docker-compose logs <product-container-name>
   ```

3. Log in to the PingAccess administrator console:

   - Console URL: https://localhost:9000
   - User: Administrator
   - Password: 2FederateM0re

## Replicate the cluster configuration

Replicate configuration across the cluster using the either the PingAccess administrator console or the PingAccess Admin REST API:

* To use the administrator console:

  1. Log in to the administrator console: `https://localhost:9000`.
  2. Go to System --> Clustering. 
     
     > If an alert is displayed, choose to discard changes.

* To use the PingAccess Admin REST API, enter:

  ```bash
  curl -k -u administrator:2FederateM0re -H 'X-XSRF-Header: PingAccess' https://localhost:9000/pa-admin-api/v3/engines
  ```

  The resulting response will be similar to this:

  ```json
  {"resultId":"success","message":"Operation succeeded."}
  ```

## Scale the PingAccess engines

1. If the cluster is running, bring the cluster down:

   ```bash
   docker-compose down
   ```

2. Start up multiple PingAccess engine nodes by running `docker-compose` with the `--scale` argument. For example, to scale up to 2 engine nodes:

   ```bash
   docker-compose up -d --scale pingaccess-engine=2
   ```

## Finishing

When you no longer want to run the cluster, you can either stop the running stack, or bring the stack down.

 To stop the running stack without removing any of the containers or associated Docker networks, enter:

 ```bash
 docker-compose stop
 ```

 To remove all of the containers and associated Docker networks, enter:

 ```bash
 docker-compose down
 ```
