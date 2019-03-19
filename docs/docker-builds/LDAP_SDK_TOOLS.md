## List all available tools
`docker run -it --rm pingidentity/ldap-sdk-tools ls`

## Use LDAPSearch
### Get some help
`docker run -it --rm pingidentity/ldap-sdk-tools ldapsearch --help`

### Simple search
```Bash
docker run -it --rm pingidentity/ldap-sdk-tools \
    ldapsearch \
        -b dc=example,dc=com \
        -p 1389 "(objectClass=*)"
```

### Save output to host file
```Bash
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
```Bash
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
## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details

## Copyright
Copyright © 2019 Ping Identity. All rights reserved.