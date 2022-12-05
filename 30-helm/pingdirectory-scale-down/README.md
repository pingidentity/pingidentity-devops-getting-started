# PingDirectory Scale Down Example
When scaling down a PingDirectory StatefulSet, the servers remaining in the topology are not automatically aware that the removed Pods are gone permanently. The remaining servers will continue to attempt to connect with the removed Pods until they are told that those Pods have left the topology, via the `remove-defunct-server` command line tool.

The PingDirectory image includes a `90-shutdown-sequence.sh` hook script that includes logic to remove a Pod from the topology with `remove-defunct-server`. The Kubernetes `preStop` lifecycle hook can be used to run this script when a Pod stops.

Running this script each time a Pod comes down (such as restarts for changed configuration) would unnecessarily increase the amount of time it takes for the Pod being restarted to become ready. The Pod would have to rejoin the topology and re-initialize replication on each restart. Because of this, it is better to only run the `90-shutdown-sequence.sh` hook script during a scale down.

The Helm examples in this directory show how to enable the `preStop` hook, scale down a PingDirectory StatefulSet, and disable the hook once the scale-down is done.

Prior to release `2211` of the PingDirectory Docker image, there was a defect in `90-shutdown-sequence.sh` that could cause the `0` ordinal server of a StatefulSet (the "seed" server) to be separated from the rest of the topology. These examples should only be used with version `2211` or later.

## Steps
First, deploy a PingDirectory StatefulSet with three replicas, with no preStop hook enabled.
```
helm upgrade --install scale-down-example pingidentity/ping-devops -f 01-original.yaml
```

Now, it's time to scale down the StatefulSet. First, the preStop hook must be enabled - this will require rolling the pods.
```
helm upgrade --install scale-down-example pingidentity/ping-devops -f 02-enable-prestop.yaml
```

Finally, once the pods are ready again, you can scale down the StatefulSet and disable the preStop hook in one step.
```
helm upgrade --install scale-down-example pingidentity/ping-devops -f 03-scaled-down.yaml
```

The remaining servers will no longer attempt to connect to the server that was removed.

The preStop hook can be disabled in two ways. It can be removed from the Helm values yaml file, or it can be disabled by setting the `SKIP_SHUTDOWN_SEQUENCE` environment variable to `true`. This will cause the `90-shutdown-sequence.sh` hook to immediately exit when called, without removing any server from the topology.
