# Deploy PingDataGovernance with an external Policy Administration Point

This example describes how to build PingDataGovernance policies, and employs server profile layering. The base profile, `pingidentity-server-profiles/baseline/pingdatagovernance`, configures PingDirectory and PingDataGovernance to proxy the PingDirectory Rest API and uses an embedded PingDataGovernance policy as the Policy Decision Service. A second layer `pingidentity-server-profiles/pdg-pap-integration` switches the Policy Decision Service to use an external PingDataGovernance Policy Administration Point (PDG-PAP).

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## What you'll do

* [Deploy the stack](#deploy-the-stack).
* [Log in to the management consoles](#log-in-to-the-management-consoles).
* [Test the default use case](#test-the-default-use-case).
* [Build and test your own policy](#build-and-test-your-own-policy).
* [Clean up](#clean-up).

## Deploy the stack

Go to your local [11-docker-compose/07-pingdatagovernance](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/11-docker-compose/07-pingdatagovernance) directory, and enter: 
   
   ```shell
   docker-compose up -d
   ```

   When _all_ of the containers are healthy, you can start testing. 

## Log in to the management consoles

- PingDataGovernance - Policy Administration Point (PAP): 
  - URL: https://localhost:8443
  - user: admin
  - password: password123
  
- PingDataConsole: 
    - URL: https://localhost:9443/console
    - server: pingdatagovernance
    - user: administrator
    - password: 2FederateM0re

## Test the default use case

The default use case does the following:
  
-  Proxies the PingDirectory Rest API using a mock access token validator.

-  If the passed bearer token is valid, PDG-PAP allows it to be forwarded to PingDirectory.

-  PingDirectory uses the `sub` field in the token along with the the URL path to look up and return a users data. 

-  On the returned data, PDG-PAP accepts the response and allows it to be returned to the requestor. 

To test this use case:

1. Access the PingDataGovernance server: 

   ```shell
   curl -k 'https://localhost:7443/pd-rest-api/uid=user.1,ou=people,dc=example,dc=com' \
   --header 'Authorization: Bearer { "active":true,"sub" : "user.1", "clientId":"client1","scope":"ds" }' 
   ```

2. Monitor the logs. To watch a request flow through all of the tools, you can `tail -f` each of these logs:

   - PingDataGovernance: 
  
     ```shell
     docker container exec -it 07-pingdatagovernance_pingdatagovernance_1 tail -f /opt/out/instance/logs/policy-decision 
     ```
     (`Ctrl+c` to exit)

   - PAP (standard container logs): 
     
     ```shell
     docker container logs -f 07-pingdatagovernance_pingdatagovernancepap_1
     ```

   - PingDirectory (standard container logs). Because the baseline profile has debug mode on, when you make a successful request through PingDataGovernance to PingDirectory, you'll see successful `BIND` and `SEARCH` logs containing the user you searched for: 
     
     ```shell
     docker container logs -f 07-pingdatagovernance_pingdirectory_1
     ```

3. Display the configurations in Data Console:
    
   - Gateway API endpoints 
     
     Select the API endpoints that are being proxied to display the related information. 

   - Policy Decision Service 
   
     Select which policy will be used to govern data and access, and display the related information.

   - PDP mode 
     
     Select `embedded` for the default policy, or import a deployment package. Select `external` to use PAP.
     
   - External Servers
     
     Display the PAP configuration and define the policy that is being used on PAP. 

## Build and test your own policy

1. Open PAP.
   
2. Define a policy. 
   
3. Select `external` for the Policy Decision Service in Data Console.
   
4. In Data Console, go to External Servers -> `pingdatagovernancepap`, and enter your policy name in the `branch` field.
   
5. Save your changes.

6. Make a request to the PingDataGovernance server again (as you did when testing the default use case):
   
   ```shell
   curl -k 'https://localhost:7443/pd-rest-api/uid=user.1,ou=people,dc=example,dc=com' \
   --header 'Authorization: Bearer { "active":true,"sub" : "user.1", "clientId":"client1","scope":"ds" }' 
   ```

   Watch the same logs, and you'll see your policy being used. 

   In PDG-PAP, this will look similar to:

   ```shell
   172.20.0.3 - - [20/May/2020:15:27:06 +0000] "POST /api/governance-engine?decision-node=e51688ff-1dc9-4b6c-bb36-8af64d02e9d1&branch=<YOUR POLICY BRANCH NAME HERE> HTTP/1.1" 400 118 "-" "Jersey/2.17 (Apache HttpClient 4.5)" 6
   ```

   If you want further confirmation, in the Data Console, go to External Servers -> `pingdatagovernancepap` and put some "junk" in the `branch` box. You'll see that PingDataGovernance is unable to find the policy branch. 


## Clean up the stack

When you're finished testing, remove the containers, network, and related data. Enter:

```shell
docker-compose down
```