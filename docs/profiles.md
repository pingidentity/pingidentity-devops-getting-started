# Using server profiles

When you deployed the full stack of solution containers in [Get started](evaluate.md), you were employing the server profiles associated with each of our solutions. In the YAML files, you'll see entries such as this for each service (solution):

  ```text
  environment:
    - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_PATH=baseline/pingaccess
  ```
Our [pingidentity-server-profiles](../../pingidentity-server-profiles/README.md) repository indicated by the `SERVER_PROFILE_URL` environment variable, contains the server profiles we use for our deployment examples. The PingAccess profile data is located in the `baseline/pingaccess` directory.

We use environment variables for certain startup and runtime configuration settings of both standalone and orchestrated deployments. There are environment variables that are common to all DevOps images. You'll find these in the [PingBase image directory](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase). There are also solution-specific environment variables. You'll find these in the [Docker image directory](https://pingidentity-devops.gitbook.io/devops/docker-images) for each available solution.

You can try different configuration settings using the common and solution-specific environment variables for our deployment examples, or use them in your own custom deployments. You can:

  * Use any of the existing server profiles in [pingidentity-server-profiles](../../pingidentity-server-profiles/README.md) to try out different types of deployments.
  * Add or change the environment variables used for any of our server profiles to better fit your purposes. These environment variables are located in the [server profiles repository](../../pingidentity-server-profiles). For example, this is the location for the [env_vars file for the baseline/pingaccess server profile](../../pingidentity-server-profiles/baseline/pingaccess/env_vars).
  * Modify a server profile based on an existing Ping Identity solution installation in your organization. You can do this using by forking our server profiles to your Github repository, or by using local directories.

## Prerequisites

  * You've already been through [Getting Started](evaluate.md) to set up your DevOps environment and run a test deployment of the solutions.

## Adding or changing environment variables

  1. Select any environment variables to add from either the [Docker image directory](https://pingidentity-devops.gitbook.io/devops/docker-images) for the solution-specific environment variables, or the [PingBase image directory](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase) for the environment variables common to all of our solutions.
  2. Select the solution whose profile you want to modify from the `baseline`, `getting-started`, or `simple-sync` directories in the [server profiles repository](../../pingidentity-server-profiles).
  3. Open the `env_vars` file associated with the solution and add any of the environment variables you've selected, or change the existing environment variables to fit your purpose.

## Modifying a server profile based on an existing Ping Identity solution installation and using your Github repository

We'll use a PingFederate installation as an example solution, and we'll fork our server profile repository (https://github.com/pingidentity/pingidentity-server-profiles) to your Github repository.

  1. Export a [configuration archive](https://support.pingidentity.com/s/document-item?bundleId=pingfederate-84&topicId=adminGuide%2Fpf_c_configurationArchive.html) as a *.zip file from a PingFederate installation to a location on your local machine.

   > Make sure this is exported as a .zip rather than compressing it yourself.

  2. Log in to Github and fork [https://github.com/pingidentity/pingidentity-server-profiles](https://github.com/pingidentity/pingidentity-server-profiles) into your own GitHub repository.
  3. Open an OS shell, create a new directory, and clone your Github repository. For example:

  ```shell
    mkdir /tmp/pf_to_docker
    cd /tmp/pf_to_docker
    git clone https://github.com/<github username>/pingidentity-server-profiles.git
  ```
  4. Replace the config `/data` directory in the [getting-started server profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started) with the `data` directory from your cloned Github repository (the `data` directory you exported from your existing PingFederate installation). For example:

  ```text
    cd pingidentity-server-profiles/getting-started/pingfederate/instance/server/default
    rm -rf data
    unzip -qd data <path_to_your_configuration_archive>/data.zip
  ```
  Where `<path_to_your_configuration_archive>` is the location to which you cloned your Github repository.

  You now have a local server profile based on your existing PingFederate installation.

5. Push this to your Github repository where you forked our server profile repository (https://github.com/pingidentity/pingidentity-server-profiles).

6. Run the PingFederate container. To save any changes you make after the container is running, add the entry `-v /some/local/path:/opt/out` to the `docker run` command. The environment variables `SERVER_PROFILE_URL` and `SERVER_PROFILE_PATH` direct Docker to use the server profile you've modified. For example:

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

7. Enter `docker container logs -f pingfederate` to display the logs as the container starts up. If your server profile modification has been applied, you'll see something like this:

  ```text
    2019-09-12 22:23:28,318  INFO  [org.eclipse.jetty.server.AbstractConnector] Started ServerConnector@3a022576{SSL,[ssl, http/1.1]}{0.0.0.0:9999}
    2019-09-12 22:23:28,318  INFO  [org.eclipse.jetty.server.Server] Started @12189ms
    2019-09-12 22:23:28,321  INFO  [com.pingidentity.appserver.jetty.PingFederateInit] PingFederate started in 9s:843ms
  ```

8. In a browser, go to `https://localhost:9999/pingfederate/app` to display the PingFederate console.

## Modifying a server profile based on an existing Ping Identity solution installation and using local directories

We'll use a PingFederate installation as an example solution, and we'll use local directories, rather than Github to modify the server profile.

1. Run the PingFederate container. To save any changes you make after the container is running, add the entry `-v /some/local/path:/opt/out` to the `docker run` command. The environment variables `SERVER_PROFILE_URL` and `SERVER_PROFILE_PATH` direct Docker to use the server profile you've modified. For example:

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

7. Enter `docker container logs -f pingfederate` to display the logs as the container starts up. If your server profile modification has been applied, you'll see something like this:

  ```text
    2019-09-12 22:23:28,318  INFO  [org.eclipse.jetty.server.AbstractConnector] Started ServerConnector@3a022576{SSL,[ssl, http/1.1]}{0.0.0.0:9999}
    2019-09-12 22:23:28,318  INFO  [org.eclipse.jetty.server.Server] Started @12189ms
    2019-09-12 22:23:28,321  INFO  [com.pingidentity.appserver.jetty.PingFederateInit] PingFederate started in 9s:843ms
  ```

8. In a browser, go to `https://localhost:9999/pingfederate/app` to display the PingFederate console.
