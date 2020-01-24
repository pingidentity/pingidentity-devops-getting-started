# Using private GitHub repositories

Generally, you'll not want your server profiles to be public, and will instead want to persist your server profiles in private GitHub repositories. To use server profiles with private repositories, you'll need to generate GitHub an access token, and specify the access token in the URL you assign to the `SERVER_PROFILE_URL` environment variable in your YAML files.

## Create a Github access token

1. In Github, go to '**Settings**' --> '**Developer Settings**' --> '**Personal access tokens**'
* From `Personal access tokens' click the button to '**Generate new token**'
* Given the token a name
* Grant the token priviledge to the **repo** group

![TCP_XML S3 Cluster Variables](../images/GITHUB_PERSONAL_ACCESS_TOKEN.png)

* Scroll to the bottom and click '**Generate Token**'

```Note: Copy the token to a secure location as you will not be able to view the token again.```


## Using the token in YAML

To use the token within your YAML file, update the Server Profile to use the following format

* https://GIT_HUB_USERNAME:GITHUB_TOKEN@github.com/PATH_TO_REPO.git

### Example URL

* SERVER_PROFILE_URL=https://github_user:zqb4famrbadjv39jdi6shvl1xvozut7tamd5v6eva@github.com/pingidentity/server_profile.git



