# Purpose
A simple example of how to call the pingdownloader image

## Help
For help, use this
`docker run --rm -i pingidentity/pingdownloader --help`

# Dry run
For a dry-run that will simply output the URL to get the bits
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory --dry-run`

# Examples
## Download latest PingFederate to your home Downloads folder (mac)
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingfederate -c`

## Download latest PingAccess
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingaccess -c`

## Download latest PingDirectory
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory -c`

## Download latest PingDirectoryProxy
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectoryproxy -c`

## Download latest PingDataSync
`docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdatasync -c`
