---
title: The pingctl Utility
---
# The `pingctl` Utility

`pingctl` is our general DevOps command-line utility.

## Dependent Utilities

To perform all of its operations, `pingctl` has a dependency on the following utilities:

* openssl
* base64
* kubectl
* envsubst
* jq
* jwt

## Installation and Upgrades

Using Homebrew to install `pingctl` on MacOS, Windows via [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install), or Linux.

1. To install, enter:

    ```sh
    brew install pingidentity/tap/pingctl
    ```

1. To upgrade, enter:

    ```sh
    brew upgrade pingidentity/tap/pingctl
    ```

1. To check for upgrades, run the following command.

    !!! note "Check regularly"
        Check for upgrades regularly.

    ```sh
    pingctl version
    ```

    The dependent utilities for `pingctl` are also installed or upgraded during this process.

Using sh to install `pingctl` on Linux and WSL.

1. To install or upgrade, enter:
    ```sh
    curl -sL https://bit.ly/pingctl-install | sh
    ```

1. Ensure you have the dependent utilities for `pingctl` installed.

## Usage

    pingctl <command> [options]

    Available Commands:
        info            Print pingctl config
        config          Manage pingctl config
        version         Version Details and Check
        clean           Remove ~/.pingidentity/pingctl

        kubernetes      Kubernetes Tools
        license         Ping Identity Licensing Tools
        pingone         PingOne Tools

Use `pingctl` for info on available commands.

Use `pingctl <command>` for info on a specific command.

## Options

   -h

Provide usage details.

## Available Commands

* [kubernetes](commands/kubernetes.md)
* [license](commands/license.md)
* [pingone](commands/pingone.md)
* info

    Provides a summary of variables defined with pingctl.

* config

    Provides an interactive process in which the user can provide all the `pingctl` standard
    variables (i.e. PingOne and Ping DevOps) as well as custom variables

* version

    Displays the current version of the tool, and checks to see if an update is available.

* clean

    Cleans the cached pingctl work directory containing the latest PingOne Access Token
