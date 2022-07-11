---
title: The PingDownloader Image (Deprecated)
---
# The `PingDownloader` Image (Deprecated)

!!! error "PingDownloader Deprecation"
    Due to internal infrastructure changes to our license server, we no longer provide product installation files through the PingDownloader image. The production installation files are still available to all customers located at [Ping Identity's Downloads Page](https://www.pingidentity.com/en/resources/downloads.html).

`PingDownloader` was an image used to simplify the download process of Ping Identity product installation files and license files.

## How to get Product Installation Files Without PingDownloader

1. Navigate to [Ping Identity's Download webpage](https://www.pingidentity.com/en/resources/downloads.html).

2. Select a Product download page, for example: [PingFederate Download Page](https://www.pingidentity.com/en/resources/downloads/pingfederate.html).

3. Click on the download button for the desired installation method and product version.

   1. If prompted to sign in, please sign in and the download will begin. Alternatively, [Sign In Here](https://www.pingidentity.com/en/account/sign-on.html).

   2. If you do not have a Ping Identity account, you can create one on the [Account Creation Page](https://www.pingidentity.com/en/try-ping.html).

## How to get Product License Files Without PingDownloader

1. Install our command-line utility `pingctl`. Installation steps are described in the utility's [Documentation](https://devops.pingidentity.com/tools/pingctlUtil/).

2. Run `pingctl config` to configure the command line tool with your DevOps User and Key information. See our [Introduction Documentation](https://devops.pingidentity.com/get-started/introduction/) for obtaining and using your DevOps User and Key.

3. Run `pingctl license {product} {version}` to obtain the license file. The `{version}` portion of the command expects the format to be `{major}.{minor}`. For example, the following command retrieves a license for PingFederate 11.0.3: `pingctl license pingfederate 11.0`
