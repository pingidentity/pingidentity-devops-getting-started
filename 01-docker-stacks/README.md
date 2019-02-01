# Purpose
This directory contains some examples that automate the manual steps taken in the Docker standalone directories

## How to
Note: ensure you have started docker swarm before deploying the stack by running `docker swarm init`

Run the `start-stack.sh` script and pass a stack yaml file

For example, `./start-stack.sh fullstack.yaml`

When done with the stack, run `./cleanup-stack.sh [stack name]` to clean up your environment.

## Yaml Files
* `basic1.yaml` - Deploy PingDirectory in a stack
* `basic2.yaml` - Deploy PingDirectory in a stack with mounted in/out volumes
* `basic3.yaml` - Deploy PingDirectory in a stack with extenal mounted volumes
* `fullstack.yaml` - Deploy PingFederate, PingDirectory, PingDataConsole and PingAccess in a networked stack
* `simplest-sync.yaml` - Deploy PingDirectory, PingDataSync and PingDataConsole in a networked stack

