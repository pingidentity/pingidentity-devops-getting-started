# Purpose
A simple example of how to call the pingdownloader image

## Help
For help, use this
`docker run --rm -i pingidentity/pingdownloader --help`

# Dry run
For a dry-run that will simply output the URL to get the bits
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory --version 7.2.0.0 --dry-run`

# Examples
## Download PingFederate 9.2 to your home Downloads folder (mac)
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingfederate --version 9.2.0 -c`

## Download PingAccess 5.2
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingaccess --version 5.2.0 -c`

## Download PingDirectory 7.2
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory --version 7.2.0.0 -c`

## Download PingDirectoryProxy
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectoryproxy --version 7.2.0.0 -c`

## Download PingDataSync
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdatasync --version 7.2.0.0 -c`
