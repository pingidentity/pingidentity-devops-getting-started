# Deploy PingFederate Across Multiple Kubernetes Clusters

This section will discuss deploying a single PingFederate cluster that spans across multiple Kubernetes clusters.

Deploying PingFederate in multiple regions should not imply that spanning a single PingFederate cluster across multiple Kubernetes clusters is necessary or optimal.  This scenario makes sense when you have:

* Traffic that can cross between regions at any time. For example, us-west and us-east and users may be routed to either location.
* Configuration that needs to be the same in multiple regions **and** there is no reliable automation to ensure this is the case

If all configuration changes are delivered via a pipeline, and traffic will not cross regions, having separate PingFederate clusters can work.

!!! note
    The set of pre-requisites required for AWS Kubernetes multi-clustering to be successful is found [here](deployK8s-AWS.md).

Static engine lists, which may be used to extend traditional, on-premise PingFederate clusters is out of scope in this document.

## Prerequisites

* Two Kubernetes clusters created with the following requirements:
    * VPC IPs selected from RFC1918 CIDR blocks
    * The two cluster VPCs peered together
    * All appropriate routing tables modified in both clusters to send cross cluster traffic to the VPC peer connection
    * Security groups on both clusters to allow traffic for ports 7600 and 7700 in both directions
    * Verification that a pod in one cluster can connect to a pod in the second cluster on ports 7600 and 7700 (directly to the back-end IP assigned to the pod, not through an exposed service)
    * externalDNS enabled
    > See example "AWS configuration" instructions [here](deployK8s-AWS.md)
* Helm client installed

## Overview
![PingFederate DNS PING MultiRegion Deployment Diagram](../images/pf_dns_ping_overview_diagram.png)

The PingFederate Docker image default `instance/server/default/conf/tcp.xml` file points to DNS_PING. After you have two peered Kubernetes clusters, spanning a PingFederate cluster across the two becomes easy. A single PingFederate cluster uses DNS_PING to query a local headless service. In this example we use [externalDNS](https://github.com/kubernetes-sigs/external-dns) to give an externalName to the headless service. The `externalDNS` feature from the Kubernetes special interest group (SIG) creates a corresponding record on AWS Route53 and constantly updates it with container IP addresses of the backend PF engines.

!!! warning "External DNS"
    If you are unable to use [externalDNS](https://github.com/kubernetes-sigs/external-dns), another way to expose the headless service across clusters is needed. HAProxy may be a viable option to explore and is beyond the scope of this document.

## What You Will Do

- Clone the example files from the `getting-started` [Repository](https://github.com/pingidentity/pingidentity-devops-getting-started)
- Edit the externalName of the pingfederate-cluster service and the DNS_QUERY_LOCATION variable as needed
  > Search the files for `# CHANGEME` comments to find where these changes need to be made.
- Deploy the clusters
- Cleanup

## Example deployment

Clone this `getting-started` [repository](https://github.com/pingidentity/pingidentity-devops-getting-started) to get the Helm values yaml for the exercise. The files are located under the folder `30-helm/multi-region/pingfederate`.  After cloning: 

1. Update the first uncommented line under any `## CHANGEME` comment in the files. The changes will indicate the Kubernetes namespace and the externalName of the pingfederate-cluster service.

2. Deploy the first cluster (the example here uses [kubectx](https://github.com/ahmetb/kubectx) to set the kubectl context))

    ```sh
    kubectx us
    helm upgrade --install example pingidentity/ping-devops -f base.yaml -f 01-layer-usa.yaml
    ```

3. Deploy the second cluster

    ```sh
    kubectx eu
    helm upgrade --install example pingidentity/ping-devops -f base.yaml -f 01-layer-eur.yaml
    ```

4. Switch back to the first cluster, and simulate a regional failure by removing the PingFederate cluster entirely:

    ```sh
    kubectx us
    helm uninstall example
    ```

5. Switch back to the second cluster and switch failover to active

    ```sh
    kubectx eu
    helm upgrade --install example pingidentity/ping-devops -f base.yaml -f 02-layer-eur.yaml
    ```

## Cleanup

```sh
kubectx eu
helm uninstall example
kubectx us
helm uninstall example
```
