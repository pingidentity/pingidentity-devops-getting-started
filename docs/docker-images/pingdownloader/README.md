
# Ping Identity Docker Image - `pingdownloader`

This docker image provides an alpine image to help with the download of
Ping product images and licenses.

## Related Docker Images
- `alpine` - Parent Image

## Usage
```shell
docker run pingidentity/pingdownloader -p <product_name>
```
### Options
```shell
*-p, --product {product-name}    The name of the product bits/license to download
   
-v, --version {version-num}      The version of the product bits/license to download.
                                 by default, the downloader will pull the 
                                 latest version

-u, --devops-user {devops-user}  Your Ping DevOps Username
                                 Alternately, you may pass PING_IDENTITY_DEVOPS_USER
                                 environment variable

-k, --devops-key {devops-key}    Your Ping DevOps Key
                                 Alternately, you may pass PING_IDENTITY_DEVOPS_KEY
                                 environment variable

-a, --devops-app {app-name}      Your App Name

-r, --repository                 The URL of the repository to use to get the bits

-m, --metadata-file              The file name with the repository metadata


For product downloads:

-c, --conserve-name              Use this option to conserve the original 
                                 file name by default, the downloader will
                                 rename the file product.zip

-n, --dry-run:                   This will cause the URL to be displayed 
                                 but the the bits not to be downloaded

--verify-gpg-signature           Verify the GPG signature. The bits are removed in
                                 the event verification fails


For license downloads:

*-l, --license                   Download a license file

```
## Examples
Download the latest PingDirectory
```
docker run pingidentity/pingdownloader -p PingDirectory
```

Download a specific version of PingDirectory
```
docker run pingidentity/pingdownloader -p PingDirectory -v 7.3.0.0
```

Download a product to /tmp on the host, as opposed to /tmp in the PingDownloader container
```
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader -p PingFederate
```
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdownloader/hooks/README.md) for details on all pingdownloader hook scripts

---
This document auto-generated from _[pingdownloader/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdownloader/Dockerfile)_

Copyright (c) 2020 Ping Identity Corporation. All rights reserved.
