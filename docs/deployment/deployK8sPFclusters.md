---
title: PingFederate Cluster Across Multiple Kubernetes Clusters
---
# PingFederate Cluster Across Multiple Kubernetes Clusters

You can deploy a single PingFederate cluster that spans across multiple Kubernetes clusters.

Having PingFederate in multiple regions doesn't always mean that spanning a single PingFederate cluster across multiple Kubernetes clusters is necessary or optimal.
This scenario makes sense when you have:

* Traffic that can cross between regions at any time (us-west and us-east, and users can be routed to either)
* Configuration that needs to be the same in multiple regions **and** no reliable automation to ensure that

If all configuration changes are delivered through pipeline, and traffic wouldn't cross regions, having separate PingFederate clusters can work.

!!! note
    The set of pre-requisites required for AWS Kubernetes multi-clustering to be successful is found [Here](deployK8s-AWS.md).

## Overview

This section will focus on the optimal use of PingFederate features:
* Adaptive clustering and dynamic discovery of engines enable engine auto-scaling.
* Static engine lists, which can be used to extend traditional, on-premise PingFederate clusters, are out of scope in this scenario.

## Discovery Options

There are two main dynamic discovery options:

### DNS_PING (PF > 10.2)

  ![PingFederate DNS PING MultiRegion Diagram](../images/pf_dns_ping_overview_diagram.png)

### S3 (PF < 10.1.x)

  ![PingFederate AWS MultiRegion Deployment Diagram](../images/pf_aws_overview_diagram.png)

In either scenario, you must perform the following prerequisites.

## Before you begin

You must have:

* Two Kubernetes clusters created with the following requirements:
    * VPC IPs selected from RFC1918 CIDR blocks
    * The two cluster VPCs peered together
    * All appropriate routing tables modified in both clusters to send cross cluster traffic to the VPC peer connection
    * Security groups on both clusters to allow traffic for ports 7600 and 7700 to pass
    * Successful verification that a pod in one cluster can connect to a pod in the second cluster on ports 7600 and 7700 (directly to the pods back-end IP, not an exposed service)
    > For more information, see example "AWS configuration" instructions [Here](deployK8s-AWS.md)
* envsubst
* kustomize

## Constants

In either scenario, some pieces remain the same.
Yaml files that include:

1. Two deployments:
    * `pingfederate-admin` represents the admin console.
    * `pingfederate` represents the engine or engines.

1. One configmap for each deployment:
    * These two configmaps are nearly identical but define the operational mode separately.

1. Profile Files:
    * run.properties.subst
    * cluster-adaptive.conf.subst
    * tcp.xml.subst (using S3_PING, NATIVE_S3_PING, or DNS_PING)

1. Two services:
    * One for each of the two deployments (9999 and 9031).

## Variables

For items specific to using S3 or DNS_PING, see the respective docs:

* [GA PF 10.2 onward, Using DNS_PING](deployPFMultiRegionDNS.md)
* [PF < 10.1.x Using S3](deployPFMultiRegionAWS.md) (referencing AWS S3, with possible application to Azure)