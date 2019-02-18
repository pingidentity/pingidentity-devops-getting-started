# Purpose
This folder is intended to demonstrate how docker compose can be used to assemble several images, each with their own role, into a functioning deployed set of containers. Docker compose can be useful for local development as it does not require an external orchestrator such as docker swarm or kubernetes.
Unlike with swarm or kubernetes, compose simply deploys containers locally, not on remote machines.

## 01-simple-stack
A simple stack with a PingFederate container and a PingDirectory container

## 02-replicated-pair
An example of a replicated pair of PingDirectory instances
