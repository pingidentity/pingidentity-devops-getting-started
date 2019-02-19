#!/bin/sh 
# A simple example of how to call the pingdownloader image to get the PingDirectory 7.2.0.0 bits

###
### For help, use this
docker run --rm -i pingidentity/pingdownloader --help

###
### For a dry-run that will simply output the URL to get the bits
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory --version 7.2.0.0 --dry-run

###
### Other examples
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingfederate --version 9.2.0 -c
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingaccess --version 5.2.0 -c
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectory --version 7.2.0.0 -c
#docker run --rm -i -v ~/Downloads:/tmp pingidentity/pingdownloader --product pingdirectoryproxy --version 7.2.0.0 -c
