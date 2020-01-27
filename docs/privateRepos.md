# Using private GitHub repositories

Generally, you'll not want your server profiles to be public, and will instead want to persist your server profiles in private GitHub repositories. To use server profiles with private repositories, you'll need to generate an access token in GitHub, then specify the access token in the URL you assign to the `SERVER_PROFILE_URL` environment variable in your YAML files.

## Create a Github access token

1. In Github, go to `Settings` --> `Developer Settings` --> `Personal access tokens`.
2. Click `Generate new token` and assign the token a name.
3. Grant the token priviledge to the `repo` group. For example:

![TCP_XML S3 Cluster Variables](../images/GITHUB_PERSONAL_ACCESS_TOKEN.png)

4. Scroll to the bottom of the page and click `Generate Token`.

> Copy the token to a secure location. You'll not be able to view the token again.

## Using the token in YAML

To use the token in your YAML file, include it in the `Server_Profile` environment variable using this format:

    ```text
    https://<github-username>:<github-token>@github.com/<your-repository>.git
    ```

For example:

    `SERVER_PROFILE_URL=https://github_user:zqb4famrbadjv39jdi6shvl1xvozut7tamd5v6eva@github.com/pingidentity/server_profile.git`



