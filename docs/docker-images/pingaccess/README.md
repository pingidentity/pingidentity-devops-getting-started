
# Ping Identity DevOps Docker Image - `pingaccess`

This docker image includes the Ping Identity PingAccess product binaries
and associated hook scripts to create and run both PingAccess Admin and
Engine nodes. 

## Related Docker Images
- `pingidentity/pingbase` - Parent Image
	>**This image inherits, and can use, Environment Variables from [pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**
- `pingidentity/pingcommon` - Common Ping files (i.e. hook scripts)
- `pingidentity/pingdownloader` - Used to download product bits

## Ports Exposed
The following ports are exposed from the container.  If a variable is
used, then it may come from a parent container
- 9000
- 3000
- ${HTTPS_PORT}

## Environment Variables
In addition to environment variables inherited from **[pingidentity/pingbase](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase)**,
the following environment `ENV` variables can be used with 
this image. 

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| PING_PRODUCT  | PingAccess  | 
| LICENSE_DIR  | ${SERVER_ROOT_DIR}/conf  | 
| LICENSE_FILE_NAME  | pingaccess.lic  | 
| LICENSE_SHORT_NAME  | PA  | 
| LICENSE_VERSION  | 5.2  | 
| STARTUP_COMMAND  | ${SERVER_ROOT_DIR}/bin/run.sh  | 
| TAIL_LOG_FILES  | ${SERVER_ROOT_DIR}/log/pingaccess.log  | 
## Running a PingDirectory container
To run a PingAccess container: 

```shell
  docker run \
           --name pingaccess \
           --publish 9000:9000 \
           --publish 443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingaccess \
           pingidentity/pingaccess:edge
```


Follow Docker logs with:

```
docker logs -f pingaccess
```

If using the command above with the embedded [server profile](../server-profiles/README.md), log in with: 
* https://localhost:9000
  * Username: Administrator
  * Password: 2Access
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingaccess/hooks/README.md) for details on all pingaccess hook scripts

---
This document auto-generated from _[pingaccess/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingaccess/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
