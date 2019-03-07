# Purpose
This folder is intended to demonstrate how to use Docker Compose to assemble several images, each with their own role, into a functioning deployed set of containers. Docker Compose can be useful for local development as it does not require an external orchestrator such as Docker Swarm or Kubernetes. Unlike with Swarm or Kubernetes, Compose deploys containers locally, not on remote machines.

## 01-simple-stack
A simple stack with a PingFederate container and a PingDirectory container

## 02-replicated-pair
An example of a replicated pair of PingDirectory instances

## 03-full-stack
A stack with PingDirectory, PingFederate, PingAccess, PingDataConsole. 
>Also note the multiple networks to represent where each would be deployed.

## 04-simple-sync
Showing PingDataSync in action connected to a PingDirectory container.
