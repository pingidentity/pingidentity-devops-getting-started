# Ping Downloader
Docker image to download Ping Identity products

## Usage
```shell
docker run pingidentity/pingdownloader -p <product_name>
```
### Options
```shell 
-v, --version: the version of the product to download. by default, the downloader will pull the latest version

-c, --conserve-name: use this option to conserve the original file name. By   default, the downloader will rename the file product.zip

-n, --dry-run:	this will cause the URL to be displayed but the the bits not to be downloaded

```
## Examples
Download the latest PingDirectory
```
docker run pingidentity/pingdownloader -p PingDirectory
```

Download a specific version of PingDirectory
```
docker run pingidentity/pingdownloader -p PingDirectory -v 7.2.0.1
```

Download a product to /tmp on the host, as opposed to /tmp in the PingDownloader container
```
docker run --rm -v /tmp:/tmp pingidentity/pingdownloader -p PingFederate
```



## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details


## Copyright
Copyright © 2019 Ping Identity. All rights reserved.