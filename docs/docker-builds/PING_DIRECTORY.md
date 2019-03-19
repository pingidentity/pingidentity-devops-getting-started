An example Ping Identity PingDirectory container, running in Alpine Linux using OpenJDK8, loaded up with a few sample users.

## PingDirectory License
Before running the PingDirectory Docker image, you must obtain a Ping Directory License.  Please visit:

   https://www.pingidentity.com/en/account/request-license-key.html

Upon receiving your license file, run the ```docker run``` command, substituting the license filename with the file that you've saved the license to.

## How to
To build the PingDirectory Docker image
```
docker build .
```

## Documentation
https://support.pingidentity.com/s/pingdirectory-help

## Running a PingDirectory container

```
  docker run \
           --name pingdirectory \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/server-profile-pingidentity-getting-started.git \
           --env SERVER_PROFILE_PATH=pingdirectory \
           pingidentity/pingdirectory
```
After approximately 30 seconds, the new license will be added and the service will be started.  If no license is provided, or an invalid or expired license is provided, the Docker container will exit.  You can view the Docker logs with the command:

```
  docker logs -f pingdirectory
```

To stop the container

```
  docker container stop pingdirectory
```

## Run a sample 100/sec search rate test

```
docker exec -it pingdirectory \
        /opt/out/instance/bin/searchrate \
                -b dc=example,dc=com \
                --scope sub \
                --filter "(uid=user.[1-9])" \
                --attribute mail \
                --numThreads 2 \
                --ratePerSecond 100
```

## LDAP Client
Connect an LDAP Client (such as Apache Directory Studio) to this container:

* LDAP Port: 1389 (mapped to 1389)
* HTTPS Port: 8443 (mapped to 8443)
* LDAP Base DN: dc=example,dc=com
* Root Username: cn=administrator
* Root Password: 2FederateM0re

## REST/SCIM Access to Directory
From Postman or a browser.

* URL: https://localhost:8443/scim/Users
  * Username: cn=administrator
  * Password: 2PingDirectory

## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details.

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.