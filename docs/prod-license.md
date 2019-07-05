# Obtain and Use Product Licenses

In order to run the Ping Identity DevOps images, a valid product license is required. There are several ways to obtain a product license to run the images:

#### Evaluation License

* [Obtaining a Ping Identity DevOps User and Key](prod-license.md#obtaining-a-ping-identity-devops-user-and-key)
* [Saving your DevOps User/Key](prod-license.md#saving-your-devops-user-and-key)
* [Using your DevOps User/Key](prod-license.md#using-your-devops-user-and-key)

#### Existing license

* [Use an existing license file \(Current customers\)](prod-license.md#using-an-existing-product-license-file)

## Obtaining a Ping Identity DevOps User and Key

Ping Identity will provide a DevOps Key to any user registered as a developer with Ping Identity. You must follow the steps listed below to obtain a Ping Identity DevOps User and Key

* Ensure you are enrolled in the Ping Identity Developer Program.  Not sure, click the link for [Join developer program](https://www.pingidentity.com/en/account/register.html?type=developer) and follow instructions.
  * If you don't have an account, please create one.
  * Otherwise, sign-in.
  * Your DEVOPS-USER is your email.
  ![](images/PROD_LICENSE_1.png)
* Request your DEVOPS-KEY from the [FORM](https://docs.google.com/forms/d/e/1FAIpQLSdgEFvqQQNwlsxlT6SaraeDMBoKFjkJVCyMvGPVPKcrzT3yHA/viewform).

You should now have a DEVOPS-USER and DEVOPS-KEY.

Example:

* `PING_IDENTITY_DEVOPS_USER=jsmith@example.com`
* `PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2`

## Saving your DevOps User and Key

The best way to save your DevOps User/Key is to use the Ping Identity DevOps utility `setup`. You can run this if you have set up your environment with the `pingidentity-devops-getting-started` GitHub repo. More details on this can be found in that [quickstart](examples/quickstart.md).

Simpy run:

```text
setup
```

and answer the prompts with your DEVOPS User/Key. 

This will place your DEVOPS USER/KEY in to a Ping Identity property file found at
`~/.pingidentity/devops`.  with the following variable names set (see example below).

```text
      PING_IDENTITY_DEVOPS_USER=jsmith@example.com
      PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
```
You can always view these settings with the `denv` command after you've configured them.

## Using your DevOps User and Key

When starting an image, you can provide your devops property file `~/.pingidentity/devops` or using the individual environment variables. The examples provided for standalong and docker compose 
have all be setup to use this property file by default.

For more detail, run the `denv` to get your devops environment information.

### Example with docker run command

An example of running a docker image using the `docker run` command would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

```text
docker run \
           --name pingdirectory \
           --publish 1389:389 \
           --publish 8443:443 \
           --detach \
           --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
           --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
           --env-file ~/.pingidentity/devops \
           pingidentity/pingdirectory
```

### Example with .yaml file

An example of running a docker image using any docker .yaml file would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

>Note: Docker Compose is able to make use of this format.  See next section for example if using
Docker Swarm.

```text
...
  pingdirectory:
    image: pingidentity/pingdirectory
    env_file:
      - ${HOME}/.pingidentity/devops
    environment:
      - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_PATH=getting-started/pingdirectory
...
```

### Example with .yaml file and inline environment variables

An example of running a docker image using any docker .yaml file would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

>Note: Docker Swarm requires this format.  See previous section for example if using
Docker Swarm.

```text
...
  pingdirectory:
    image: pingidentity/pingdirectory
    environment:
      - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_PATH=getting-started/pingdirectory
      - PING_IDENTITY_DEVOPS_USER=jsmith@example.com
      - PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
...
```

## Using an existing Product License file

You can also use an existing valid product license file the product/version combo you are running, by placing them into the proper directory of your server profile. The default server profile location and file name for each product are as follows:

Note: You do not need to do this if you are using your DevOps User/Key. If you have provided license files as part of your server profile and a DevOps User/Key, it will ignore the DevOps User/Key.

* PingFederate - `instance/server/default/conf/pingfederate.lic`
* PingAccess - `instance/conf/pingaccess.lic`
* PingDirectory - `instance/PingDirectory.lic`
* PingDataSync - `instance/PingDirectory.lic`

## Troubleshooting

If you have any quesitons or issues, please contact [devops\_program@pingidentity.com](mailto:devops_program@pingidentity.com).

