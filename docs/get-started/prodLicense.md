---
title: DevOps Product Licenses
---
# DevOps Product Licenses

To run the Ping Identity DevOps images, you must have a valid product license. You can use either of the following licenses for DevOps images.

#### Evaluation License

When you register for Ping Identity's DevOps program, you are issued credentials that automate the process of retrieving an evaluation product license.

!!! warning "Evaluation License"
    Evaluation licenses are short lived (30 days) and **must not** be used in production deployments.

Evaluation licenses can only be used with images published in the last 90 days.
If you want to continue to use an image that was published more than 90 days ago, you must obtain a product license.
After you have a product license for the product and version of the more-than-90-days-old image, follow the instructions to [mount the product license](../how-to/existingLicense.md).

* [Using your DevOps User/Key](#using-your-devops-user-and-key)

#### Existing License

* [Mount Existing Product License](../how-to/existingLicense.md)

## Using Your DevOps User and Key

When starting an image, you can provide your DevOps property file `~/.pingidentity/devops` or using the individual environment variables.

>The examples provided for docker-compose are set up to use this property file by default.

For more details, run the `ping-devops info` to view your DevOps environment information.

### Example Docker Run Command

The following example shows running a Docker image using the `docker run` command.

```sh
docker run \
  --name pingdirectory \
  --publish 1389:1389 \
  --publish 8443:1443 \
  --detach \
  --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
  --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
  --env-file ~/.pingidentity/devops \
  pingidentity/pingdirectory
```

### Example YAML file

The following example shows running a Docker image using any Docker .yaml file.

```yaml
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

### Example Inline Env Variables

This example shows running a Docker image using any Docker .yaml file where you specify inline environment variables. \(See the two environment variables starting with **PING\_IDENTITY\_DEVOPS**\).

```yaml
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

