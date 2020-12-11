# Securing the Containers

By default, Ping Identity Docker Images run as root within the container. When deploying these images into your production environment, you may wish to secure them by using one of the following patterns which we describe below, in order of preference.

## Isolate Containers with a User Namespace

Linux namespaces provide isolation for running processes, limiting their access to system resources without the running process being aware of the limitations.

The best way to prevent privilege-escalation attacks from within a container is to configure your container’s applications to run as unprivileged users. For containers whose processes must run as the root user within the container, you can re-map this user to a less-privileged user on the Docker host.

Please view the Docker’s in-depth [Documentation](https://docs.docker.com/engine/security/userns-remap/) on this pattern for more information.

## Inside-Out Pattern

Using the inside-out pattern, the container steps down from root to run as a non-privileged user. You may pass the User ID (UID) and Group ID (GID) for the container to run as.

Overview of the bootstrap process:

* Start as root
* Immediately check if need to step down (PING_CONTAINER_PRIVILEGED=false)
* Create the group with provided group ID or 9999
* Create the user with provided user ID or 9031
* Strip ownership but for user:group
* Step-down from root to user

This pattern has the benefit of removing permissions from anything but the specified user.

Use the following environment variables to set the user and group and prevent from running as root

```shell
PING_CONTAINER_PRIVILEGED=false
PING_CONTAINER_UID=<UID> (Default: 9031)
PING_CONTAINER_GID=<GID> (Default: 9999)
```

Pros:

* This pattern is more secure
* Does not require infrastructure changes
* User/group exist within the container
* Recommended to be combined with namespace-Isolated containers

Cons:

* Implementation is vendor-specific and may require more introspection on the part of the deployer

## Outside-In Pattern (Kubernetes Security-Context)

Using the outside-in pattern, you will specify the user to run as via the Docker API (Docker Run, Compose, etc). This user will need to exist on the host machine if you wish to mount a volume from the host into the container and file ownership IDs need to agree.

Pros:

* Easy, visible (accessible with docker run --user)
* The container runtime is never root at any point

Cons:

* User does not have a home directory, some tools will or may have issues running properly or as expected
* For this pattern to work, at build time, we need to leave permissions open to the world since the user does not exist in /etc/password and inodes cannot be tied to it at runtime

## Ping Identity's Docker Image Hardening Guide

View Ping Identity's [Hardening Guide](https://support.pingidentity.com/s/article/Docker-Image-Hardening-Deployment-Guide) which outlines best practices for securing your product Docker Image.
