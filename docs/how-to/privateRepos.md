---
title: Using Private Git Repositories
---
# Using Private Git Repositories

In general, you don't want your server profiles to be public. Instead, you should persist your server profiles in private git repositories.

To use server profiles with private repositories, you must either:

* Pull using HTTPS
* Pull using SSH

For HTTPS with GitHub:

1. Generate an access token in GitHub.
2. Specify the access token in the URL you assign to the `SERVER_PROFILE_URL` environment variable in your YAML files.

For SSH:

* Include your keys and known hosts in the image under `/home/ping/.ssh`.

## Cloning from GitHub using HTTPS

### Creating a GitHub Access Token

1. In GitHub, go to `Settings` --> `Developer Settings` --> `Personal access tokens`.
1. Click `Generate new token` and assign the token a name.
1. Grant the token privilege to the `repo` group.

    > Copy the token to a secure location. You won't be able to view the token again.

1. At the bottom of the page, click `Generate Token`.

### Using The Token In YAML

To use the token in your YAML file, include it in the `SERVER_PROFILE_URL` environment variable using this format:

```html
https://<github-username>:<github-token>@github.com/<your-repository>.git
```

For example:

```yaml
SERVER_PROFILE_URL=https://github_user:zqb4famrbadjv39jdi6shvl1xvozut7tamd5v6eva@github.com/pingidentity/server_profile.git
```

### Using Git Credentials in Profile URL

Typically, variables in a `SERVER_PROFILE_URL` string aren't replaced. However, certain Git user and password variables can be replaced.

* To substitute for the user and password variables using values defined in your YAML files, include either or both `${SERVER_PROFILE_GIT_USER}` and `${SERVER_PROFILE_GIT_PASSWORD}` in your server profile URL. For example:

    ```sh
    SERVER_PROFILE_URL=https://${SERVER_PROFILE_GIT_USER}:${SERVER_PROFILE_GIT_PASSWORD}@github.com/pingidentity/server_profile.git
    ```

* When using layered server profiles, each layer can use the base user and password variables, or you can define values specific to that layer.

    For example, for a `license` server profile layer, you can use the `SERVER_PROFILE_LICENSE_GIT_USER` and `SERVER_PROFILE_LICENSE_GIT_PASSWORD` variables, and substitute for those variables using values defined in your YAML files.

## Cloning using SSH

* To clone using SSH, you can mount the necessary keys and known hosts files using a volume at `/home/ping/.ssh`, the home directory of the default user in our product images.
* To clone from GitHub, you must add the necessary SSH keys to your account through the account settings page.
