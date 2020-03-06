### Important Folder Structure Notes
- `cert_config/` Contains bootstraping files for cert generation for ElasticSearch to use TLS between nodes (and kibana front end)
- `elasticsearch_config` Contains index mappings for PingFederate, PingAccess, PingDirectory. They are very beta and can be further tuned.
- `enrichment_cache` Is preloaded with yaml as it needs to be present for logstash to start, they are updated every x seconds defined in compose file
- `kibana_config` Stores an NDJSON file with all saved dashboard objects etc, and index mappings. This is your dashboards!
- `logstash` Stores the main pipeline for injesting logs from Ping Products. Logstash pipeline for taking logs from PA / PF / PD
- `ping_siem_config_bootstrap` Contains Scrpt files for dependency install, cert generation, enrichment file collection and parsing, and template loaders.

