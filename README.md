# Ping Identity DevOps
This repository provides foundational examples to try different configurations and deployments of the Ping Identity solutions using the DevOps images and toolkit.

## Documentation
 * The complete collection of documentation for Ping Identity solutions for DevOps is located on [Gitbook](https://pingidentity-devops.gitbook.io/devops/).
 * You can also go to [Ping Identity's DevOps page](https://www.pingidentity.com/content/developer/en/devops.html) for additional resources.

## Contents

* [10-docker-standalone](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/10-docker-standalone)

  Run Ping Identity standalone products in Docker containers.

* [11-docker-compose](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose)

  Define and run multi-container Ping Identity Docker images with Docker Compose.

* [12-docker-swarm](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/12-docker-swarm)         -

  Deploy Ping Identity product stacks using Docker Swarm.
  
* [20-kubernetes](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/20-kubernetes)

  Deploy PingDirectory in Kubernetes.

### ldapsdk tool
Use the `ldapsdk` tool in the top level directory to startup an `ldap-sdk-tools` container
allowing for easy access to the LDAP SDK Tools (such as ldapsearch, ldapmodify, and other tools).

Running `ldapsdk` the first time will help configure your settings.  After that, you
simply run.  To edit the settings in the future, use the configure option:
`ldapsdk configure`.

### Bash profile Docker helper aliases
Several aliases are available in the utility `bash_profile_devops` to perform common
Docker commands with containers, images, services, and so on.  You can easily source this
from your bash startup file (i.e. .bash_profile) to make easy use of these alias.

### Docker images

* A complete listing of the Ping Identity solutions public images used in these examples is available at [Docker Hub](https://hub.docker.com/u/pingidentity/).

## Security Warning

The server profiles referenced within this repository are for evaluation and documentation purposes only. They contain default credentials that would be a substantial security risk in a production environment.

For additional information, please see [SECURITY.md](SECURITY.md)

## Troubleshooting
This repository is in active development and has not been officially released.
If you experience issues with this project, see [Troubleshooting](docs/troubleshooting/BASIC_TROUBLESHOOTING.md).
