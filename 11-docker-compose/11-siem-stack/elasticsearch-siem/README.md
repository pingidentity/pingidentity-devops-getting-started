### Important Folder Structure Notes
- `cert_config/` Contains bootstraping files for cert generation for ElasticSearch to use TLS between nodes (and kibana front end), if nodes are added this file must be updated

- `index_templates` Contains index mappings for PingFederate, PingAccess, PingDirectory. They also point to ILM policies that are used for retention. By Default they point to a TWO '2' day retention. 

- `enrichment_cache` Is preloaded with yaml as it needs to be present for logstash to start, they are updated every x seconds defined in compose file. These will ensure the stack knows about TOR and malicious IP's

- `kibana_config` Stores an NDJSON file with all saved dashboard objects etc, and index mappings. This is your dashboards!

- `logstash` Stores the main pipeline for injesting logs from Ping Products. Logstash pipeline for taking logs from PA / PF / PD

- `ping_siem_config_bootstrap` Contains Scrpt files for dependency install, cert generation, enrichment file collection and parsing, and template loaders.

- `ilm_policies` These files contain rules around how long and how much data should exists within indexes. By DEFAULT they are SMALL 2 days 2 GB. This is due to configuration of elasticsearch HEAP size being SMALL as this is a DEMO. These need to change in a production implementation.

- `index_bootstraps` These files will bootstrap the indexes, this has to occur before ping writes logs, otherwise they will not roll over correctly.

- `ping_siem_config_bootstrap` These are script files that execute from within containers. These include a wide range of things from dependency installers, to enrichment loaders, and keystore bootstrappers.

- `watchers` These files are alert files. They contain a search, interval, and actions. They are loaded only if you elect to use slack alerting.