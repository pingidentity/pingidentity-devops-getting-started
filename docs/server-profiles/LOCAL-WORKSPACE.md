Locally Developing Server Profiles
While developing server profiles, you will likely want to work on your local workstation and watch changes happen as you make them. 

To do this effectively, be aware of two directories in all Ping Images. 

/opt/out - all changes and running configurations during container runtime (i.e. "persisted data") are captured here. For example: On the PingFederate image /opt/out/instance equates the typical PingFederate root directory: 
```
.
├── README.md
├── SNMP
├── bin
├── connection_export_examples
├── etc
├── legal
├── lib
├── log
├── modules
├── sbin
├── sdk
├── server
├── tools
└── work
```

/opt/in - a Ping Identity container will look in this directory for any provided server-profile structures or other relevant files. This is in contrast to a server-profile provided via Github URL in an environment variable. 

How to use these directories: 
these directories are usefule for building and working with local server-profiles. /opt/in is especially valuable if  you do not want your containers to reach out to the public github. Here is an example: 
1. start with a vanilla PingFederate and bind-mount /opt/out to local directory: 
```shell
docker run \
          --name pingfederate \
          --publish 9999:9999 \
          --detach \
          --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
          --env SERVER_PROFILE_PATH=getting-started/pingfederate \
          -v /tmp/docker/pf:/opt/out \
          pingidentity/pingfederate:edge
```
> Make sure the locally mounted directory (e.g.`/tmp/docker/pf`) is not created. /opt/out expects to create the directory. 

2. Make some configuration changes via PingFederate UI. As you make changes, you can see the files in the local directory change. For PingFederate, a folder `instance` is created. This is a server-profile. You could push this to Github for use as an environment variable, but here we will use it as a local server-profile. 


3. Stop the container and start a new one with the local config:
```
docker container stop pingfederate

docker run \
          --name pingfederate-local \
          --publish 9999:9999 \
          --detach \
          -v /tmp/docker/pf:/opt/in \
          pingidentity/pingfederate:edge
```

in the logs you can see where `/opt/in` is used: 
```
docker logs pingfederate-local
# Output:
# ----- Starting hook: /opt/entrypoint.sh
# copying local IN_DIR files (/opt/in) to STAGING_DIR (/opt/staging)
# ----- Starting hook: /opt/staging/hooks/01-start-server.sh
```

Additional Notes: 
* This is a helpful example to user when your containers cannot reach Github. 
* Docker recommends to never use bind-mounts in production. Hence, this example is good for *developing* server profiles. 
* Mounted volumes (`docker volume create pf-local`), preferred method, can be used instead. Be sure the volume is empty when mounting to /opt/out
* Be sure to look at [server-profiles administration](./ADMINISTRATION.md) to see what can go in to each product's `/opt/in`. 