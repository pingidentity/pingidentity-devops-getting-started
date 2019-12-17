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
  * Create your own server profiles based on existing Ping Identity solution installations in your organization.

## Adding or changing environment variables

  1. Select any environment variables to add from either the [Docker image directory](https://pingidentity-devops.gitbook.io/devops/docker-images) for the solution-specific environment variables, or the [PingBase image directory](https://pingidentity-devops.gitbook.io/devops/docker-images/pingbase) for the environment variables common to all of our solutions.
  2. Select the solution whose profile you want to modify from the `baseline`, `getting-started`, or `simple-sync` directories in the [server profiles repository](../../pingidentity-server-profiles).
  3. Open the `env_vars` file associated with the solution and add any of the environment variables you've selected, or change the existing environment variables to fit your purpose.

## Creating a server profile based on an existing Ping Identity solution installation

  1. 
