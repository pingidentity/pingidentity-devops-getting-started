# 10-pingdataconsole

Demonstrate how to stand up a Ping Data Console container that can talk to other PingData components \(i.e. PingDirectory, PingDataAccess\)

## How to startup a Ping Data Console container...

### Using docker run

The following example will create a docker network, run the Ping Data Console and open up a webpage to the conosole.

```bash
docker network create pingnet

docker run -d \
       --network pingnet \
       --publish 8443:8443 \
       --name pingdataconsole \
       pingidentity/pingdataconsole

open https://localhost:8443/console
```

If you are using the PingDirectory container from these standalone images, you can login with the following credentials

```text
     Server: pingdirectory
   Username: administrator
   Password: 2FederateM0re
```

