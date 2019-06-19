# ldap-sdk-tools

This docker image provides an apine image with the LDAP Client SDK tools to be used against other PingDirectory instances.

## Related Docker Images

* `pingidentity/pingdownloader` - Image used to download ping product
* `openjdk:8-jre8-alpine` - Alpine server to run LDAP SDK Tools from

## Environment Variables

The following environment `ENV` variables can be used with this image.

| ENV Variable | Default | Description |
| ---: | :--- | :--- |
| PATH | /opt/tools:${PATH} |  |

## List all available tools

`docker run -it --rm pingidentity/ldap-sdk-tools ls`

## Use LDAPSearch

### Get some help

`docker run -it --rm pingidentity/ldap-sdk-tools ldapsearch --help`

### Simple search

```bash
docker run -it --rm pingidentity/ldap-sdk-tools \
    ldapsearch \
        -b dc=example,dc=com \
        -p 1389 "(objectClass=*)"
```

### Save output to host file

```bash
docker run -it --rm \
    -v /tmp:/opt/out \
    pingidentity/ldap-sdk-tools \
    ldapsearch \
        --baseDN dc=example,dc=com \
        --port 1389 \
        --outputFormat json "(objectClass=*)" >/tmp/search-result.json
```

## Use manage-certificates

### trusting certificates

```bash
PWD=2FederateM0re
mkdir -p /tmp/hibp
docker run -it --rm \
  -v /tmp/hibp:/opt/out \
  pingidentity/ldap-sdk-tools \
  manage-certificates trust-server-certificate \
    --hostname haveibeenpwned.com \
    --port 443 \
    --keystore /opt/out/hibp-2019.jks \
    --keystore-password ${PWD}
ls -all /tmp/hibp
keytool -list \
  -keystore /tmp/hibp/hibp-2019.jks \
  -storepass ${PWD}
```

## Docker Container Hook Scripts

Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/ldap-sdk-tools/hooks/README.md) for details on all ldap-sdk-tools hook scripts

This document auto-generated from [_ldap-sdk-tools/Dockerfile_](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/ldap-sdk-tools/Dockerfile)

Copyright \(c\) 2019 Ping Identity Corporation. All rights reserved.

