---
title: Assigning a Provisioner Node ID for PingFederate Pods
---
# Assigning a Provisioner Node ID for PingFederate Pods
The PingFederate provisioner node id is set in the run.properties file used to configure the server. This value is used to set up [failover for provisioning](https://docs.pingidentity.com/bundle/pingfederate-111/page/rwx1564003031130.html).

When using failover, each provisioning server must be given a unique index. By default with no server profile, the `PF_PROVISIONER_NODE_ID` environment variable is used to set the node id, with a default value of 1.

If it is necessary to set node ids for PingFederate servers, a StatefulSet can be used to provide consistent hostnames for individual Pods. The node id can then be parsed from these hostnames.

!!! warning
    The use of a StatefulSet instead of a Deployment for PingFederate has some consequences. In particular, updates to the StatefulSet will be done as a rolling updates, which can increase the time needed for an update.

In the Pod spec for the StatefulSet:
```
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
```

Then, a hook script can be used to parse the pod ordinal, which can then be set as the node id. Note that this will overwrite the default `PF_PROVISIONER_NODE_ID` value.

In your server profile, create a `02-get-remote-server-profiles.sh.post` script to update the environment variable:
```
#!/usr/bin/env sh
. "${HOOKS_DIR}/pingcommon.lib.sh"

# Parse the pod ordinal
PF_PROVISIONER_NODE_ID=${POD_NAME##*-}

# Add one to the ordinal so that node id starts at 1 instead of 0
PF_PROVISIONER_NODE_ID=$((PF_PROVISIONER_NODE_ID+1))

# Save the node id to the environment used by the hook scripts
export_container_env PF_PROVISIONER_NODE_ID
```

Ensure your server profile uses this environment variable if you are providing a custom `instance/bin/run.properties.subst` file:
```
provisioner.node.id=${PF_PROVISIONER_NODE_ID}
```
    