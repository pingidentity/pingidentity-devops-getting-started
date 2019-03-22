# Docker Swarm
This directory contains examples that automate the manual steps taken in the Docker standalone directories.

## Example Docker Swarm Stack Deployment Files
Included are the following stack deployment yaml files that can be used in a
`docker stack deploy -c stack.yaml stack-name`

* basic1.yaml        - Deploy PingDirectory in a stack with mounted out volume
* basic2.yaml        - Deploy PingDirectory in a stack with mounted in/out volumes
* basic3.yaml        - Deploy PingDirectory in a stack with externally mounted volumes
* fullstack.yaml     - Deploy PingFederate, PingDirectory, PingDataConsole and PingAccess in a networked stack
* simple-sync.yaml   - Deploy PingDirectory, PingDataSync and PingDataConsole in a networked stack

## HowTo
Ensure that you have started Docker Swarm before deploying the stack by running:

`docker swarm init`

There are two shell scripts that can be used to start and cleanup the example swarms.

### swarm-start.sh
Used to start the stack in Docker Swarm environment.

```
Usage: swarm-start.sh <stack-name>.yaml

Example:

   swarm-start.sh basic1.yaml
```

### swarm-cleanup.sh
Used to cleanup the Docker stack in Docker Swarm environment.

```
Usage: swarm-cleanup.sh <stack-name>.yaml

Example:

   swarm-cleanup.sh basic1.yaml
```

## Console Application
If you are using the PingDataConsole container from these swarm images, you should be able to login with

http://localhost:8080/admin-console/

### PingDirectory
```
     Server: pingdirectory:636
   Username: administrator
   Password: 2FederateM0re
```

### PingDirectorySync
```
     Server: pingdirectorysync:636
   Username: administrator
   Password: 2FederateM0re
```
