## PingDataConsole License
Before running the PingDataConsole Docker image, you must obtain a PingDataConsole License. Please visit:

https://www.pingidentity.com/en/account/request-license-key.html

## Run
To run a PingDataConsole container: 

```shell
  docker run \
           --name pingdataconsole \
           --publish 8080:8080 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/server-profile-pingidentity-getting-started.git \
           --env SERVER_PROFILE_PATH=pingdataconsole \
           pingidentity/pingdataconsole
```


Follow Docker logs with:

```
docker logs -f pingdataconsole
```

If using the command above with the embedded [server profile](../server-profiles/README.md), log in with: 
* http://localhost:8080/admin-console/login
```
Server: localhost:636
Username: administrator
Password: 2FederateM0re
```
>make sure you have a PingDirectory running

You can open a shell into the container with: 

```
docker container exec -it pingdataconsole sh
```

## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.