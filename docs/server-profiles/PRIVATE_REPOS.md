# Private GitHub Repos

Most often you will not want to expose your server profiles publically to all users but rather persist your server profiles in private GitHub repositories. In this document, we'll cover how to generate GitHub access tokens and how to update your YAML files to access private repos.

## Create an Access Token

### In GitHub: ###

* Navigate to '**Settings**' -> '**Developer Settings**' -> '**Personal access tokens**'
* From `Personal access tokens' click the button to '**Generate new token**'
* Given the token a name
* Grant the token priviledge to the **repo** group

![TCP_XML S3 Cluster Variables](../images/GITHUB_PERSONAL_ACCESS_TOKEN.png)

* Scroll to the bottom and click '**Generate Token**'

```Note: Copy the token to a secure location as you will not be able to view the token again.```


## Using the token

To use the token within your YAML file, update the Server Profile to use the following format

* `https://GIT_HUB_USERNAME:GITHUB_TOKEN@github.com/PATH_TO_REPO.git`

### Example URL ###

* SERVER_PROFILE_URL=`https://github_user:zqb4famrbadjv39jdi6shvl1xvozut7tamd5v6eva@github.com/pingidentity/server_profile.git`



