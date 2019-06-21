# Develop Locally

You can develop and work with server-profiles from your local machine in addition to pushing to Github.

## All-Powerful Directories

To develop effectively, be aware of two directories in all Ping Images.

### /opt/out

All configurations and changes during container runtime \(i.e. "persisted data"\) are captured here. For example: On the PingFederate image `/opt/out/instance` contains much of the typical PingFederate root directory:

```text
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

### /opt/in

A Ping Identity container will look in this directory for any provided server-profile structures or other relevant files. This is in contrast to a server-profile provided via Github URL in an environment variable.

## How to Use:

These directories are useful for building and working with local server-profiles. `/opt/in` is especially valuable if you do not want your containers to reach out to Github. Here is an example:

1. start with a vanilla PingFederate and bind-mount /opt/out to local directory:

   ```text
    docker run \
              --name pingfederate \
              --publish 9999:9999 \
              --detach \
              --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
              --env SERVER_PROFILE_PATH=getting-started/pingfederate \
              -v /tmp/docker/pf:/opt/out \
              pingidentity/pingfederate:edge
   ```

   > Make sure the locally mounted directory \(e.g.`/tmp/docker/pf`\) is not created. /opt/out expects to create the directory.

2. Make some configuration changes via PingFederate UI. As you make changes, you can see the files in the local directory change. For PingFederate, a folder `instance` is created. This is a server-profile. You could push this to Github for use as an environment variable, but here we will use it as a local server-profile.
3. Stop the container and start a new one with the local config:

   ```text
   docker container stop pingfederate

   docker run \
            --name pingfederate-local \
            --publish 9999:9999 \
            --detach \
            -v /tmp/docker/pf:/opt/in \
            pingidentity/pingfederate:edge
   ```

   in the logs you can see where `/opt/in` is used:

   ```text
   docker logs pingfederate-local
   # Output:
   # ----- Starting hook: /opt/entrypoint.sh
   # copying local IN_DIR files (/opt/in) to STAGING_DIR (/opt/staging)
   # ----- Starting hook: /opt/staging/hooks/01-start-server.sh
   ```

### Additional Notes:

* This is helpful when developing locally and configuration is not ready for GitHub
* Docker recommends to never use bind-mounts in production. Hence, this example is good for _developing_ server profiles. 
* Mounted volumes \(`docker volume create pf-local`\), preferred method, can be used instead. Be sure the volume is empty when mounting to /opt/out
* Be sure to look at [server-profiles administration](administration.md) to see what can go in to each product's `/opt/in`. 

### Use Github!

A fun way to watch exactly which files change as you make configurations \(using the example above\):

```text
  cd /tmp/docker

  git init

  # start container. make changes

  git status

  git diff HEAD

  #complete changes. Stop container

  #save config
  git add .
  git commit -m "added new connection"

  #push to github to use as a environment variable server profile in the future
  git remote add origin <your-github-repo>
  git push origin master
```

