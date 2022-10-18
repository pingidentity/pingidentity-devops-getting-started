# Entry balancing example
The yaml files in this directory provide an example entry balancing deployment. The hostnames used in these examples will need to be modified based on the external DNS being used. The yaml files can be used to deploy two PingDirectory replication sets and a PingDirectoryProxy instance that manages traffic to those PingDirectory instances.

Entry balancing is only supported with version `2210` or later of the PingDirectory and PingDirectoryProxy Docker images.

The PingDirectory installations can run [across multiple clusters](https://devops.pingidentity.com/deployment/deployPDMultiRegion/). They can also be installed in the same cluster for testing.

## Example deployment of these Helm values files
First, deploy the two replication sets

`helm upgrade --install set1 pingidentity/ping-devops -f set1.yaml`

`helm upgrade --install set2 pingidentity/ping-devops -f set2.yaml`

Then, deploy the proxy

`helm upgrade --install proxy pingidentity/ping-devops -f proxy.yaml`

After all the servers are up, if the hostnames are set correctly and servers can reach each other, then you should see the load balancing algorithms defined and available when looking at the output of `status` on the proxy server:

```
          --- Load-Balancing Algorithms ---
Name                                                      : Status    : # Available : # Degraded : # Unavailable
----------------------------------------------------------:-----------:-------------:------------:--------------
dc_example_dc_com-failover                                : AVAILABLE : 6           : 0          : 0
dc_example_dc_com-fewest-operations                       : AVAILABLE : 6           : 0          : 0
ou_people_dc_example_dc_comServer_Set_1-failover          : AVAILABLE : 3           : 0          : 0
ou_people_dc_example_dc_comServer_Set_1-fewest-operations : AVAILABLE : 3           : 0          : 0
ou_people_dc_example_dc_comServer_Set_2-failover          : AVAILABLE : 3           : 0          : 0
ou_people_dc_example_dc_comServer_Set_2-fewest-operations : AVAILABLE : 3           : 0          : 0
```

You can now route traffic to the proxy server, which will distribute the traffic among the PingDirectory instances.
