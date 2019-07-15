
# Ping Identity DevOps `pingdirectory` Hook - `80-post-start.sh`
This hook runs after the PingDirectory service has been started and is running.  It
will determine if it is part of a directory replication topology by the presence
of a TOPOLOGY_SERVICE_BAME .  If not present, then replication will not be enabled.  
Otherwise,
it will perform the following steps regarding replication.

- Wait for DNS lookups to work, sleeping until successful
- If my instance is the first one to come up, then replication enablement will be skipped.
- Wait until a successful ldapsearch an be run on (this may take awhile when a bunch of instances are started simultaneiously):
  - my instance
  - first instance in the TOPOLOGY_FILE
- Change the customer name to my instance hostname
- Check to see if my hostname is already in the replication topology.  If it is, then exit
- To ensure a clean toplogy, call 81-repair-toplogy.sh to mend the TOPOLOGY_FILE before replciation steps taken
- Enable replication
- Initialize replication

---
This document auto-generated from _[pingdirectory/hooks/80-post-start.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingdirectory/hooks/80-post-start.sh)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
