
# Ping Identity Docker Image - `pingdownloader`

This docker image provides an alpine image to help with the download of
Ping product images and licenses.

## Related Docker Images
- `alpine` - Parent Image

## Usage
### Dowload product
####  Easiest way
  The call below will download the latest available version of <product_name> to `/tmp/product.zip` regardless of which product is requested. This may make it easier to script installations across products.
```shell
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader --product <product_name>
```

#### Keep original file name
If you wish to download the product and keep the original file name, use the `--conserve-name` or `-c` option, like so
```shell
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader --product <product_name>
```

#### Specify version
You may specify the version of the product you wish to download, with the `--version` option. For example:
```shell
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader --product pingdirectory --version 7.3.0.3
```
Note: some product versions available on PingIdentity main download site may not be available for download with this mechanism.

### Obtain evaluation license
If you have obtained a devops user and key, you may obtain evaluation licenses on-demand with the following calls
#### Easiest way
The call below will fetch a license:
```shell
docker run --rm -v /tmp:/tmp --env-file ~/.pingidentity/devops pingidentity/pingdownloader --license --product <product_name>
```
Do note the use of `--env-file` which is used for convenience as a way to pass the `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY` variables to the `pingidentity/pingdownloader` container.

Like for product download, the license file will be written to `/tmp/product.lic` unless the `--conserve-name` option is specified.

#### Specify credentials in line
If you do not persist your PingIdentity Devops information in the default file, you may explicitly pass the values as environment variables:
```shell
docker run --rm -v /tmp:/tmp --env PING_IDENTITY_DEVOPS_USER=<devops email> --env PING_IDENTITY_DEVOPS_KEY=<devops key here> pingidentity/pingdownloader --license --product <product_name>
```

#### Keep original license file name
```shell
docker run --rm -v /tmp:/tmp --env-file ~/.pingidentity/devops pingidentity/pingdownloader --license --product <product_name> --conserve-name
```

#### Specify version
If you need a license specific 

### Options
```shell 
-a, --app-name: the name of the requesting application (Default: pingdownloader) **
-c, --conserve-name: use this option to conserve the original file name. By   default, the downloader will rename the file product.zip
-k, --devops-key: the devops key to use to retrieve a product evaluation license
-l, --license: instructs pindownloader to request an evaluation license instead of downloading the product bits
-m, --metadata-file: the name of the metadata file to use to manage product downloads (Default: gte-bits-repo.json) **
*-p, --product: the name of the product to download. Valid product names currently:
                pingaccess
                pingcentral
                pingdatametrics
                pingdatasync
                pingdatagovernance
                pingdatagovernancepap
                pingdirectory
                pingdirectoryproxy
                pingfederate
-n, --dry-run:	this will cause the URL to be displayed but the the bits not to be downloaded
-r, --repository: the URL of the repository to use to download the metadata and the bits **
-u, --devops-user: the email address used to register for a PingIdentity Devops account
-v, --version: the version of the product to download. by default, the downloader will pull the latest version

**: you should not need to change this unless you are customizing you download or license API calls and work closely with PingIdentity.
```

## Examples
Download the latest PingDirectory
```
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader -p PingDirectory
```

Download a specific version of PingDirectory
```
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader -p PingDirectory -v 7.3.0.0
```

Download a product to /tmp on the host, as opposed to /tmp in the PingDownloader container
```
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader -p PingFederate
```
## Docker Container Hook Scripts
Please go [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/docs/docker-images/pingdownloader/hooks/README.md) for details on all pingdownloader hook scripts

---
This document auto-generated from _[pingdownloader/Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdownloader/Dockerfile)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
