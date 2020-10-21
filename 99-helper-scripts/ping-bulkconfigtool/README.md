# Ping Identity Bulk Config Tools

The bulk export process provides a simple way to extract holistic configuration from both PingFederate and PingAccess to simplify build and pipeline process.

The bulk export process performs the following:
1. Extract configuration from a local sandbox deployment.
2. Process the JSON export provided a process configuration (see [pa-config.json](./ping-bulkexport-tools-project/in/pa-config.json) and [pf-config.json](./ping-bulkexport-tools-project/in/pf-config.json) examples).
    - Search and replace (e.g. hostnames)
    - Cleans, add, and remove JSON members as required.
    - Tokenise the configuration and maintain environment variables.
    - Outputs pretty JSON.

The bulk export process also allows config injection for secrets and keys.

### Example output:
- PingAccess
  - Configuration: [data.json.subst](../../server_profiles/pingaccess/instance/data/start-up-deployer/data.json.subst)
  - Env Vars: [pa.env](../../docker-compose/pa.env)
- PingFederate
  - Configuration: [import-bulkconfig.json.subst](../../server_profiles/pingfederate/instance/server/default/drop-in-config/003-importbulkconfig/requestBody.json.subst)
  - Env Vars: [pa.env](../../docker-compose/pa.env)

## Pre-requisites

The bulk export utility comes in pre-compiled source code. To build the project, you'll need:
- JDK 11
    - JAVA_HOME and PATH environment settings.
      - JAVA_HOME=/path/to/java
      - PATH=$PATH:$JAVA_HOME/bin
    - https://adoptopenjdk.net/
- Maven
    - MAVEN_HOME and PATH environment settings.
      - MAVEN_HOME=/path/to/maven
      - PATH=$PATH:$MAVEN_HOME/bin
    - https://maven.apache.org/

You'll also need the CDR Sandbox running on your local machine.
  - If you have changed the default settings (e.g. hostnames) you'll need to configure the configuration json files [pa-config.json](./ping-bulkexport-tools-project/in/pa-config.json), [pa-admin-config.json](./ping-bulkexport-tools-project/in/pa-admin-config.json), and [pf-config.json](./ping-bulkexport-tools-project/in/pf-config.json).

## Run the export utility.

1. In terminal, navigate to the scripts/ping-bulkconfigtools folder.
2. Compile the tool if you haven't already done so.
    - cmd: ./_compile_bulkexporttool.sh
3. Export PingAccess configuration
    - cmd: ./_pa_export-config.sh
    - GETs configuration from: https://localhost:9000/pa-admin-api/v3/config/export
    - This will then create 2 exports: 
        1) server_profiles/pingaccess/instance/data/start-up-deployer/data.json.subst
        2) server_profiles/pingaccess-admin/instance/data/start-up-deployer/data.json.subst (contains CONFIG QUERY http listener).
    - Creates/maintains the following environment variable files:
      - docker-compose/pa.env
      - k8/02-completeinstall/pa.env
4. Export PingFederate configuration
    - cmd: ./_pf_export-config.sh
    - GETs configuration from: https://localhost:9999/pf-admin-api/v1/bulk/export
    - This will then create the following: 
        1) server_profiles/pingfederate/instance/import-bulkconfig.json.subst
    - Creates/maintains the following environment variable files:
      - docker-compose/pf.env
      - k8/02-completeinstall/pf.env

## Configure and commit

You'll need to configure the following environment variable files. The export process will maintain values inside these files that have been previously set however, new parameters may be present so you should look out for them.
- docker-compose/pa.env
- docker-compose/pf.env
- k8/02-completeinstall/pa.env
- k8/02-completeinstall/pf.env

You do not need to commit the environment variables. You should consider excluding these files from being committed as they may contain sensitive information such as certificate keys and passwords.

Commit the following files to update the configuration:
- server_profiles/pingaccess/instance/data/start-up-deployer/data.json.subst
- server_profiles/pingaccess-admin/instance/data/start-up-deployer/data.json.subst
- server_profiles/pingfederate/instance/import-bulkconfig.json.subst

## Known Issues

### Old hivemodule.xml

Bulk configuration requires the ability for PingFederate to reload configuration while running. When introduced, certain elements in hivemodule requires model="autoreloadable" to allow reloading of configuration. 

If you have issues, you may have inherited an old hivemodule.xml in your server profile. Check and compare it aligns to the version of PingFederate that you are running.

### LDAP authentication to Admin Console

PingFederate can be configured to enable LDAP authentication to the admin console (web/api). This has not been tested and may require alterations to the startup deployer calls stored under server/default/drop-in-config.

## Appendix

### Applying encoded file configuration

PingFederate and PingAccess both provide API's to import file content. This may be used for:
- Importing certificates and PKCS12 keystores.
- Importing property or binary files to adapter configuration.

The bulk export process will expose fileData configuration options in the environment variable files (i.e. pf.env and pa.env). This provides the administrator the ability to inject certificate/file based configuration. 

You'll need to base64 encode into a JSON friendly value:
1. Encode the file content in base64, 
2. Remove line breaks, and 
3. Escape back slashes.

Here's a command that can do that for you:
- openssl base64 -in ~/Downloads/admin_signing.p12 | tr -d '\n' | sed 's/\\\//\\\\\\\//g'



