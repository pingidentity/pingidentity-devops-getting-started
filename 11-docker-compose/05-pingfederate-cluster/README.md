# 05-pingfederate-cluster

This is an example of a PingFederate cluster

[docker-compose.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/05-pingfederate-cluster/docker-compose.yaml)

## Getting started

Please refer to the [Docker Compose Overview](./) for details on how to start, stop, cleanup stacks.

## Compose Commands

To start the stack, from this directory run:

`docker-compose up -d`

Watch the directories initialize with:

`docker-compose logs -f`

To stand up multiple PingFederate engine nodes, run compose with the `--scale` argument:

`docker-compose up -d --scale pingfederate=2`

## Verify
Once the admin is up, you can check cluster status via the console or with:
```shell
curl -u administrator:2FederateM0re -k 'https://localhost:9999/pf-admin-api/v1/cluster/status' \
--header 'x-xsrf-header: PingFederate'
```
You should see similar to:
```json
{"nodes":[{"address":"169.254.1.2:7600","mode":"CLUSTERED_CONSOLE","index":804046313,"nodeGroup":"","version":"10.0.0.15"},{"address":"169.254.1.3:7600","mode":"CLUSTERED_ENGINE","index":2142569058,"nodeGroup":"","version":"10.0.0.15","nodeTags":""}],"lastConfigUpdateTime":"2019-12-31T19:36:54.000Z","replicationRequired":true,"mixedMode":false}
```

## How it works

The compose file makes use of profile layering. 
The base profile layer ([pf-dns-ping-clustering](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pf-dns-ping-clustering)) provides two files relevant to PingFederate clustering.

Files in `pf-dns-ping-clustering/pingfederate`: 
```
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
**tcp.xml.subst** - This is where the magic happens. The file specifies usage of DNS_PING for clustering and expects a variable, `DNS_QUERY_LOCATION` to be passed. 

**run.properties.subst** - This file is used to tell the PF container which `OPERATIONAL_MODE` it is in. Hence `CLUSTERED_CONSOLE` or `CLUSTERED_ENGINE` should be passed to `OPERATIONAL_MODE` as environment variables. 


## Using the containers

Once you see that the containers are healthy in `docker ps`

To see the PingFederate management console

* Go to [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)
* Log in with `Administrator / 2FederateM0re`

## Cleaning up

To bring the stack down:

`docker-compose down`

