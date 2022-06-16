---
title: pingctl Environment and Configuration Variables
---

# Configuration & Environment Variables

Configuration and Environment variables allow users to cache secure and repetitive settings into
a `pingctl` config file.  The default location of the file is `~/.pingidentity/config`.

You can specify a given configuration item in one of three ways: the `pingctl` config file, the user's current environment variables, or through command line arguments.  The order of priority (highest to lowest) is:

* Command-Line argument overrides (when available)
* `pingctl` config file
* Environment variable overrides

## PingOne Variables

The standard **PingOne variables** used by `pingctl` are as follows:

| Variable                             | Description                                                                                                                                         |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| **PINGONE_API_URL**                  | [PingOne API URL](https://apidocs.pingidentity.com/pingone/platform/v1/api/#get-read-external-authentication-status) (i.e. api.pingone.com/v1)      |
| **PINGONE_AUTH_URL**                 | [PingOne Auth URL](https://apidocs.pingidentity.com/pingone/platform/v1/api/#changelog) (i.e. auth.pingone.com, auth.pingone.eu, auth.pingone.asia) |
| **PINGONE_ENVIRONMENT_ID**           | PingOne Environment ID GUID                                                                                                                         |
| **PINGONE_WORKER_APP_CLIENT_ID**     | PingOne Worker App ID GUID with access to PingOne Environment                                                                                       |
| **PINGONE_WORKER_APP_GRANT_TYPE**    | PingOne Worker App Grant Type to use.  Should be one of authorization_code, implicit or client_credential                                           |
| **PINGONE_WORKER_APP_REDIRECT_URI**  | PingOne Worker App available redirect_uri.  Defaults to http://localhost:8000                                                                       |
| **PINGONE_WORKER_APP_CLIENT_SECRET** | PingOne Worker App Secret providing authentication to PingOne Worker App ID GUID                                                                    |

## Legacy ping-devops Variables

Prior to the `pingctl` CLI tool, `ping-devops` was used to help with the management of docker, docker-console, and kustomize deployments (this utility has been deprecated).  In configuring the legacy tool, several variables were used when deploying docker images into different environments.

The legacy variables still supported and managed by `pingctl` are as follows:

| Variable                          | Description                                                                                                             |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **PING_IDENTITY_ACCEPT_EULA**     | Specify `YES` or `NO` to accept [Ping Identity EULA](https://www.pingidentity.com/en/legal/subscription-agreement.html) |
| **PING_IDENTITY_DEVOPS_USER**     | [Ping DevOps User](https://devops.pingidentity.com/get-started/devopsRegistration/)                                     |
| **PING_IDENTITY_DEVOPS_KEY**      | [Ping DevOps Key](https://devops.pingidentity.com/get-started/devopsRegistration/)                                      |
| **PING_IDENTITY_DEVOPS_HOME**     | Home directory/path of your DevOps projects                                                                             |
| **PING_IDENTITY_DEVOPS_REGISTRY** | Default Docker registry from which to pull images                                                                              |
| **PING_IDENTITY_DEVOPS_TAG**      | Default DevOps tag to use for deployments (i.e. 2205)                                                                   |

## pingctl Variables

**Additional variables** honored by `pingctl` are:

| Variable                                   | Description                                                                                                                       |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| **PINGCTL_CONFIG**                         | Location of the `pingctl` configuration file. Set as an environment variable only.  Default: `~/.pingidentity/config`                                               |
| **PINGCTL_DEFAULT_OUTPUT**                 | Specifies default format of data returned. Command-Line arg `-o`. Default: `table`                                            |
| **PINGCTL_DEFAULT_POPULATION**             | Specifies default population to use for PingOne commands. Command-Line arg `-p`. Default: `Default`                           |
| **PINGCTL_OUTPUT_COLUMNS_{resource_type}** | Specify custom format of table csv data to be returned.   Command-Line arg `-c`. See more detail [below](#pingctl_output_columns) |
| **PINGCTL_OUTPUT_SORT_{resource_type}**    | Specify column to use for sorting data.   Command-Line arg `-s`. See more detail [below](#pingctl_output_sort)                               |

## PINGCTL_OUTPUT_COLUMNS

There are two classes of variables provided by `PINGCTL_OUTPUT`:

* `PINGCTL_OUTPUT_COLUMNS_{resource}` - Specifies the columns to display whenever a `pingctl pingone get {resource}` command is used.

    Same as the `-c` option on the command-line (see [pingctl pingone get](../tools/commands/pingone.md) command).

    Format of value should be constructed with `HeadingName:jsonName,HeadingName:jsonName`.  The best way to understand is by looking at the example of the default `USERS` resource:

    !!! note "Example PINGCTL_OUTPUT_COLUMNS_USERS setting and output"
        ```
        PINGCTL_OUTPUT_COLUMNS_USERS=LastName:name.family,FirstName:name.given
        ```

       Setting the above will generate output similar to:

        ```
        $ pingctl pingone get users
        LastName     FirstName
        --------     ---------
        Badham       Antonik
        Agnès        Enterle
        --
        2 'USERS' returned
        ```

        Alternatively, you can use the `-c` option as a command-line argument:

        ```
        $ pingctl pingone get users -c "LastName:name.family,FirstName:name.given,Username:username"
        LastName     FirstName    Username
        --------     ---------    --------
        Badham       Antonik      antonik_adham
        Agnès        Enterle      enterle_agnès
        --
        2 'USERS' returned
        ```

## PINGCTL_OUTPUT_SORT

* `PINGCTL_OUTPUT_SORT_{resource}` - specifies the column on which to sort.

    Same as the `-s` option on the command-line (see [pingctl pingone get](../tools/commands/pingone.md) command).

    Format of the value should be constructed with `jsonName`.  The name must be one of the entries in `PINGCTL_OUTPUT_COLUMNS_{resource}`.

    !!! note "Example PINGCTL_OUTPUT_SORT_USERS setting and output"
        ```
        PINGCTL_OUTPUT_SORT_USERS=name.family
        ```

        Setting the above will generate output similar to the following (note that the LastName (name.family) is sorted):

        ```
        $ pingctl pingone get users
        LastName     FirstName
        --------     ---------
        Agnès        Enterle
        Badham       Antonik
        --
        2 'USERS' returned
        ```

        Alternatively, you can use the `-s` option as a command-line argument:

        ```
        $ pingctl pingone get users -s "name.given"
        LastName     FirstName    Username
        --------     ---------    --------
        Agnès        Enterle      enterle_agnès
        Badham       Antonik      antonik_badham
        --
        2 'USERS' returned
        ```
