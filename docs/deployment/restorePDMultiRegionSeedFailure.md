# Restoring a Multi Region PingDirectory Deployment After Seed Cluster Failure

The PingDirectory hook scripts rely on the seed server of the seed cluster being available when running in a multi-region environment. This leads to the question of what can be done if the seed region's servers, along with their persistent volumes are lost. This page describes manual steps that can be taken to restore the PingDirectory topology in this case.

Note: these steps are only needed if the seed region is lost _including its persistent volumes_.

In this document, the non-seed region is referred to as the "surviving" region.

## Starting point

Assume the seed region and all of its persistent volumes have been lost. The surviving region will still replicate among itself, but it will not be able to reach the seed region servers even after they are restarted, due to changes to the server certificates caused by the restart.

Running the `status` command on one of the surviving pods, you will see in the output that there are configured servers in the topology that are not reachable:

```
          --- Mirrored Subtrees ---
Base DN               : Write Master                   : Configured      : Outbound        : Inbound         : Failed Write
                      :                                : Peers           : Connections     : Connections     : Operations
----------------------:--------------------------------:-----------------:-----------------:-----------------:----------------
cn=Cluster,cn=config  : N/A (single instance topology) : 0               : 0               : 0               : 0
cn=Topology,cn=config : No Master (data read-only)     : 3               : 1               : 1               : 0
```

You will also see administrative alerts in the output indicating that the mirrored subtree manager can't establish a connection with the servers in the seed region.

## Overview

The key steps to restore the topology in this case are:

1. Force a server in the surviving region to act as master of the topology
2. Remove the unreachable servers from the topology
3. Undo forcing a server to act as master of the topology
4. Ensure any seed region pods are in single-server topologies
5. Use dsreplication enable to add the servers from the refreshed seed region to the topology of the surviving region
6. Use dsreplication initialize-all from a server of the surviving region to update the data across the regions

## Force a server to act as master of the topology

The PingDirectory topology will see that it cannot connect with half the servers and will switch to read-only mode. To allow the changes we need to make to the topology to fix this, exec into one of the pods in the surviving region.

```
kubectl exec -ti example-pingdirectory-0 sh
```

Run the following command to force this pod as master:

```
dsconfig set-global-configuration-prop --set force-as-master-for-mirrored-data:true --no-prompt
```

## Remove the unreachable servers from the topology

Now we must tell the surviving pods that the original seed region pods no longer exist, and that they must be removed from the topology. These commands may take a long time to run, as the `remove-defunct-server` tool will keep trying to connect for up to ten minutes depending on the state of the seed region.

```
remove-defunct-server --ignoreOnline --serverInstanceName example-pingdirectory-1.west --bindDN [bind dn] --bindPassword [bind password]
```

In the above command, replace the --serverInstanceName argument with the instance name of one of the seed region pods. Then repeat the command for each seed region pod's instance name.

This step may differ depending on the state of the seed region. If the seed region is wiped out and is still not available, then you may be prompted during the `remove-defunct-server` process whether you want to retry connecting to a server that was from the failed seed region. Enter "no" and continue when prompted.

If the seed region has been restored and the servers are up by the time you are running this command, then you will likely see the ten minute timeout described above. This is because the servers are available on the same hostnames as before, but their inter-server certificates have changed during the restart. So SSL connections will not be possible, leading to the connection timeout

## Undo forcing a server to act as master of the topology

At this point the pods in the surviving region should now be the only pods in that region's topology - they should no longer be attempting to contact any pod from the failed seed region.

```
          --- Mirrored Subtrees ---
Base DN               : Write Master                   : Configured      : Outbound        : Inbound         : Failed Write
                      :                                : Peers           : Connections     : Connections     : Operations
----------------------:--------------------------------:-----------------:-----------------:-----------------:----------------
cn=Cluster,cn=config  : N/A (single instance topology) : 0               : 0               : 0               : 0
cn=Topology,cn=config : example-pingdirectory-0.east   : 1               : 1               : 1               : 0
```

Exec into the pod that was forced as master in the first step. Run this command to undo the previous change:

```
dsconfig set-global-configuration-prop --set force-as-master-for-mirrored-data:false --no-prompt
```

## Remove the seed servers from their own topology after restart if necessary

If the seed region was completely wiped out and unavailable during the earlier `remove-defunct-server` step, then this step will be necessary. When the seed region comes up again, it will join its servers together in a new topology containing only the seed pods, as it is unaware of the other region.

It is not possible to merge two existing topologies containing more than one server each. We need to split up the restarted seed region pods into individual single-server topologies so that we can add them to the topology of the surviving region.

Exec into one of the seed region pods:

```
kubectl exec -ti example-pingdirectory-0 sh
```

Use remove-defunct-server to split up each server, starting with the highest pod ordinal and working down until ordinal `1`. Once this is done, all seed region pods will be in separate single-server topologies, and we can then add them to the existing topology of the surviving region.

```
remove-defunct-server --ignoreOnline --serverInstanceName example-pingdirectory-1.west --bindDN [bind dn] --bindPassword [bind password]
```


## Add the servers from the refreshed seed region to the topology of the surviving region

At this point the servers in the seed region should be in their own single-server topologies, and the servers in the surviving region should be in a topology containing only the pods in that region.

Now we can re-enable replication between the regions. Run the following command once for each pod in the seed region, updating the `--host1` or `--host2` argument each time to point to the server being enabled in that run. The command can be run from a shell on any pod.

```
dsreplication enable \
    --trustAll \
    --host1 example-pingdirectory-0.example.east.example.com \
    --port1 "${LDAPS_PORT}" \
    --useSSL1 \
    --replicationPort1 "${REPLICATION_PORT}" \
    --bindDN1 "${ROOT_USER_DN}" \
    --bindPasswordFile1 "${ROOT_USER_PASSWORD_FILE}" \
    --host2 example-pingdirectory-0.example.west.example.com \
    --port2 "${LDAPS_PORT}" \
    --useSSL2 \
    --replicationPort2 "${REPLICATION_PORT}" \
    --bindDN2 "${ROOT_USER_DN}" \
    --bindPasswordFile2 "${ROOT_USER_PASSWORD_FILE}" \
    --adminUID "${ADMIN_USER_NAME}" \
    --adminPasswordFile "${ADMIN_USER_PASSWORD_FILE}" \
    --no-prompt --ignoreWarnings \
    --baseDN dc=example,dc=com \
    --noSchemaReplication
```

## Run dsreplication initialize-all from a server of the surviving region

All the pods are now once again in a topology together. Now we need to initialize the seed region with the data from the surviving region. Run the following command, targeting a server in the surviving region with the `--hostname` argument (this indicates which server the data is coming from, so we want to use a server in the surviving region):

```
dsreplication initialize-all \
    --hostname example-pingdirectory-0.example.east.example.com \
    --port 7700 --useSSL \
    --baseDN dc=example,dc=com --adminUID admin \
    --adminPasswordFile /tmp/pw --no-prompt
```

Now we can see from `dsreplication status --showAll` that all the pods are replicating and have matching generation IDs:

```
          --- Replication Status for dc=example,dc=com: Enabled ---
Server                                                                               : Location : Entries : Conflict Entries : Backlog (1) : Rate (2) : A.O.B.C. (3) : Generation ID : Server ID : Replica ID
-------------------------------------------------------------------------------------:----------:---------:------------------:-------------:----------:--------------:---------------:-----------:-----------
example-pingdirectory-0.east (example-pingdirectory-0.example.east.example.com:7700) : east     : 2038    : 0                : 0           : 0        : 0 seconds    : 4105471824    : 19064     : 32073
example-pingdirectory-1.east (example-pingdirectory-1.example.east.example.com:7700) : east     : 2038    : 0                : 0           : 0        : 0 seconds    : 4105471824    : 4444      : 18281
example-pingdirectory-0.west (example-pingdirectory-0.example.west.example.com:7700) : west     : 2038    : 0                : 0           : 0        : 0 seconds    : 4105471824    : 28554     : 13185
example-pingdirectory-1.west (example-pingdirectory-1.example.west.example.com:7700) : west     : 2038    : 0                : 0           : 0        : 0 seconds    : 4105471824    : 2590      : 4761
```

And from `status` we can see all the inbound and outbound connections are functioning as expected:

```
          --- Mirrored Subtrees ---
Base DN               : Write Master                   : Configured      : Outbound        : Inbound         : Failed Write
                      :                                : Peers           : Connections     : Connections     : Operations
----------------------:--------------------------------:-----------------:-----------------:-----------------:----------------
cn=Cluster,cn=config  : N/A (single instance topology) : 0               : 0               : 0               : 0
cn=Topology,cn=config : example-pingdirectory-0.east   : 3               : 3               : 3               : 0
```
