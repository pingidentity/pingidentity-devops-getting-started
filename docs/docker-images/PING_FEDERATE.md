An example Ping Identity PingFederate container, running in Alpine Linux using OpenJDK8.

## PingFederate License
Before running the PingFederate Docker image, you must obtain a PingFederate License. Please visit:

https://www.pingidentity.com/en/account/request-license-key.html

## Run
To run a PingFederate container: 

```shell
  docker run \
           --name pingfederate \
           --publish 9999:9999 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingfederate \
           --env SERVER_PROFILE_PARENT=LICENSE \
           --env SERVER_PROFILE_LICENSE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_LICENSE_PATH=licenses/pingfederate \
           pingidentity/pingfederate
```

Follow Docker logs with:

```
docker logs -f pingfederate
```

If using the command above with the embedded [server profile](../server-profiles/README.md), log in with: 
* https://localhost:9999/pingfederate/app
  * Username: Administrator
  * Password: 2FederateM0re


You can open a shell into the container with: 

```
docker container exec -it pingfederate sh
```

## Documentation
https://support.pingidentity.com/s/PingFederate-help

## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.