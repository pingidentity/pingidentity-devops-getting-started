# Purpose
Demonstrate how to stand up a PingDataConsole container without any framework

## How to
See https://cloud.docker.com/repository/docker/pingidentity/pingdataconsole

```Bash
docker network create pingnet
docker run -d --network pingnet -p 8080:8080 --name pingdataconsole pingidentity/pingdataconsole
open http://localhost:8080/admin-console
```
