```
docker network create pingnet
docker run -d --network pingnet -p 8080:8080 --name pingdataconsole pingidentity/pingdataconsole
open https://localhost:8080/admin-console
```
## How to
To build the PingDataConsole Docker image
```
docker build -t [image_name] .
```

## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.