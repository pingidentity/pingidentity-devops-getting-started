## Enrichment Folder
- This directory will store enrichment files. 
- The directory must exist for the enrichment services to work.
- Stub files exist for AlienVaultIP and TorNodes. They are reloaded upon stack start and on an interval defined as a varible.
- MaliciousCountries.yml This is a list of what you consider to be malicious countries.
- KnownCountries.yml This is a list of what you consider to be normal countries.

### Do not Delete any files in this folder or logstash will not run.