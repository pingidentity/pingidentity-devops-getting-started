# Deploying Ping Delegator Image

This document proivdes the steps to deploy a Ping Delegator instance to:
* Authenticate the admin via PingFederate
* Manage users/groups in a Ping Directory instance

## Pre-Requisites
An instance of Ping Federate and Ping Directory are required.  The steps below
assume an instance of each using the standalone examples from the
`pingidentity-devops-getting-started/11-docker-compose/00-standalone` Github Repo. 

> The steps below could be applied to any Ping Federate and Ping Directory instance,
> although some of the hostnames/ports in the examples below will need to be adjusted.

## Assumptions
* Running all three instances on local machine under docker-compose

```
      authn  console                 console                      https
      9031    9999                    8443                        1443
       |       |                       |                           |
   +----------------+          +----------------+          +----------------+
   |  pingfederate  |          |  pingdelegator |          |  pingdirectory |
   +----------------+          +----------------+          +----------------+
```

## Add host alias' in /etc/hosts
Ping Delegator runs as a Single Page App (SPA) from your browser, and performs 
redirects between the three instances.  This requires that hostnames be 
addressable from both your hosts and your docker-compose environments.  The easiest
way to accomplish this is to alias the three instance/service names to localhost
in your /etc/host file.

> There are additional ways to accomplish this with actual host names and thru the
> use of other tools like Ping Access.

    ```
    sudo vi /etc/hosts

    # Add the following line and ensure these names are only used 1 time in your
    # /etc/hosts file
    127.0.0.1 pingfederate pingdirectory pingdelegator pingdataconsole
    ```

## Startup
1. Startup Ping Directory
   
   ```
   ping-devops docker start pingdirectory
   ```

2. Startup Ping Federate
   
   ```
   ping-devops docker start pingfederate
   ```

3. Startup Ping Delegator

   ```
   ping-devops docker start pingdelegator
   ```

## Ping Federate Configuration

Login to the Ping Federate console and complete the following steps

1. Add scope for PingDirectory Server APIs.
   
    * Click OAuth Server --> Scope Management
    * Click `Exclusive Scopes` tab
    * Provide:
      * Scope Value: `urn:pingidentity:directory-delegated-admin`
      * Scope Description: `Directory Delegated Admin`
    * Click `Add` button
    * Click `Save` button

2. Create a OAuth Server Client

    * Click OAuth Server
    * Under CLIENTS section, click `Create New` button
    * Provide (keep all defaults other than):
      * Client ID: `dadmin`
      * Name: `dadmin`
      * Add Redirect URI as: `https://pingdelegator:8443/delegator/*` 
      * Select `Bypass Authorization Approval - Bypass` checkbox
      * Select `Allow Exclusive Scopes` checkbox
      * Select `urn:pingidentity:directory-delegated-admin` checkbox
      * Select `Allowed Grant Types - Implicit` checkbox
    * Click `Save` button

3. Allow Cross-Origin Resource Sharing

    * In Section Cross-Origin Resource Sharing Settings
      * Add Allowed Origin: `*`
    * Click `Save` button


## Ping Directory Configuration

Exec into the Ping Directory container and run the following dsconfig commands.

```
docker container exec -it ping_devops_pingdirectory_1 sh

#
# Add following entries
#   - Groups OU
#   - Admins OU
#   - deladmin Administrative User
#
ldapmodify --defaultAdd --continueOnError <<EOMOD1
dn: ou=Groups,dc=example,dc=com
objectClass: organizationalUnit
ou: Groups

dn: uid=deladmin,ou=people,dc=example,dc=com
objectClass: inetOrgPerson
uid: deladmin
cn: Delegated Admin
givenName: Delegated
sn: Admin
userpassword: 2FederateM0re

EOMOD1

#
# The search-base-dn value is the DN of a valid base entry where
# managed users are stored.
#
dsconfig create-rest-resource-type  --no-prompt \
    --type user \
    --type-name users \
    --set "display-name:Users" \
    --set enabled:true \
    --set "search-base-dn:ou=people,dc=example,dc=com" \
    --set primary-display-attribute-type:cn \
    --set resource-endpoint:users \
    --set "search-filter-pattern:(|(cn=*%%*)(mail=%%*)(uid=%%*)(sn=*%%*))" \
    --set structural-ldap-objectclass:inetOrgPerson \
    --set "parent-dn:ou=people,dc=example,dc=com"

dsconfig create-rest-resource-type  --no-prompt \
    --type group \
    --type-name groups \
    --set "display-name:Groups" \
    --set enabled:true \
    --set "search-base-dn:ou=groups,dc=example,dc=com" \
    --set primary-display-attribute-type:cn \
    --set resource-endpoint:groups \
    --set "search-filter-pattern:(cn=*%%*)" \
    --set structural-ldap-objectclass:groupOfUniqueNames \
    --set "parent-dn:ou=groups,dc=example,dc=com"

#
# Specify the attributes that will be made available through the Delegated Admin API
#
dsconfig create-delegated-admin-attribute --no-prompt --type-name users --attribute-type cn --set "display-name:Full Name" --set "display-order-index:0"
dsconfig create-delegated-admin-attribute --no-prompt --type-name users --attribute-type givenName --set "display-name:First Name" --set "display-order-index:1"
dsconfig create-delegated-admin-attribute --no-prompt --type-name users --attribute-type sn --set "display-name:Last Name" --set "display-order-index:2"
dsconfig create-delegated-admin-attribute --no-prompt --type-name users --attribute-type mail --set "display-name:Email" --set "display-order-index:3"
dsconfig create-delegated-admin-attribute --no-prompt --type-name users --attribute-type uid --set "display-name:User ID" --set "display-order-index:4"
dsconfig create-delegated-admin-attribute --no-prompt --type-name users --attribute-type ds-pwp-account-disabled --set "display-name:Account Disabled"
dsconfig create-delegated-admin-attribute --no-prompt --type-name groups --attribute-type cn --set "display-name:Group"
dsconfig create-delegated-admin-attribute --no-prompt --type-name groups --attribute-type description --set "display-name:Description"

#
# Create Delegated Admin Rights
#
dsconfig create-delegated-admin-rights  --no-prompt \
    --rights-name deladmin \
    --set enabled:true \
    --set admin-user-dn:uid=deladmin,ou=people,dc=example,dc=com

#
# Create Delegated Admin Resource User and Group Rights
#
# This will add/update aci's found on the User and Group resource trees, defined in rest resource
#
dsconfig create-delegated-admin-resource-rights --no-prompt \
    --rights-name deladmin \
    --rest-resource-type users \
    --set admin-scope:all-resources-in-base \
    --set admin-permission:create \
    --set admin-permission:read \
    --set admin-permission:update \
    --set admin-permission:delete \
    --set enabled:true

dsconfig create-delegated-admin-resource-rights --no-prompt \
    --rights-name deladmin \
    --rest-resource-type groups \
    --set admin-scope:all-resources-in-base \
    --set admin-permission:create \
    --set admin-permission:read \
    --set admin-permission:update \
    --set admin-permission:delete \
    --set enabled:true

#
# Create an access token validator for PingFederate tokens.
#
# WARNING: Use of the Blind Trust Trust Manager Provider is not recommended for production.  Instead, obtain PingFederate's
#          server certificate and add it to the JKS trust store using the 'manage-certificates trust-server-certificate'
#          command.  Then, update the PingFederateInstance external server to use the JKS Trust Manager Provider.
#          Consult the PingDirectory and PingData Security Guide for more information about configuring Trust Manager Providers.
#
dsconfig set-trust-manager-provider-prop  --no-prompt \
    --provider-name "Blind Trust" \
    --set enabled:true

dsconfig create-external-server  --no-prompt \
    --server-name pingfederate \
    --type "http" \
    --set "base-url:https://pingfederate:9031" \
    --set "hostname-verification-method:allow-all" \
    --set "trust-manager-provider:Blind Trust"

dsconfig create-identity-mapper  --no-prompt \
    --mapper-name "entryUUIDMatch" \
    --type "exact-match" \
    --set enabled:true \
    --set "match-attribute:entryUUID" \
    --set "match-base-dn:dc=example,dc=com"

dsconfig create-access-token-validator  --no-prompt \
    --validator-name "pingfederate-validator" \
    --type "ping-federate" \
    --set enabled:true \
    --set "identity-mapper:entryUUIDMatch" \
    --set "subject-claim-name:sub" \
    --set "authorization-server:pingfederate" \
    --set "client-id:pingdirectory" \
    --set "client-secret:pingdirectory"

#
# Complete the configuration of the Delegated Admin API.
#
dsconfig set-access-control-handler-prop --no-prompt \
    --add 'global-aci:(extop="1.3.6.1.4.1.30221.2.6.17 || 1.3.6.1.4.1.30221.2.6.62")(version 3.0;acl "Authenticated access to the multi-update and generate-password extended requests for the Delegated Admin API"; allow (read) userdn="ldap:///all";)'

dsconfig set-access-control-handler-prop --no-prompt \
    --add 'global-aci:(targetcontrol="1.3.6.1.4.1.4203.1.10.2 || 1.3.6.1.4.1.30221.2.5.40")(version 3.0;acl "Authenticated access to the no-op and password validation details request controls for the Delegated Admin API"; allow (read) userdn="ldap:///all";)'

dsconfig set-virtual-attribute-prop --no-prompt \
    --name "Delegated Admin Privilege" \
    --set enabled:true

dsconfig set-http-servlet-extension-prop --no-prompt \
    --extension-name "Delegated Admin" \
    --set access-token-scope:urn:pingidentity:directory-delegated-admin \
    --set "response-header:Cache-Control: no-cache, no-store, must-revalidate" \
    --set "response-header:Expires: 0" \
    --set "response-header:Pragma: no-cache"

#
# A CORS policy is not needed when the app is running in the Ping Directory Server or Ping Proxy Server.
# To prevent a potential security vulnerability in the CORS policy, cors-allowed-origins should instead be set to the
# public name of the host, proxy, or load balancer that is going to be presenting the delegated admin web application.
#
dsconfig create-http-servlet-cross-origin-policy --no-prompt \
    --policy-name "Delegated Admin Cross-Origin Policy" \
    --set "cors-allowed-methods: GET" \
    --set "cors-allowed-methods: OPTIONS" \
    --set "cors-allowed-methods: POST" \
    --set "cors-allowed-methods: DELETE" \
    --set "cors-allowed-methods: PATCH" \
    --set "cors-allowed-origins: *"

dsconfig set-http-servlet-extension-prop --no-prompt \
    --extension-name "Delegated Admin" \
    --set "cross-origin-policy:Delegated Admin Cross-Origin Policy"


#
# Create an email account status notification handler for user creation.
# This handler cannot be enabled until an SMTP server is available in the global configuration.
#
#dsconfig create-request-criteria \
#    --criteria-name "Delegated Admin User Creation Request Criteria" \
#    --type simple --set operation-type:add \
#    --set "included-target-entry-dn:ou=people,dc=example,dc=com" \
#    --set "any-included-target-entry-filter:(objectClass=inetOrgPerson)" \
#    --set "included-application-name:PingDirectory Delegated Admin"
#
#dsconfig create-account-status-notification-handler \
#    --handler-name "Delegated Admin Email Account Status Notification Handler" \
#    --type multi-part-email \
#    --set enabled:false \
#    --set "account-creation-notification-request-criteria:Delegated Admin User Creation Request Criteria" \
#    --set account-created-message-template:config/account-status-notification-email-templates/delegated-admin-account-created.template


```

---
Copyright (c)  2020 Ping Identity Corporation. All rights reserved.
