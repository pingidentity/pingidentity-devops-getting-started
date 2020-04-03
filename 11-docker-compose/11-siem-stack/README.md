# Ping Stack with ElasticSearch SIEM -- BETA version 1.0
### Built by Ryan Ivis with Ping Identity   
### Project Salt Water
- Sailing to the NorthStar without understanding the water around you can be difficult. We want to help with that!

---------------

#### Project Goals
- Enable Customers to see the water in the pipes
- Enable some useful alerts that can be generated from our products
- Use industry standard tooling to boost your security program

---------------

## Latest Build News

- Implemented Impossible Distance Alert. Currently set to 1200km at 6hr.
- Modified many of the configurations to support logging in via LDAP.
- Authentication to the ES Stack / Kibana is now LDAP driven. There is a LDAP group `ESAdminGroup` that is in the example.com Root DSE. Adding a user to this group now gives them access to kibana and all data within elasticsearch as an admin.
- Migrated all indexes to using ILM. This means by default the stack will only store 2 days worth of logs and ensure indexes do not grow over 2GB. This is done because the enviroment is setup as a demo. HEAP sizes in the ES server are SMALL becasue this is a demo. I will soon have production ready documents written to show customers how this can be brought to production.
- Tested updating to elastic 7.6.1 (all good)
- Added in Slack Alerting! 
  - The process requires running a script after you start your stack. 
  - The script will ask you for your webhook url, then add the configuration into the elasticsearch keystore.
  - To run the script run the config_slack_alerts.sh script from the project directory end enter in your webhook URL.

---------------

## Status
| Phase    | Ping Product                                |  Status     |
|----------|---------------------------------------------|-------------|
| Phase 1  | PingFederate Audit Logs                     | Complete    |
| Phase 1a | PingFederate Provisioner Logs               | Complete    |
| Phase 1b | PingFederate System Logs                    | Complete    |
| Phase 2  | LDAP Integrate ElasticSearch / Kibana       | Complete    |
| Phase 2a | Ping SIEM Dashboard                         | Beta        |
| Phase 2b | PingDirectory Load Generator (thanks arno)  | Complete    |
| Phase 2c | Index Mapping rework for PD data index      | Complete    | 
| Phase 2d | Migrate All Indexes to use ILM vs Date/Time | Complete    |
| Phase 2e | Ping Federate Threat Detection Dashboard    | Beta        |
| Phase 3  | PingDirectory Logs                          | Complete    | 
| Phase 4  | PingAccess Logs                             | Complete    |
| Phase 5  | Test and Implement 3  Trial ES Watchers     | Complete    |
| Phase 6  | Help GTE / RSA Implement Customer Demos     | Not Started |
| Phase 7  | Slack Integrate Alerts from SIEM.           | Complete    |
| Phase 8  | Develop Several Custom Alerts               | In Progress |
| Phase 9  | Develop Production Grade Deployment Doc     | In Progress |
| Phase 10 | Implement GEO-Distance Impossible detection | Beta        |


See [Deploy an Elasticsearch SIEM stack](https://pingidentity-devops.gitbook.io/devops/deploy/deploycompose/deploysiemstack) for more information.
