# Quick Start

Let's walk through a common sample use case together: taking a traditional PF server and moving it into a docker container.

Pre-requisites:

* GitHub Account

In this example we will take a Configuration Archive of your current \(possibly favorite\) _development_ PingFederate server and push it into a 'server profile'. Then we will start a PingFederate Docker container that pulls in this configuration. This is recommended for development and demonstration only.

Steps:

1. Export a [Configuration Archive](https://support.pingidentity.com/s/document-item?bundleId=pingfederate-84&topicId=adminGuide%2Fpf_c_configurationArchive.html) from a PingFederate instance into a location on your local machine.

   > Make sure this is exported as a .zip rather than compressing/zipping yourself

2. Log in to github.com and fork [https://github.com/pingidentity/pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles) into your own GitHub repository.
3. Open a terminal. Then:

   ```shell
   mkdir /tmp/pf_to_docker

   cd /tmp/pf_to_docker

   # Clone Server Profiles from your repository
   # Substitute the name of your GitHub account
   git clone https://github.com/<github username>/pingidentity-server-profiles.git
   ```

4. Copy your exported data.zip to replace `data.zip` in the [vanilla sample server-profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started)

   ```text
    cd pingidentity-server-profiles/getting-started/pingfederate/instance/server/default/data/drop-in-deployer

    rm data.zip

    cp <path_to_your_configuration_archive>/data.zip .
   ```

5. Now we have a local Server-Profile. We will push this to Github then use it via a docker environment variable. 

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

    git commit -m "updated with custom Configuration Archive"

    git push origin master
   ```
    > Make sure you are pushing to your forked repo.
    >```
    >   git remote set-url origin <https://github.com/<your_username/pingidentity-server-profiles
    >```

6. Now.. Run! :

   ```text
        docker run \
           --name pingfederate \
           --publish 9999:9999 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/<your_username>/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingfederate \
           pingidentity/pingfederate:edge
   ```

7. The container should now have started in the background. run `docker container logs -f pingfederate` to watch the logs. To be sure your config is properly applied look for:

   ```text
        2019-03-20 20:12:48,841  INFO  [org.eclipse.jetty.server.Server] Started @53553ms
        2019-03-20 20:12:53,206  INFO  [org.sourceid.saml20.domain.mgmt.impl.DataDeployer] Deploying: /opt/out/instance/server/default/data/drop-in-deployer/data.zip
        2019-03-20 20:12:53,217  INFO  [com.pingidentity.configservice.ConfigUpdateCoordinator] Configuration update is in progress…
        2019-03-20 20:12:53,244  INFO  [org.sourceid.saml20.domain.mgmt.impl.DataDeployer] Deploying: /opt/out/instance/server/default/conf/data-default.zip
        ##Watch your configuration happen!!##
        2019-03-20 20:12:56,531  INFO  [com.pingidentity.configservice.ConfigUpdateCoordinator] Configuration update has finished or was terminated.
   ```

8. Finally, browse to `https://localhost:9999/pingfederate/app`

## Some additional notes regarding persistence and ongoing usage:

* With the way we are running this container, any changes you make will be lost once you stop the container. To save your changes add `-v /some/local/path:/opt/out` to the `docker run` command. Look at the [develop locally](./local-workspace.md) doc
* The PingFederate license is located in `tmp/pf_to_docker/server-profile-pingidentity-getting-started/pingfederate/instance/server/default/conf`. The default license will quickly expire. You can upload your own license, but be careful to not push this license to a public github. For Ping employees, you can host private repositories on Gitlab. Otherwise, you can keep your own license in your local version of the repository.

