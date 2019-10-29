# 05-pingfederate-cluster

This is an example of a PingFederate cluster

## Getting started

Please refer to the [Docker Compose Overview](./) for details on how to start, stop, cleanup stacks.

## Prerequite

This example uses AWS S3 for PingFederate node discovery and requires you to provide the bucket name, key and secret within the docker-compose.yaml file. For additional information regarding AWS S3 setup, please review this [document](https://pingidentity-devops.gitbook.io/devops/examples/12-docker-swarm/pingfederate-clustering-with-s3#aws-s3-bucket-creation-and-permissions)

## Compose Commands

To start the stack, from this directory run:

`docker-compose up -d`

Watch the directories initialize with:

`docker-compose logs -f`

To stand up multiple PingFederate engine nodes, run compose with the `--scale` argument:

`docker-compose up -d --scale --pingfederate=2`

## Using the containers

Once you see that the containers are healthy in `docker ps`

To see the PingFederate management console

* Go to [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)
* Log in with `Administrator / 2FederateM0re`

## Cleaning up

To bring the stack down:

`docker-compose down`

