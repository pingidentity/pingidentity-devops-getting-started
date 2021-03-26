
# Ping Identity Docker Image - `ldap-sdk-tools`

This docker image provides an apine image with the LDAP Client
SDK tools to be used against other PingDirectory instances.

## Related Docker Images
- `pingidentity/pingdownloader` - Image used to download ping product
- `openjdk:8-jre8-alpine` - Alpine server to run LDAP SDK Tools from

## Environment Variables
The following environment `ENV` variables can be used with
this image.

| ENV Variable  | Default     | Description
| ------------: | ----------- | ---------------------------------
| SHIM  | ${SHIM}  |  |
| IMAGE_VERSION  | ${IMAGE_VERSION}  |  |
| IMAGE_GIT_REV  | ${IMAGE_GIT_REV}  |  |
| PATH  | /opt/tools:${PATH}  |  |
## List all available tools
`docker run -it --rm pingidentity/ldap-sdk-tools:edge ls`

## Use LDAPSearch
### Get some help
`docker run -it --rm pingidentity/ldap-sdk-tools:edge ldapsearch --help`

### Simple search
```Bash
docker run -it --rm pingidentity/ldap-sdk-tools:edge \
    ldapsearch \
        -b dc=example,dc=com \
        -p 1389 "(objectClass=*)"
```

### Save output to host file
```Bash
docker run -it --rm \
    -v /tmp:/opt/out \
    pingidentity/ldap-sdk-tools:edge \
    ldapsearch \
        --baseDN dc=example,dc=com \
        --port 1389 \
        --outputFormat json "(objectClass=*)" >/tmp/search-result.json
```

## Use manage-certificates
### trusting certificates
```Bash
PWD=2FederateM0re
mkdir -p /tmp/hibp
docker run -it --rm \
  -v /tmp/hibp:/opt/out \
  pingidentity/ldap-sdk-tools:edge \
  manage-certificates trust-server-certificate \
    --hostname haveibeenpwned.com \
    --port 1443 \
    --keystore /opt/out/hibp-2019.jks \
    --keystore-password ${PWD}
ls -all /tmp/hibp
keytool -list \
  -keystore /tmp/hibp/hibp-2019.jks \
  -storepass ${PWD}
```

## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/ldap-sdk-tools/hooks/README.md) for details on all ldap-sdk-tools hook scripts

---
This document is auto-generated from _[ldap-sdk-tools/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/ldap-sdk-tools/Dockerfile)_

Copyright © 2021 Ping Identity Corporation. All rights reserved.
