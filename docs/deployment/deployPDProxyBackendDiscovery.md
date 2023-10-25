# Deploy PingDirectoryProxy and PingDirectory with automatic backend discovery

Since version 8.3 of PingDirectoryProxy, proxy servers can use [automatic server discovery](https://docs.pingidentity.com/r/en-us/pingdirectory-93/pd_proxy_auto_server_discovery) to determine the backend PingDirectory servers, rather than adding those servers individually to the configuration. This page describes how to use this feature with the PingDirectory and PingDirectoryProxy Docker images and the ping-devops Helm chart

The directory and proxy Docker images added support for this feature as of the 2310 release, and the ping-devops Helm chart added support in release `0.9.20`.

## Configuring the proxy instance to join the directory topology

The first step of enabling automatic server discovery is to have the proxy server(s) join the topology of replicating directory servers. To enable this, the proxy Docker image supports the following variables:

- `JOIN_PD_TOPOLOGY`: Set to `true` to add the proxy instance to a directory topology
- `PINGDIRECTORY_HOSTNAME`: The hostname of the directory server to connect with when joining the topology
- `PINGDIRECTORY_LDAPS_PORT`: The LDAPS port of the directory server to connect with when joining the topology

If all three of these variables are set, the proxy server will join the designated topology after the server starts up.

### Waiting for the directory topology to be ready before starting

The designated directory server must be running for the proxy server to join the topology. To ensure directory is running before proxy attempts to join, a `wait-for` can be used.

For example, using the ping-devops Helm chart, the following values yaml instructs proxy to wait until the second `pingdirectory` pod is running before starting and attempting to join the topology. "releasename" can be replaced with the Helm release name.

```
initContainers:
  wait-for-pd:
    name: wait-for-pd
    image: pingidentity/pingtoolkit:2309
    command: ['sh', '-c', 'echo "Waiting for PingDirectory..." && wait-for releasename-pingdirectory-1.releasename-pingdirectory-cluster:1636 -t 300 -- echo "PingDirectory running"']

pingdirectory:
  container:
    replicaCount: 2
  enabled: true
  envs:
    LOAD_BALANCING_ALGORITHM_NAMES:dc_example_dc_com-fewest-operations;dc_example_dc_com-failover

pingdirectoryproxy:
  includeInitContainers:
  - wait-for-pd
  container:
    replicaCount: 1
  enabled: true
  envs:
    JOIN_PD_TOPOLOGY: "true"
    PINGDIRECTORY_HOSTNAME: releasename-pingdirectory-0.releasename-pingdirectory-cluster
    PINGDIRECTORY_LDAPS_PORT: "1636"
```

## Configuring automatic server discovery on proxy using a server profile

The proxy server must also be configured via `dsconfig` to enable automatic server discovery. For an example, see the automatic server discovery [server profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pingdirectoryproxy-automatic-server-discovery).

## Setting load balancing algorithm names on the directory instances

To associate directory servers with the load balancing algorithms configured on the proxy server, the `load-balancing-algorithm-name` property must be set. This can be done with the `LOAD_BALANCING_ALGORITHM_NAMES` environment variable in the directory Docker image. When using multiple algorithm names, separate them with a `;`. See the above yaml snippet for an example.

## Removing the proxy server from the topology on pod shutdown

By default the proxy server will rejoin the topology automatically on restarts. In the `ping-devops` Helm chart, proxy does not use a persistent volume, so it will fully restart and rejoin the topology during each startup.

Another option, which allows for scaling down the number of proxy servers, is adding a `preStop` hook to remove the proxy server from the topology. In general this can cause slowness because it will run whenever a pod stops, but it ensures that scaling down the number of proxies does not leave outdated servers in the topology registry. For example:

```
pingdirectoryproxy:
  container:
    # Add the preStop hook to run the remove-defunct-server tool
    lifecycle:
      preStop:
        exec:
          command:
          - /opt/staging/hooks/90-shutdown-sequence.sh
```

## Automatic server discovery when directory and proxy pods are split across multiple clusters

When [deploying directory pods across multiple Kubernetes clusters](./deployPDMultiRegion.md), some additional configuration needs to be added to allow proxy to join the directory topology and enable automatic server discovery.

Essentially, the proxy workload will need to have similar variables and network access as the directory workload (see the directory multi-cluster doc linked above). In addition, proxy will need the right variables set to join the topology and the right wait-for logic to wait for the other servers to be ready before starting and joining the topology.

See [here](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/30-helm/multi-region/pingdirectoryproxy-automatic-server-discovery) for a complete Helm example.

