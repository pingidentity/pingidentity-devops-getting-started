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


## Commercial Support
These images are not currently considered stable and are subject to changes without notification.
Please contact devops_program@pingidentity.com for details


## Copyright
Copyright © 2019 Ping Identity. All rights reserved.