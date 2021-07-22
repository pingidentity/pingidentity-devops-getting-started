---
title: Deploy PingFederate Cluster
---
# Deploying PingFederate Cluster

This use case employs server profile layering, using the PingFederate server profile in `pingidentity-server-profiles/pf-dns-ping-clustering/pingfederate` directory as the base layer profile. This server profile contains two files critical to PingFederate clustering:

* `tcp.xml.subst`

  Specifies usage of DNS_PING for clustering and expects the environment variable, `DNS_QUERY_LOCATION`, to be passed.

* `run.properties.subst`

  Indicates to the PingFederate container which `OPERATIONAL_MODE` is to be used. The environment variables `CLUSTERED_CONSOLE` or `CLUSTERED_ENGINE` need to be passed.

The following is the file structure for these files in `pingidentity-server-profiles/pf-dns-ping-clustering/pingfederate`:

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

For more information about using server profiles, see [Layering Server Profiles](../how-to/profilesLayered.md).

## Before you begin

You must:

* Complete [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Have PingFederate build image for version 10 or later. (The DNS Discovery feature first available in version 10 is needed.)

## About this task

You will:

* Deploy the PingFederate cluster.
* Verify the cluster status.
* Replicate the cluster configuration.
* Scale the PingFederate engines.

## Deploying the PingFederate cluster

Use the `docker-compose.yaml` file in your local `pingidentity-devops-getting-started/11-docker-compose/05-pingfederate-cluster` directory to deploy the cluster.

1. From the `pingidentity-devops-getting-started/11-docker-compose/05-pingfederate-cluster` directory, start the stack by entering:

      ```sh
      docker-compose up -d
      ```

1. To check that the containers are healthy and running, enter:

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

1. Sign on to the PingFederate Administrator Console:

    | Product | Connection Details |
    | --- | --- |
    | [PingFederate](https://localhost:9999/pingfederate/app) | <ul> <li>URL: [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |

## Verifying cluster status

Check the status of the cluster using either the PingFederate Administrator Console or the PingFederate Admin REST API:

* To use the Administrator Console:

  1. Sign on to the Administrator Console: `https://localhost:9999/pingfederate/app`.
  1. Go to System --> Cluster Management and click `Cluster Status`.

* To use the PingFederate Admin REST API, enter:

  ```sh
  curl -u administrator:2FederateM0re \
    -k 'https://localhost:9999/pf-admin-api/v1/cluster/status' \
    --header 'x-xsrf-header: PingFederate'
  ```

  The resulting response resembles the following:

  ```json
  {
   "nodes":[
      {
         "address":"169.254.1.2:7600",
         "mode":"CLUSTERED_CONSOLE",
         "index":804046313,
         "nodeGroup":"",
         "version":"10.0.0.15"
      },
      {
         "address":"169.254.1.3:7600",
         "mode":"CLUSTERED_ENGINE",
         "index":2142569058,
         "nodeGroup":"",
         "version":"10.0.0.15",
         "nodeTags":""
      }
   ],
   "lastConfigUpdateTime":"2020-12-31T19:36:54.000Z",
   "replicationRequired":true,
   "mixedMode":false
  }
  ```

## Replicating the configuration

Replicate the configuration across the cluster using the either the PingFederate Administrator Console or the PingFederate Admin REST API:

* To use the Administrator Console:

    1. Sign on to the Administrator Console: `https://localhost:9999/pingfederate/app`.
    1. Go to System --> Cluster Management and click `Replicate Configuration`.

* To use the PingFederate Admin REST API, enter:

  ```sh
  curl -X POST \
    -u administrator:2FederateM0re \
    -k 'https://localhost:9999/pf-admin-api/v1/cluster/replicate' \
    --header 'x-xsrf-header: PingFederate'
  ```

  The resulting response resembles the following:

  ```json
  {"resultId":"success","message":"Operation succeeded."}
  ```

## Scaling engines

To scale up to two engine nodes:

```sh
docker-compose up -d --scale pingfederate=2
```

## Cleaning up

When you no longer want to run this stack, bring the stack down.

* To remove all of the containers and associated Docker networks, enter:

   ```sh
   docker-compose down
   ```

* To stop the running stack without removing any of the containers or associated Docker networks, enter:

   ```sh
   docker-compose stop
   ```

* To remove attached Docker Volumes

   ```sh
   docker volume prune
   ```
