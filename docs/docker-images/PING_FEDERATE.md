An example Ping Identity PingFederate container, running in Alpine Linux using OpenJDK8.

## PingFederate License
Before running the PingFederate Docker image, you must obtain a PingFederate License. Please visit:

https://www.pingidentity.com/en/account/request-license-key.html

Upon receiving your license file, run the ```docker run``` command, substituting the license filename with the file that you've saved the license to.

## How to
To build the PingFederate Docker image
```
docker build -t [image_name] .
```

## Documentation
https://support.pingidentity.com/s/PingFederate-help

## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.