An example Ping Identity PingDataSync container, running in Alpine Linux using OpenJDK8.

## PingDirectory License
Before running the PingDirectory Docker image, you must obtain a PingDirectory License.  Please visit:

   https://www.pingidentity.com/en/account/request-license-key.html

Upon receiving your license file, run the ```docker run``` command, substituting the license filename with the file that you've saved the license to.

## How to
To run the PingDataSync Docker image
```
  docker run \
           --name pingdatasync \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=simple-sync/pingdatasync \
           --env SERVER_PROFILE_PARENT=LICENSE \
           --env SERVER_PROFILE_LICENSE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_LICENSE_PATH=licenses/pingdirectory \
           pingidentity/pingdatasync
```

## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details.

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.
