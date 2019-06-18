
# Ping Identity DevOps `pingdirectory` Hook - `189-import-data.sh`
This hook will import data into the PingDirectory if there are data files
included in the server profile data directory.

If a .template file is provided, then makeldif will be run to create the .ldif
file to be imported.

If there are any skipped or rejected entries, an error message will be printed
and the container will exit, unless the environment variable
`PD_IMPORT_CONTINUE_ON_ERROR=true` is provided when the container is run.

---
This document auto-generated from _[pingdirectory/hooks/189-import-data.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectory/hooks/189-import-data.sh)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
