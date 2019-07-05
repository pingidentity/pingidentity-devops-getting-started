
# Ping Identity DevOps `pingdatacommon` Hook - `182-template-to-ldif.sh`
This hook will import data into the PingDirectory if there are data files
included in the server profile data directory.

If a .template file is provided, then makeldif will be run to create the .ldif
file to be imported.

To be implemented by the downstream product (i.e. pingdirectory)

---
This document auto-generated from _[pingdatacommon/hooks/182-template-to-ldif.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdatacommon/hooks/182-template-to-ldif.sh)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
