# Ping Identity DevOps - Getting Started
Provides foundational examples to get familarized with the various moving parts 
in the devops toolkit. Throughout this repository, we'll cover the basics of 
running PingFederate, PingDirectory, PingAccess and more in docker containers. 

## Contents

* 00-docker-standalone - Run Ping Identity standalone products in docker containers 
* 01-docker-compose    - Define and run multi-container Ping Identity docker images with Docker Compose
* 02-docker-stacks     - Deploy Ping Identity product stacks using Docker Swarm

## Bash profile docker helper aliases
Several aliases are available in the utility `bash_profile_docker` to perform common 
docker commands with containers, images, services, etc...  You can easily source this
from you bash startup file (i.e. .bash_profile) to make easy use of these alias.

## Docker images

* A complete listing of Ping Identity's public images used in these examples are available at [Docker Hub](https://hub.docker.com/u/pingidentity/)

## Troubleshooting
This repoistory is in active development and has not been offically released. 
If you experiece issues with this project, please feel free to log it by opening an issue.
