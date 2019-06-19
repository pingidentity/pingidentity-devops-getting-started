# Quick Start

Let's walk through a common sample use case together: taking a traditional PF server and moving it into a docker container.

Pre-requisites:

* GitHub Account

In this example we will take a Configuration Archive of your current \(possibly favorite\) _development_ PingFederate server and push it into a 'server profile'. Then we will start a PingFederate Docker container that pulls in this configuration. This is recommended for development and demonstration only.

Steps:

1. Export a Configuration Archive from a PingFederate instance into a location on your local machine.

   > Make sure this is exported as a .zip rather than compressing/zipping yourself

2. Log in to github.com and fork [https://github.com/pingidentity/pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles)
3. Open a terminal. Then:

   ```text
   mkdir /tmp/pf_to_docker

   cd /tmp/pf_to_docker

   git clone https://github.com/pingidentity/pingidentity-server-profiles.git

   git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git
   ```

4. From here, you can use two terminal windows, one for each of the new directories:

   ```text
    ls
    ######OUTPUTS#######
    # pingidentity-devops-getting-started         
    # server-profile-pingidentity-getting-started
    ####################
   ```

5. From the window for server-profile:

   ```text
    cd pingidentity-server-profiles/getting-started/pingfederate/instance/server/default/data/drop-in-deployer

    rm data.zip

    cp <path_to_your_configuration_archive>/data.zip .
   ```

6. Now we have a 'Server Profile' that we can point to when starting a PingFederate container so ... let's do that! In order to use this server profile from the 'Ping DevOps Getting Started' examples, we will push to github.

   ```text
   git status

   ######OUTPUTS######
   # On branch master
   # Your branch is ahead of 'origin/master' by 2 commits.
   # (use "git push" to publish your local commits)
   #
   # Changes not staged for commit:
   # (use "git add/rm <file>..." to update what will be committed)
   # (use "git checkout -- <file>..." to discard changes in working directory)
   #
   # deleted:    data.zip
   #
   # Untracked files:
   # (use "git add <file>..." to include in what will be committed)
   #
   # idp_data.zip
   #
   # no changes added to commit (use "git add" and/or "git commit -a")
   ##################
   ```

   ```text
    git add .

    git status
   ```

   ```text
    #####OUTPUTS#####
    # On branch master
    # Your branch is ahead of 'origin/master' by 2 commits.
    #  (use "git push" to publish your local commits)
    #
    # Changes to be committed:
    #  (use "git reset HEAD <file>..." to unstage)
    #
    #  deleted:    data.zip
    #  new file:   idpdata.zip
    #################
   ```

   ```text
    git commit -m "updated with custom Configuration Archive"

    git push origin master
   ```

7. Now let's tell our "getting started" example to point to this server profile. Open `pingidentity-devops-getting-started/10-docker-standalone/FF-shared/env-vars` in a text editor. Then change `GIT_REPO=<your-git-repo>` to point at your forked repo. Should look like: `https://github.com/<YOUR_USERNAME>/pingidentity-server-profiles`
8. Now.. Run! From the terminal pointed at `pingidentity-devops-getting-started` :

   ```text
    cd 10-docker-standalone

    ./docker-run.sh pingfederate
   ```

9. The container should now have started in the background. run `docker container logs -f pingfederate` to watch the logs. To be sure your config is properly applied look for:

   ```text
    2019-03-20 20:12:48,841  INFO  [org.eclipse.jetty.server.Server] Started @53553ms
    2019-03-20 20:12:53,206  INFO  [org.sourceid.saml20.domain.mgmt.impl.DataDeployer] Deploying: /opt/out/instance/server/default/data/drop-in-deployer/data.zip
    2019-03-20 20:12:53,217  INFO  [com.pingidentity.configservice.ConfigUpdateCoordinator] Configuration update is in progress…
    2019-03-20 20:12:53,244  INFO  [org.sourceid.saml20.domain.mgmt.impl.DataDeployer] Deploying: /opt/out/instance/server/default/conf/data-default.zip
    ##Watch your configuration happen!!##
    2019-03-20 20:12:56,531  INFO  [com.pingidentity.configservice.ConfigUpdateCoordinator] Configuration update has finished or was terminated.
   ```

10. Finally, browse to `https://localhost:9999/pingfederate/app`

## Some additional notes regarding persistence and ongoing usage:

* The getting started example we used to start the container \( `./docker-run.sh pingfederate` \) bind-mounts the container to your local storage in: `/tmp/Docker/pingfederate`. As such, you can work in your PingFederate container like you would on any development server. You will see `server.log` in `/tmp/Docker/pingfederate/runtime/instance/log`
* You can use `./docker-stop.sh pingfederate` to stop the container and `./docker-run.sh pingfederate` to start it again. If you don't use `./docker-cleanup.sh pingfederate`, all of your changes will be persisted. Use cleanup if you want to go back
* The PingFederate license is located in `tmp/pf_to_docker/server-profile-pingidentity-getting-started/pingfederate/instance/server/default/conf`. The default license will quickly expire. You can upload your own license, but be careful to not push this license to a public github. For Ping employees, you can host private repositories on Gitlab. Otherwise, you can keep your own license in your local version of the repository.

