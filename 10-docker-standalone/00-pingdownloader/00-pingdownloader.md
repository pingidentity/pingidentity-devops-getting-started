# 00-pingdownloader

## Running PingDownloader Image

A simple example of how to call the pingdownloader docker image

### Help

For help, simply pass the `--help` parameter to the docker run and obtain the usage.

```text
$ docker run --rm pingidentity/pingdownloader --help
Usage: get-bits.sh {options}
    where {options} include:
        *-p, --product:    the name of the product to download
                        one of:
                            pingdirectory
                            pingdatasync
                            pingaccess
                            pingdatagovernance
                            pingdirectoryproxy
                            pingfederate
                            ldapsdk
                            delegator
        -v, --version: the version of the product to download.
                       by default, the downloader will pull the latest version
        -c, --conserve-name: use this option to conserve the original file name
                             by default, the downloader will rename the file product.zip
        -n, --dry-run:    this will cause the URL to be displayed but the
                        the bits not to be downloaded
```

## Dry run

For a dry-run that will simply **output the URL** to get the bits for **pingdirectory** use the following command.

```text
docker run --rm pingidentity/pingdownloader \
       --product pingdirectory \
       --dry-run
```

## Alias the docker run

To make it easier to run the docker command with a oneword command, create the folowing alias. This will:

* `--rm` \| remove the container when complete
* `-v ~/Downloads:/tmp` \| mount a volume in the containers /tmp to the users Download directory

  ```text
  alias pingdownloader='docker run --rm -v ~/Downloads:/tmp pingidentity/pingdownloader'
  ```

## Examples

### Download PingFederate

Download latest PingFederate to your home Downloads folder \(mac\)

```text
# Using the pingdownloader alias defined above

pingdownloader --product pingfederate --conserve-name
```

