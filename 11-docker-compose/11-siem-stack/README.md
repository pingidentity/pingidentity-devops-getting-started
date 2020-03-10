# Ping Stack with ElasticSearch SIEM -- BETA version (.1)
#### Built by Ryan Ivis with Ping Identity   
#### Project Salt Water

The goal of this project is to have pre-built security dashboards to ride along side our products. The inital phase is currently working on PingFederate Audit Logs. 

## What is this ?
![alt text](https://github.com/ryanivis/ping-devops-es-siem/blob/master/images/Architecture.png "Architecture Overview")
- Threat Intel and TOR Endpoints are being provided by AlienVault and the TOR Network Endpoint List.  
- Threat Feeds are updated on an interval via seting a var in docker-compose !!!

This project will start a Ping Stack with Elastic Search Infrastructure built in for visualizing traffic and other security / log data.

---------------
## Latest Build News

- Finish building threat detection dash for PingFederate that includes attack detection for DOS, Stolen Credentials, XXE, Password Brute Force, CSRF, SAML Signature Manipulation, Deserialization. 
  - The dash is configured for experenced security engineers, and may not cover every type of attack of these sorts. Please use caution, the dash is in beta. Thanks YYU!

---------------

## Status
| Phase    | Ping Product                                |  Status     |
|----------|---------------------------------------------|-------------|
| Phase 1  | PingFederate Audit Logs                     | Complete    |
| Phase 1a | PingFederate Provisioner Logs               | Complete    |
| Phase 1b | PingFederate System Logs                    | Complete    |
| Phase 2  | LDAP Integrate ElasticSearch / Kibana       | In Progress |
| Phase 2a | Ping SIEM Dashboard                         | Beta        |
| Phase 2b | PingDirectory Load Generator (thanks arno)  | Complete    |
| Phase 2c | Index Mapping rework for PD data index      | Complete    | 
| Phase 2d | Integrate 2 Day Retention with Curator      | In Progress |
| Phase 2e | Ping Federate Threat Detection Dashboard    | Beta        |
| Phase 3  | PingDirectory Logs                          | Complete    | 
| Phase 4  | PingAccess Logs                             | Complete    |
| Phase 5  | Test and Implement Yelp Elastalert          | Not Started |
| Phase 6  | Help GTE / RSA Implement Customer Demos     | Not Started |


## Important Note
- **THIS IS NOT INTENDED FOR PRODUCTION. THERE ARE DEFAULT PASSWORDS THAT MUST BE MODIFIED**...   
     
- **THERE ARE PERSISTANT DISKS USED FOR ELASTIC SEARCH DATA, AND ELASTIC SEARCH CERTS. TO CLEAR THEM WHEN YOU ARE DONE TESTING RUN**...   
	- `docker volume prune`  

- **YOU MUST RUN THE FOLLOWING COMMAND ON UBUNTU (LIKELY OTHER DISTRO'S) TO SUPPORT HEAP SIZES**
	- `sudo sysctl -w vm.max_map_count=262144`

# Directions

- To setup on AWS use a M5.XL or M5a.XL (16GB RAM)
- Tested on Ubuntu 18 Running Docker / Docker Compose
    - Installed using these directions https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04
    - Install Docker and Docker Compose(the above link can help or do your own research)
    - `sudo sysctl -w vm.max_map_count=262144`
- Clone this project to your local disk.  
- Create and place a file `.env` in root path of the clone and place these lines in it (update your devops details).
```
COMPOSE_PROJECT_NAME=es   
ELASTIC_VERSION=7.6.0   
ELASTIC_SECURITY=true    
ELASTIC_PASSWORD=2FederateM0re   
CERTS_DIR=/usr/share/elasticsearch/config/certificates     
PING_IDENTITY_DEVOPS_USER={YOUR DEVOPS USER NAME HERE}    <====== NOTICE THIS
PING_IDENTITY_DEVOPS_KEY={YOUR DEVOPS KEY HERE}    <====== NOTICE THIS
```
- Start the stack with `docker-compose up -d`  
- Monitor the stack with `docker-compose logs --follow`

------------
## Dashboard Examples

### Demo Ping Federate Threat Intel Dashboard
![alt text](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/11-docker-compose/11-siem-stack/images/threat_intel_dash.png "SIEM Dashboard")

### Demo Ping SIEM Dashboard (Beta 4) - More security use cases are coming soon.
![alt text](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/11-docker-compose/11-siem-stack/images/dashboard.png "SIEM Dashboard")

### Ping Federate Demo Dashboard
![alt text](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/11-docker-compose/11-siem-stack/images/pingfederate_dashboard.png "PingFederate Basic Demo Dashboard")

### Demo Access Demo Dashboard
![alt text](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/11-docker-compose/11-siem-stack/images/pingaccess_dashboard.png "PingAccess Basic Demo Dashboard")

### Demo Directory Demo Dashboard
![alt text](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/11-docker-compose/11-siem-stack/images/pingdirectory_dashboard.png "PingDirectory Demo Dashboard")

------------

## PingDirectory
- Audit Logs are being delivered
- There are 2 containers that produce load, you can STOP these containers to save on CPU
    - authrate_ok
    - authrate_ko

## PingFederate
- Audit and System logs are delivered.

## PingAccess
 - Audit Logs are being delivered

## Kibana Access
- Kibana listens on https://{IP}:5601  

- DEFAULT PASSWORDS  
    - UN is configured as "elastic"  
    - PASSWORD is configured as "2FederateM0re"  


## Important Notes <--READ
- Allow 5-10 min for the stack to come up!
- The stack spins up a few containers that send load to PingDirectory, below you will find directions to disable those.
- **If updating the Elastic Password**
	- ping-devops-es-siem/.env 
- This uses the default elastic user. This is **bad practice** and you should configure service users for logstash / kibana.
- Server Side TLS Certificate Validation is not enabled on the demo it is set to 'none' in the ES configuration
- TLS is used betweeen ES nodes, as well as between Logstash and Kibana.
- Certs are all self signed.

------------
## Kibana Saved Objects
- Saved Objects can be loaded by going to 'saved objects' under kibana settings and exporting all. Save the file in the...  
	- ./elasticsearch-siem/kibana_config/kib_base.ndjson  

- They will be reloaded when the stack is reloaded!!! This enables you to save objects for dashboards and reload!

------------
## ElasticSearch Template for PingFederate Audit Logs
- Elasticsearch will load the PF-Audit Template such that logs will have the correct field types for searching ONLY working for the AUDIT logs if you use the Included LOG4J format within this PF baseline.
- The Scripts will load this template(s) once cluster state is green.
	- ./elasticsearch-siem/elasticsearch_config/****

------------
## Logstash Pipeline
- TOR Enrichment
- Threat Intel (Alien Vault Provided)
- GEO IP Lookup
- Data Parsing
- Logstash Pipeline is stored in the folder structure. It includes Parsers for All Ping Log Sources.

------------
## PingFederate
- Ping Fed ships logs on 2 different SYSLOG PORTS, with a CUSTOM mappings.
------------

------------
## PingDirectory
- Ping Fed ships logs on 1 SYSLOG PORT, with a CUSTOM mapping.
------------

------------
## PingAccess
- Ping Fed ships logs on 2 different SYSLOG PORTS, with a CUSTOM mappings.
------------


## Ping Dev-Ops Included Documentation


## Server Profiles

Ping Identity Server Profiles are used to provide the configuration, data, environment details to Ping Identity Docker Images.

### Available Server Profiles

There are several Ping Identity Server Profiles available in the Ping Identity Github repositories. They are outlined in the table below.

| Server Profile | Description |
| :--- | :--- |
| [Getting Started](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started) | Ping Identity products with basic install/config |
| [Baseline](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline) | Ping Identity products with full integration |
| [Simple Sync](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/simple-sync) | DataSync server sync'ing between two PingDirectory trees |

### Playground Server Profiles

There is a Github Repository containing samples, experimental, training types of server profiles that may be created to help with examples and getting started projects. These are guaranteed to be documented as they are often one off examples of different concepts. Some of these products include:

| Server Profile | Description |
| :--- | :--- |
| [PingFed Cluster](https://github.com/pingidentity/server-profile-pingidentity-playground/tree/master/getting-started-pingfederate-cluster) | Configuring a PingFed cluster with admin/engine nodes |
| [PingOne for Customer](https://github.com/pingidentity/server-profile-pingidentity-playground/tree/master/pingone-cloud) | Use cases around PingOne for Customer |
