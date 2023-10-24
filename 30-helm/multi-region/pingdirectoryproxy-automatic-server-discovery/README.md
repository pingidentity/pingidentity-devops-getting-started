# PingDirectoryProxy automatic server discovery when deploying PingDirectory across multiple clusters

When [deploying directory pods across multiple Kubernetes clusters](https://devops.pingidentity.com/deployment/deployPDMultiRegion/), some additional configuration needs to be added to allow proxy to join the directory topology and enable automatic server discovery.

Essentially, the proxy workload will need to have similar variables and network access as the directory workload (see the directory multi-cluster doc linked above). In addition, proxy will need the right variables set to join the topology and the right wait-for logic to wait for the other servers to be ready before starting and joining the topology.

The Helm yaml files in this directory demonstrate how to configure this using the `ping-devops` Helm chart. The `west.yaml` file is expected to be deployed as the seed cluster, with the Helm release given the name `west`. The `east.yaml` file is expected to be deployed as the second cluster, with the Helm release given the name `east`.
