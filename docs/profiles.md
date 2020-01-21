# Using server profiles

When you deployed the full stack of solution containers in [Get started](evaluate.md), you were employing the server profiles associated with each of our solutions. In the YAML files, you'll see entries such as this for each product instance:

  ```text
  environment:
    - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_PATH=baseline/pingaccess
  ```
Our [pingidentity-server-profiles](../../pingidentity-server-profiles) repository indicated by the `SERVER_PROFILE_URL` environment variable, contains the server profiles we use for our DevOps deployment examples. The `SERVER_PROFILE_PATH` environment variable indicates the location of the product profile data to use. In the example above, the PingAccess profile data located in the `baseline/pingaccess` directory.

We use environment variables for certain startup and runtime configuration settings of both standalone and orchestrated deployments. There are environment variables that are common to all product images. You'll find these in the [PingBase image directory](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase). There are also product-specific environment variables. You'll find these in the [Docker image directory](https://pingidentity-devops.gitbook.io/devops/docker-images) for each available product.

## Prerequisites

  * You've already been through [Getting Started](evaluate.md) to set up your DevOps environment and run a test deployment of the solutions.

## What you'll do

  * Add or change the environment variables used for any of our server profiles to better fit your purposes. These environment variables are located in the [server profiles repository](../../pingidentity-server-profiles) for each product. For example, the location for the env_vars file for PingAccess is located in the [baseline/pingaccess server profile](../../pingidentity-server-profiles/baseline/pingaccess).
  * Modify one of our server profiles to reflect an existing Ping Identity product installation in your organization. You can do this by forking our server profiles repository (https://github.com/pingidentity/pingidentity-server-profiles) to your Github repository, or by using local directories.

## Add or change environment variables

1. Select any environment variables to add from either the [Docker image directory](https://pingidentity-devops.gitbook.io/devops/docker-images) for the solution-specific environment variables, or the [PingBase image directory](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase) for the environment variables common to all of our solutions.
2. Select the solution whose profile you want to modify from the `baseline`, `getting-started`, or `simple-sync` directories in the [server profiles repository](../../pingidentity-server-profiles).
3. Open the `env_vars` file associated with the solution and add any of the environment variables you've selected, or change the existing environment variables to fit your purpose.

## Modify a server profile

You can modify one of our server profiles based on data from your existing Ping Identity solution installation. Modify a server profile in either of these ways:

* Using your Github repository
* Using local directories

### Modify a server profile using your Github repository

We'll use a PingFederate installation as an example.

1. Export a [configuration archive](https://support.pingidentity.com/s/document-item?bundleId=pingfederate-84&topicId=adminGuide%2Fpf_c_configurationArchive.html) as a *.zip file from a PingFederate installation to a local directory.

 > Make sure this is *exported* as a .zip rather than compressing it yourself.

2. Log in to Github and fork [https://github.com/pingidentity/pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles) into your own GitHub repository.
3. Open an OS shell, create a new directory, and clone your Github repository to a local directory. For example:

```shell
  mkdir /tmp/pf_to_docker
  cd /tmp/pf_to_docker
  git clone https://github.com/<github-username>/pingidentity-server-profiles.git
```

Where <github-username> is the name you used to log in to the Github account.

4. Go to location where you cloned your fork of our `pingidentity-server-profiles` repository, and replace the `/data` directory in `getting-started/pingfederate/instance/server/default` with the `data` directory you exported from your existing PingFederate installation. For example:

```text
  cd pingidentity-server-profiles/getting-started/pingfederate/instance/server/default
  rm -rf data
  unzip -qd data <path_to_your_configuration_archive>/data.zip
```
Where <path_to_your_configuration_archive> is the location for your exported PingFederate configuration archive.

You now have a local server profile based on your existing PingFederate installation.

5. Push your changes to your Github repository (where you forked our server profile repository).

6. Deploy the PingFederate container. The environment variables `SERVER_PROFILE_URL` and `SERVER_PROFILE_PATH` direct Docker to use the server profile you've modified.


   > To save any changes you make after the container is running, add the entry `--volume <local-path>:/opt/out` to the `docker run` command. See *Saving your changes* in [Get Started](getStarted.md) for more information.

   For example:

  ```text
    docker run \
      --name pingfederate \
      --publish 9999:9999 \
      --publish 9031:9031 \
      --detach \
      --env SERVER_PROFILE_URL=https://github.com/<your_username>/pingidentity-server-profiles.git \
      --env SERVER_PROFILE_PATH=getting-started/pingfederate \
      --env-file ~/.pingidentity/devops \
      pingidentity/pingfederate:edge
  ```

  > If your GitHub server-profile repo is private, use the `username:token` format so the container can access the repository. For example, `https://github.com/<your_username>:<your_access_token>/pingidentity-server-profiles.git`.

7. Enter `docker container logs -f pingfederate` to display the logs as the container starts up.

8. In a browser, go to `https://localhost:9999/pingfederate/app` to display the PingFederate console.

### Modify a server profile using local directories

We'll use PingFederate as an example, and we'll use the local directories `/opt/in` and `/opt/out` bound and mounted as Docker volumes, rather than Github to modify the server profile:

* The `/opt/out` directory

  All configurations and changes during our container runtimes (persisted data) are captured here. For example, the PingFederate image `/opt/out/instance` contains much of the typical PingFederate root directory:

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

* The `/opt/in` directory

  A Ping Identity container will look in this directory for any provided server-profile structures or other relevant files. This is in contrast to a server-profile provided via Github URL in an environment variable.

These directories are useful for building and working with local server-profiles. The `/opt/in` directory is particularly valuable if you do not want your containers to access Github for data (the default for our server profiles). Here's an example, again using PingFederate:

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
