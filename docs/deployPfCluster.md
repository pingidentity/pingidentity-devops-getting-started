# Deploy a PingFederate cluster

This use case employs server profile layering, using the PingFederate server profile in `pingidentity-server-profiles/pf-dns-ping-clustering/pingfederate` directory as the base layer profile. This server profile contains two files critical to PingFederate clustering:

* `tcp.xml.subst` 

  Specifies usage of DNS_PING for clustering and expects the environment variable, `DNS_QUERY_LOCATION` to be passed. 

* `run.properties.subst` 

  Indicates to the PingFederate container which `OPERATIONAL_MODE` the container is to be used. The environment variables `CLUSTERED_CONSOLE` or `CLUSTERED_ENGINE` need to be passed. 

The file structure for these files in `pingidentity-server-profiles/pf-dns-ping-clustering/pingfederate` looks like this:
 
```text
.
└── pingfederate
    └── instance
        ├── bin
        │   └── run.properties.subst
        └── server
            └── default
                └── conf
                    └── tcp.xml.subst
```

The top profile layer uses the server profile in `pingidentity-server-profiles/getting-started/pingfederate`.

See [Layering server profiles](docs/profilesLayered.md) for more information about using server profiles.

## Prerequisites

* You've already been through [Getting Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* PingFederate build image for version 10 or greater. (The DNS Discovery feature first available in version 10 is needed.)

## What you'll do

* Deploy the PingFederate cluster.
* Verify the cluster status.
* Replicate the cluster configuration.
* Scale the PingFederate engines.

## Deploy the PingFederate cluster

You'll use the `docker-compose.yaml` file in your local `pingidentity-devops-getting-started/11-docker-compose/05-pingfederate-cluster` directory to deploy the cluster.

1. From the `pingidentity-devops-getting-started/11-docker-compose/05-pingfederate-cluster` directory, start the stack. Enter:

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

3. Log in to the PingFederate administrator console:

   - Console URL: https://localhost:9999/pingfederate/app
   - User: Administrator
   - Password: 2FederateM0re

## Verify the cluster status

Check the status of the cluster using either or the PingFederate Admin REST API:

* To use the administrator console:

  1. Log in to the administrator console: `https://localhost:9999/pingfederate/app`.
  2. Go to System --> Cluster Management and click `Cluster Status`.

* To use the PingFederate Admin REST API, enter:

  ```bash
  curl -u administrator:2FederateM0re -k 'https://localhost:9999/pf-admin-api/v1/cluster/status' \
  --header 'x-xsrf-header: PingFederate'
  ```

  The resulting response will be similar to this:

  ```json
  {"nodes":[{"address":"169.254.1.2:7600","mode":"CLUSTERED_CONSOLE","index":804046313,"nodeGroup":"","version":"10.0.0.15"},{"address":"169.254.1.3:7600","mode":"CLUSTERED_ENGINE","index":2142569058,"nodeGroup":"","version":"10.0.0.15","nodeTags":""}],"lastConfigUpdateTime":"2019-12-31T19:36:54.000Z","replicationRequired":true,"mixedMode":false}
  ```

## Replicate the cluster configuration

Replicate configuration across the cluster using the either the PingFederate administrator console or the PingFederate Admin REST API:

* To use the administrator console:

  1. Log in to the administrator console: `https://localhost:9999/pingfederate/app`.
  2. Go to System --> Cluster Management and click `Replicate Configuration`.

* To use the PingFederate Admin REST API, enter:

  ```bash
  curl -X POST -u administrator:2FederateM0re -k 'https://localhost:9999/pf-admin-api/v1/cluster/replicate' \
  --header 'x-xsrf-header: PingFederate'
  ```

  The resulting response will be similar to this:

  ```json
  {"resultId":"success","message":"Operation succeeded."}
  ```

## Scale the PingFederate engines

1. If the cluster is running, bring the cluster down:

   ```bash
   docker-compose down
   ```

2. Start up multiple PingFederate engine nodes by running `docker-compose` with the `--scale` argument. For example, to scale up to 2 engine nodes:

   ```bash
   docker-compose up -d --scale pingfederate=2
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
