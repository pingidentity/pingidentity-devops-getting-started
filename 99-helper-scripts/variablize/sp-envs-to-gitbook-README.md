# Migrating Environments with Server-Profiles

It can be challenging to manage promoting configurations through environments (e.g. dev>qa>prod) when dealing with exporting and importing configuration archives. 

One part of the the challenge is the various hostnames and what they may be configured to in each environment. To overcome this, you can variablize the the exported configuration archive, and set the variables per deployment.


<!-- TODO: recommended path to promote configurations. repo, branches, one env_hosts file. do not fork, use blue-green for deployment. 

TODO: how to use variablize. sample commands
The `variablize_config.sh` tool can be used by sending each host/variable directly, or sending a list of hosts via a file.  -->

## Examples


### With Hosts File
**Preferred Method**
```
./variablize_pf_pa_config.sh --env-file /path/to/env_hosts -p /path/to/config/archive.zip --output data
```
This command will:
  1. Unzip archive.zip
  2. Iterate over a list of hosts and variable names and find and replace each into the config. 
  3. Rename the folder to `data`

The file containing the items to look for must be structured similar to: 
```
VARIABLE_NAME=string
PF_HOSTNAME=federate.dev.pingidentity.com
PF_HOSTNAME=federate.prod.pingidentity.com 
PA_HOSTNAME=access.dev.pingidentity.com 
PA_HOSTNAME=access.prod.pingidentity.com
PD_HOSTNAME=directory.dev.pingidentity.com
PD_HOSTNAME=directory.prod.pingidentity.com
```

### Single Host Variablization
```
./variablize__pf_pa_config.sh --source federate.dev.pingidentity.com --destination PF_HOSTNAME \
--path /path/to/config/archive.zip --backup --output data.zip
```
This command will: 
  1. Unzip `archive.zip` 
  2. Look for `federate.dev.pingidentity.com` and replace it with `${PF_HOSTNAME}`.
  3. Re-zip and rename to `data.zip`
  4. Create a `data.zip.bak` backup.

## Notes: 
  - Inline help on script can be found by adding -h or --help flags
  - if you point at a config archive zip and don't specify `--output` it will be converted to data.zip.subst. 
  - add the script to ~/bin to call from anywhere: 
  ```
  cd ~/bin
  ln -s <path/to/variablize_pf_ps_config.sh> variablize
  ```
  then you can run from anywhere on your host:
  ```
  variablize -s federate.dev.pingidentity.com -d PF_HOSTNAME \
  -p /path/to/config/archive.zip -B -o data
  ```