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

TBD

---
Copyright (c)  2020 Ping Identity Corporation. All rights reserved.
