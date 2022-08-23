# Deploy PingFederate Across Multiple Kubernetes Clusters

This section will discuss deploying a single PingFederate cluster that spans across multiple Kubernetes clusters.

Having PingFederate in multiple regions doesn't always mean that spanning a single PingFederate cluster across multiple Kubernetes clusters is necessary or optimal.
This scenario makes sense when you have:

* Traffic that can cross between regions at any time. (us-west and us-east, and users may be routed to either)
* Configuration that needs to be the same in multiple regions **and** no reliable automation to ensure that

If all configuration changes are delivered via pipeline, and traffic wouldn't cross-regions, having separate PingFederate clusters can work.

!!! note
    The set of pre-requisites required for AWS Kubernetes multi-clustering to be successful is found [Here](deployK8s-AWS.md)

Static engine lists, which may be used to extend traditional, on-premise PingFederate clusters is out of scope here.

## Prerequisites

* Two Kubernetes clusters created with the following requirements:
    * VPC IPs selected from RFC1918 CIDR blocks
    * The two cluster VPCs peered together
    * All appropriate routing tables modified in both clusters to send cross cluster traffic to the VPC peer connection
    * Security groups on both clusters to allow traffic for ports 7600 and 7700 to pass
    * Successfully verified that a pod in one cluster can connect to a pod in the second cluster on ports 7600 and 7700 (directly to the pods back-end IP, not an exposed service)
    * externalDNS enabled
    > See example "AWS configuration" instructions [Here](deployK8s-AWS.md)
* Helm

## Overview
![PingFederate DNS PING MultiRegion Deployment Diagram](../images/pf_dns_ping_overview_diagram.png)

The PingIdentity PingFederate Docker image default `instance/server/default/conf/tcp.xml` file points to DNS_PING. Once you have two peered Kubernetes clusters, to span a PingFederate cluster across becomes easy. A single pingfederate cluster using DNS_PING queries a local headless service. In this example we use [externalDNS](https://github.com/kubernetes-sigs/external-dns) to give an externalName to the headless service. externalDNS makes a corresponding record on AWS Route53 and constantly updates it with container ips of the backend PF engines.

!!! notes "External DNS"
    if unable to use [externalDNS](https://github.com/kubernetes-sigs/external-dns), another way to expose the headless service across clusters is needed. HAProxy may be viable.

## What You'll Do

- Clone example files from the `getting-started` [Repository](https://github.com/pingidentity/pingidentity-devops-getting-started)
- Edit the externalName of the pingfederate-cluster service and the DNS_QUERY_LOCATION variable as needed
  > search on the files for `# CHANGEME`
- Deploy the clusters
- Cleanup

## Running

Clone the `getting-started` [Repository](https://github.com/pingidentity/pingidentity-devops-getting-started) to get the Helm values yaml for the exercise (30-helm/multi-region/pingfederate), then:

1. Fix the first un-commented line under any `## CHANGEME` in the files. This will be the Kubernetes namespace and the externalName of the pingfederate-cluster service.

2. Deploy the first cluster

    ```sh
    kubectx us
    helm upgrade --install example pingidentity/ping-devops -f base.yaml -f 01-layer-usa.yaml
    ```

3. Deploy the second cluster

    ```sh
    kubectx eu
    helm upgrade --install example pingidentity/ping-devops -f base.yaml -f 01-layer-eur.yaml
    ```

4. Switch back to the first cluster, and simulate a regional failure

    ```sh
    kubectx us
    helm uninstall example
    ```

5. Switch back to the second cluster and switch failover to active

    ```sh
    kubectx eu
    helm upgrade --install example pingidentity/ping-devops -f base.yaml -f 02-layer-eur.yaml
    ```

## Cleanup Clusters

```sh
kubectx eu
helm uninstall example
kubectx us
helm uninstall example
```
