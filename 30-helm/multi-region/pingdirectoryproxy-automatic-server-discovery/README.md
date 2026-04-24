# PingDirectoryProxy automatic server discovery when deploying PingDirectory across multiple clusters

When [deploying directory pods across multiple Kubernetes clusters](https://devops.pingidentity.com/deployment/deployPDMultiRegion/), some additional configuration needs to be added to allow proxy to join the directory topology and enable automatic server discovery.

Essentially, the proxy workload will need to have similar variables and network access as the directory workload (see the directory multi-cluster doc linked above). In addition, proxy will need the right variables set to join the topology and the right wait-for logic to wait for the other servers to be ready before starting and joining the topology.

The `pingdirectoryproxy-automatic-server-discovery/pingdirectoryproxy` profile used by these examples now includes a startup hook for multi-region PingDirectoryProxy deployments.

- `K8S_CLUSTER` becomes the local proxy location.
- By default, every non-local cluster in `K8S_CLUSTERS` is created as a peer location if needed and added to the local location as a `preferred-failover-location`.
- Set `PREFERRED_FAILOVER_LOCATIONS` to use an explicit ordered subset of the non-local clusters in `K8S_CLUSTERS`.
- The location configuration is applied again on restart so the local proxy location converges back to the declared order.

These examples still require the normal topology join variables and wait-for sequencing. If you scale down proxies and want them removed from the topology registry before shutdown, keep the `preStop` guidance from the automatic discovery documentation aligned with your deployment.

Required proxy environment variables for this example:

- `SERVER_PROFILE_PATH: pingdirectoryproxy-automatic-server-discovery/pingdirectoryproxy`
- `JOIN_PD_TOPOLOGY: "true"`
- `K8S_CLUSTERS`
- `K8S_CLUSTER`
- `K8S_SEED_CLUSTER`
- `PINGDIRECTORY_HOSTNAME`
- `PINGDIRECTORY_LDAPS_PORT`
- `SKIP_WAIT_FOR_DNS: "true"` when the advertised pod hostnames resolve to external LoadBalancer
  addresses rather than pod IPs.

Optional proxy environment variable:

- `PREFERRED_FAILOVER_LOCATIONS`: ordered list of non-local clusters from `K8S_CLUSTERS` to use as failover locations for the local proxy location.

The Helm yaml files in this directory demonstrate how to configure this using the `ping-devops` Helm chart. The `west.yaml` file is expected to be deployed as the seed cluster, with the Helm release given the name `west`. The `east.yaml` file is expected to be deployed as the second cluster, with the Helm release given the name `east`.
