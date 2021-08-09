---
title:  The ldap-sdk-tools utility
---
# The `ldap-sdk-tools` utility

The `ldap-sdk-tools` Docker image gives you easy access to our LDAP Client SDK tools for use with PingDirectory.

For complete documentation, see the [`pingidentity/ldapsdk` repository](https://github.com/pingidentity/ldapsdk).

## Setting up the utility

1. From your local `pingidentity-devops-getting-started` directory, enter:

    ```sh
    ./ldapsdk
    ```

    When you run the `ldapsdk` script for the first time, you're prompted to configure your settings.

    To edit the settings in the future, enter:

    ```sh
     ldapsdk configure
   ```

1. To start the `ldap-sdk-tools` Docker image, enter:

    ```sh
    docker run  -it --rm  --network pingnet  pingidentity/ldap-sdk-tools:latest
    ```

1. To list the available tools, enter `ls`
