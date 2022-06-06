---
title: Deploy PingAuthorize with an External Policy Editor
---
# Deploying PingAuthorize with an External Policy Editor

This example describes how to build PingAuthorize policies and employs server profile layering. The base profile, `pingidentity-server-profiles/baseline/pingauthorize`, configures PingDirectory and PingAuthorize to proxy the PingDirectory Rest API and uses an embedded PingAuthorize policy as the Policy Decision Service. A second layer `pingidentity-server-profiles/paz-pap-integration` switches the Policy Decision Service to use an external PingAuthorize Policy Editor (PAZ-PAP).

## Before you begin

You must complete [Get started](../get-started/introduction.md) to set up your DevOps environment and run a test deployment of the products.

## About this task

You will:

* Deploy the stack
* Log in to the management consoles
* Test the default use case
* Build and test your own policy
* Clean up

## Deploying the stack

Go to your local [11-docker-compose/07-pingauthorize](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose/07-pingauthorize) directory and enter:

```sh
docker-compose up -d
```

When _all_ of the containers are healthy, you can start testing.

## Signing on to the management consoles

| Product | Connection Details |
    | --- | --- |
    | [PingDirectory](https://localhost:9443/console) | <ul><li>URL: [https://localhost:9443/console](https://localhost:9443/console)</li><li>Server: pingdirectory:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAuthorize](https://localhost:9443/console) | <ul><li>URL: [https://localhost:9443/console](https://localhost:9443/console)</li><li>Server: pingauthorize:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAuthorize PAP](https://localhost:8443) | <ul><li>URL: [https://localhost:8443](https://localhost:8443)</li><li>Username: admin</li><li>Password: password123</li></ul> |

## Testing the default use case

The default use case does the following:

* Proxies the PingDirectory Rest API using a mock access token validator.
* If the passed bearer token is valid, PAZ-PAP allows it to be forwarded to PingDirectory.
* PingDirectory uses the `sub` field in the token along with the the URL path to look up and return a users data.
* On the returned data, PAZ-PAP accepts the response and allows it to be returned to the requestor.

To test this use case:

1. Access the PingAuthorize server:

      ```sh
      curl -k 'https://localhost:7443/pd-rest-api/uid=user.1,ou=people,dc=example,dc=com' \
      --header 'Authorization: Bearer { "active":true,"sub" : "user.1", "clientId":"client1","scope":"ds" }'
      ```

1. Monitor the logs.

   To watch a request flow through all of the tools, you can `tail -f` each of these logs:

   * PingAuthorize:

      ```sh
      docker container logs -f 07-pingauthorize_pingauthorize_1
      ```

      (`Ctrl+c` to exit)

   * PAP (standard container logs):

     ```sh
     docker container logs -f 07-pingauthorize_pingauthorizepap_1
     ```

   * PingDirectory (standard container logs). Because the baseline profile has debug mode on, when you make a successful request through PingAuthorize to PingDirectory, you see successful `BIND` and `SEARCH` logs containing the user you searched for:

     ```sh
     docker container logs -f 07-pingauthorize_pingdirectory_1
     ```

1. Display the configurations in Data Console:

   * Gateway API endpoints
     Select the API endpoints that are being proxied to display the related information.
   * Policy Decision Service
     Select which policy will be used to govern data and access, and display the related information.
   * PDP mode
     Select `embedded` for the default policy, or import a deployment package. Select `external` to use PAP.
   * External Servers
     Display the PAP configuration and define the policy that is being used on PAP.

## Building and testing your own policy

1. Open PAP.
1. Define a policy.
1. Select `external` for the Policy Decision Service in Data Console.
1. In Data Console, go to External Servers -> `pingauthorizepap` and enter your policy name in the `branch` field.
1. Save your changes.
1. Make a request to the PingAuthorize server again as you did when testing the default use case:

    ```sh
    curl -k 'https://localhost:7443/pd-rest-api/uid=user.1,ou=people,dc=example,dc=com' \
    --header 'Authorization: Bearer { "active":true,"sub" : "user.1", "clientId":"client1","scope":"ds" }'
    ```

    Watch the same logs to see your policy being used.

    In PAZ-PAP, this resembles the following:

    ```sh
    172.20.0.3 - - [20/May/2020:15:27:06 +0000] "POST /api/governance-engine?decision-node=e51688ff-1dc9-4b6c-bb36-8af64d02e9d1&branch=<YOUR POLICY BRANCH NAME HERE> HTTP/1.1" 400 118 "-" "Jersey/2.17 (Apache HttpClient 4.5)" 6
    ```

    If you want further confirmation, in the Data Console, go to External Servers -> `pingauthorizepap` and put some "junk" in the `branch` box. You'll see that PingAuthorize is unable to find the policy branch.

## Cleaning Up

When you no longer want to run this stack, bring the stack down.

To remove all of the containers and associated Docker networks, enter:

```sh
docker-compose down
```

To stop the running stack without removing any of the containers or associated Docker networks, enter:

```sh
docker-compose stop
```

To remove attached Docker Volumes, enter:

```sh
docker volume prune
```
