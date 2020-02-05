# Deploy a PingAccess cluster


This is an example of a PingAccess cluster

[docker-compose.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/06-pignacces-cluster/docker-compose.yaml)

## Getting started

Please refer to the [Docker Compose Overview](./) for details on how to start, stop, cleanup stacks.

## Background

This example uses the [pa-clustering](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pa-clustering) profile

This profile contains an H2 DB (instance/data/PingAccess.mv.db) which is configured to look for the PingAccess admin at `pingaccess:9090`. Remember to include this if/when creating your own profile as this setting is not contained in an exported PingAccess configuration archive. 

## Compose Commands

To start the stack, from this directory run:

`docker-compose up -d`

Watch the services initialize with:

`docker-compose logs -f`

To stand up multiple PingAccess engine nodes, run compose with the `--scale` argument:

`docker-compose up -d --scale pingaccess-engine=2`

## Checking cluster replication

Once you see that the containers are healthy in `docker ps`
You can check the engines were successfully added with: 
```
curl -k -u administrator:2FederateM0re -H 'X-XSRF-Header: PingAccess'  http
s://localhost:9000/pa-admin-api/v3/engines
```
Or via the PingAccess management console:

  1. Go to [https://localhost:9000](https://localhost:9999)
  2. Log in with `Administrator / 2FederateM0re`
  3. Then System>Clustering (choose discard changes if alert pops up)

## Cleaning up

To bring the stack down:

`docker-compose down`
