# Docker Stacks
This directory contains some examples that automate the manual steps taken in the Docker standalone directories

## Example Docke Stack Deployment Yaml Files
Included are the following stack deployment yaml files that can be used in a
`docker stack deploy -c stack.yaml stack-name`

* basic1.yaml        - Deploy PingDirectory in a stack with mounted out volume
* basic2.yaml        - Deploy PingDirectory in a stack with mounted in/out volumes
* basic3.yaml        - Deploy PingDirectory in a stack with extenally mounted volumes
* fullstack.yaml     - Deploy PingFederate, PingDirectory, PingDataConsole and PingAccess in a networked stack
* simplest-sync.yaml - Deploy PingDirectory, PingDataSync and PingDataConsole in a networked stack

## HowTo
Ensure that you have started docker swarm before deploying the stack by running:

`docker swarm init`

There are a 2 shell scripts that can be used to start and cleanup the example stacks.

### stack-start.sh
Used to start the docker stack in docker swarm environment.

```
Usage: stack-start.sh <stack-name>.yaml

Example:

   stack-start.sh basic1.yaml
```

### stack-cleanup.sh
Used to cleanup the docker stack in docker swarm environment.

```
Usage: stack-cleanup.sh <stack-name>.yaml

Example:

   stack-cleanup.sh basic1.yaml
```
