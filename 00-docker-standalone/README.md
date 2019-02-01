# Purpose
The goal of the contents of this directory is to demonostrate how to use the docker images in the PingIndentity lineup on docker, independent of any other framework. It should be a journey to take step-by-step in the order of the sub-directories names.

## Contents

* `00-pingdownloader/` - utility container used for downloading Ping Identity product artifacts
* `01-pingdirectory/` - conveneince configurations for running PingDirectory
* `02-pingfederate/` - stand-alone PingFederate container
* `03-pingaccess/` - stand-alone PingAccess container
* `10-pingdataconsole/` - stand-alone OingDataConsole container
* `99-logging/` - sample technique to aggregate log logs across containers
* `FF-shared/` - shared environment variables used in above containers
