# Deploy PingDataGovernance with External Policy Administration Point

This example represents a scenario where a developer would work on building PingDataGovernance Policies. 

This use case employs server profile layering. The base profile, `pingidentity-server-profiles/baseline`, configures PingDirectory and PingDataGovernance to proxy the PingDirectory Rest API and uses an embeded PingDataGovernance policy as the Policy Decision Service. A second layer `pingidentity-server-profiles/pdg-pap-integration` switches the Policy Decision Service to use an external PDG-Policy Administration Point

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## What you'll do

* Deploy the stack.
* Log in to the management consoles.
* Bring down or stop the stack.

## Deploy the Stack

`cd` to the corresponding directory and run `docker-compose up -d`

once all the containers are healthy you can start checking things out. 

## Log in to the management consoles
- PingDataGovernance - Policy Administration Point: https://localhost:8443
  - login: admin/password123
- PingDataConsole: https://localhost:9443/console
  - login: 
    server: pingdatagovernance
    user: administrator
    password: 2FederateM0re

## Things to Do

### Test the default use case

The default use case:
  
1. Proxies the PingDirectory Rest API using a mock access token validator 

2. If the passed bearer token is valid, the PDG - Policy Administration Point allows it to be forwarded to PingDirectory

3. PingDirectory uses the "sub" field in the token along with the the URL path to look up and return a users data. 

4. On the returned data, PDG-PAP accepts the response and allows it to be returned to the requestor. 

To test this use case, you can `curl` the PingDataGovernance Server. 

```
curl -k 'https://localhost:7443/pd-rest-api/uid=user.1,ou=people,dc=example,dc=com' \
--header 'Authorization: Bearer { "active":true,"sub" : "user.1", "clientId":"client1","scope":"ds" }' 
```

You can watch everything that is happening and  how it is configured by looking in PingDataConsole and watching logs. 

1. Relevant logs. To watch a request flow through all of the tools, you can `tail -f` each of the following logs: 
  - PingDataGovernance - `docker container exec -it 07-pingdatagovernance_pingdatagovernance_1 tail -f /opt/out/instance/logs/policy-decision` (`ctrl+c` to exit)
  - Policy Administration Point - standard container logs - `docker container logs -f 07-pingdatagovernance_pingdatagovernancepap_1`
  - PingDirectory - Standard container logs. Since the baseline profile has debug mode on, when you make a successful request through PDG to PD you should see successful `BIND` and `SEARCH` logs containing the user you searched for. `docker container logs -f 07-pingdatagovernance_pingdirectory_1`

2. Relevant areas in Data Console: 
  - `Gateway API endpoints` - Look at and choose API endpoints to are being proxied. 
  - `Policy Decision Service` - Look at and choose which policy will be used to govern data and access.  
    - `PDP mode` - use `embedded` for the defualt policy, or import a deployment package. use `external` to use PAP
  - `External Servers` - Look at the PAP configuration and define the policy that is being used on PAP. 

### Build and Test Your Own Policy

1. Open the Policy Administration Point
2. Work on a policy. 
3. Select `external` for the `Policy Decision Service` in data console
4. In Data Console go to  `External Servers`>`pingdatagovernancepap`> enter your policy name in the `branch` box
5. (save)

Now if you make a request to the same APIs from [above](#test-the-default-use-case) and watch the same logs, you will see your policy being used. 

In PDG-PAP, this will look similar to:

```
172.20.0.3 - - [20/May/2020:15:27:06 +0000] "POST /api/governance-engine?decision-node=e51688ff-1dc9-4b6c-bb36-8af64d02e9d1&branch=<YOUR POLICY BRANCH NAME HERE> HTTP/1.1" 400 118 "-" "Jersey/2.17 (Apache HttpClient 4.5)" 6
```

If you still don't trust it, put some "junk" in the `branch` box, you will see PingDataGovernance not able to find the policy branch. 


## Cleanup 

`docker-compose down`