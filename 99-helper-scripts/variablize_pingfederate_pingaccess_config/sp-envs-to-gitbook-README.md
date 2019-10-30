# Migrating Environments with Server-Profiles

It can be challenging to manage promoting configurations through environments (e.g. dev>qa>prod) when dealing with exporting and importing configuration archives. 

One part of the the challenge is the various hostnames and what they may be configured to in each environment. To overcome this, you can: 1. variablize the the exported configuration archive 2. set the variables per deployment.
The following will cover: 
  - Recommended path to promote configurations. 

TODO: recommended path to promote configurations. repo, branches, one env_hosts file. do not fork, use blue-green for deployment. 

TODO: how to use variablize. sample commands
The `variablize_config.sh` tool can be used by sending each host/variable directly, or sending a list of hosts via a file. 

single host
```
./variablize_config.sh --source federate.dev.pingidentity.com --destination PF_HOSTNAME \
--path /path/to/config/data.zip --interactive --rename
```
This command will unzip `data.zip` and look for `federate.dev.pingidentity.com` then replace it with `${PF_HOSTNAME}`.
Additionally it wil create a `data.zip.bak` backup (re `--rename`) and ask to confirm before replacing (re `--interactive`). 

hosts file
```
./variablize_config.sh -e /path/to/env_hosts -p /path/to/config/data.zip
```
This command will iterate over a list of hosts and variables and find and replace each into the config. The file must be structured similar to: 
```
federate.dev.pingidentity.com PF_HOSTNAME
federate.prod.pingidentity.com PF_HOSTNAME
access.dev.pingidentity.com PA_HOSTNAME
access.prod.pingidentity.com PA_HOSTNAME
directory.dev.pingidentity.com PD_HOSTNAME
directory.prod.pingidentity.com PD_HOSTNAME
hostname variable_name
```
