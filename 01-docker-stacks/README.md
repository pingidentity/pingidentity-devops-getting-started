# Purpose
This directory contains some examples that automate the manual steps taken in the Docker standalone directories

## How to
Note: ensure you have started docker swarm before deploying the stack by running `docker swarm init`

Run the `start-stack.sh` script and pass a stack yaml file

For example, `./start-stack.sh fullstack.yaml`
When done with the stack, run `./cleanup-stack.sh [stack name]` to clean up your environment.
