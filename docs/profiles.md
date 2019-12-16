# Using server profiles

When you deployed the full stack of solution containers in [Get started](evaluate.md), you were employing the server profiles associated with each of our solutions. If you take a look at the [YAML file for the full stack deployment](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/11-docker-compose/03-full-stack/docker-compose.yaml), you'll see entries such as this for each service (solution):

  ```text
  environment:
    - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
    - SERVER_PROFILE_PATH=baseline/pingaccess
  ```
Our [pingidentity-server-profiles](../../pingidentity-server-profiles/README.md) repository indicated by the `SERVER_PROFILE_URL` environment variable, contains the server profiles we use for our deployment examples. The PingAccess profile data is located in the `baseline/pingaccess` directory.
