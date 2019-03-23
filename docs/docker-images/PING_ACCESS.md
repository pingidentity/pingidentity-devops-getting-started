## Purpose
This delivers PingAccess anywhere you need to protect resources.

## PingAccess License
Before running the PingAccess Docker image, you must obtain a PingAccess License. Please visit:

https://www.pingidentity.com/en/account/request-license-key.html

## Run
To run a PingAccess container: 

```shell
  docker run \
           --name pingaccess \
           --publish 9000:9000 \
           --publish 443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/server-profile-pingidentity-getting-started.git \
           --env SERVER_PROFILE_PATH=pingaccess \
           pingidentity/pingaccess
```


Follow Docker logs with:

```
docker logs -f pingaccess
```

If using the command above with the embedded [server profile](../server-profiles/README.md), log in with: 
* https://localhost:9000
  * Username: Administrator
  * Passowrd: 2FederateM0re


You can open a shell into the container with: 

```
docker container exec -it pingfederate sh
```


## Documentation
https://support.pingidentity.com/s/pingaccess-help

## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details.

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.