#!/bin/sh 
# A simple example of how to call the pingdownloader image to get the PingDirectory 7.2.0.0 bits

###
### For help, use this
docker pull pingidentity/pingdownloader
docker run --rm -i pingidentity/pingdownloader --help

###
### For a dry-run that will simply output the URL to get the bits
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory --dry-run

###
### Other examples
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingfederate -c
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingaccess -c
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory -c
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectoryproxy -c
