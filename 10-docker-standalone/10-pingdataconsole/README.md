# Purpose
Demonstrate how to stand up a PingDataConsole container without any framework

## How to
See https://hub.docker.com/r/pingidentity/pingdataconsole

```Bash
docker network create pingnet

docker run -d \
       --network pingnet \
       --publish 8080:8080 \
       --name pingdataconsole \
       pingidentity/pingdataconsole
       
open http://localhost:8080/admin-console
```

If you are using the PingDirectory container from these standalone images, you should be able to login with

```
     Server: localhost:636
   Username: administrator
   Password: 2FederateM0re
```