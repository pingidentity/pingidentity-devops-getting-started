---
title: Ping Identity DevOps Docker Image - `pingdelegator`
---

# Ping Identity Docker Image - `pingdelegator`

This docker image provides an NGINX instance with PingDelegator
that can be used in administering PingDirectory Users/Groups.

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
> This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)
- `pingidentity/pingcommon` - Common Ping files (i.e. hook scripts)


## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://devops.pingidentity.com/docker-images/pingbase/)**,
the following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| PING_PRODUCT_VERSION  | ${VERSION}  |  |
| PD_DELEGATOR_PUBLIC_HOSTNAME  | localhost  |  |
| PD_DELEGATOR_HTTP_PORT  | 6080  |  |
| PD_DELEGATOR_HTTPS_PORT  | 6443  |  |
| PF_ENGINE_PUBLIC_HOSTNAME  | localhost  | The hostname for the public Ping Federate instance used for SSO.  |
| PF_ENGINE_PUBLIC_PORT  | 9031  | The port for the public Ping Federate instance used for SSO. NOTE: If using port 443 along with a base URL with no specified port, set to an empty string.  |
| PF_DELEGATOR_CLIENTID  | dadmin  | The client id that was set up with Ping Federate for Ping Delegator.  |
| PD_ENGINE_PUBLIC_HOSTNAME  | localhost  | The hostname for the DS instance the app will be interfacing with.  |
| PD_ENGINE_PUBLIC_PORT  | 1443  | The HTTPS port for the DS instance the app will be interfacing with.  |
| PD_DELEGATOR_TIMEOUT_LENGTH_MINS  | 30  | The length of time (in minutes) until the session will require a new login attempt  |
| PD_DELEGATOR_HEADER_BAR_LOGO  |   | The filename used as the logo in the header bar, relative to this application's build directory. Note about logos: The size of the image will be scaled down to fit 22px of height and a max-width of 150px. For best results, it is advised to make the image close to this height and width ratio as well as to crop out any blank spacing around the logo to maximize its presentation. e.g. '${SERVER_ROOT_DIR}/html/delegator/images/my_company_logo.png'  |
| PD_DELEGATOR_DADMIN_API_NAMESPACE  |   | The namespace for the Delegated Admin API on the DS instance. In most cases, this does not need to be set here. e.g. 'dadmin/v2'  |
| PD_DELEGATOR_PROFILE_SCOPE_ENABLED  | false  | Set to true if the "profile" scope is supported for the Delegated Admin OIDC client on PingFederate and you wish to use it to show the current user's name in the navigation.  |
| NGINX_WORKER_PROCESSES  | auto  | The number of NginX worker processes -- Default: auto  |
| NGINX_WORKER_CONNECTIONS  | 1024  | The number of NginX worker connections -- Default: 1024  |
| STARTUP_COMMAND  | nginx  | The command that the entrypoint will execute in the foreground to instantiate the container  |
| STARTUP_FOREGROUND_OPTS  | -c ${SERVER_ROOT_DIR}/etc/nginx.conf  | The command-line options to provide to the the startup command when the container starts with the server in the foreground. This is the normal start flow for the container  |
| STARTUP_BACKGROUND_OPTS  | ${STARTUP_FOREGROUND_OPTS}  | The command-line options to provide to the the startup command when the container starts with the server in the background. This is the debug start flow for the container  |

## Run
To run a PingDelegator container with HTTPS_PORT=6443 (6443 is simply a convention for
PingDelegator so conflicts are reduced with other container HTTPS ports):

```shell
  docker run \
           --name pingdelegator \
           --publish 6443:6443 \
           --detach \
           --env PING_IDENTITY_ACCEPT_EULA=YES \
           --env PING_IDENTITY_DEVOPS_USER \
           --env PING_IDENTITY_DEVOPS_KEY \
           --tmpfs /run/secrets \
           pingidentity/pingdelegator:edge
```

PingDelegator requires running instances of PingFederate/PingDirectory.

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdelegator/hooks/README.md) for details on all pingdelegator hook scripts

---
This document is auto-generated from _[pingdelegator/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdelegator/Dockerfile)_

Copyright © 2023 Ping Identity Corporation. All rights reserved.
