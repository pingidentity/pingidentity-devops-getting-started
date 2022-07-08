---
title: Sizing Kubernetes clusters
---
# Sizing Kubernetes clusters

When creating your Kubernetes cluster, size the nodes appropriately.

## Kubernetes cluster capacity

When determining the capacity of your cluster, there are many ways to approach sizing the nodes. For example, if you calculated a cluster sizing of 16 CPU and 64GB RAM, you could break down the node sizing into these options:

1. 2 nodes: 8 CPU / 32 GB RAM
1. 4 nodes: 4 CPU / 16 GB RAM
1. 8 nodes: 2 CPU / 8 GB RAM
1. 16 nodes: 1 CPU / 4 GB RAM

To understand which sizing option to select, consider the associated pros and cons.

!!! Note "Instance pricing"
    You can generally assume that instance cost per CPU/RAM is linear among the major cloud platforms.

## Option 1: fewer, larger nodes

### Pros

* If you have applications that are CPU or RAM intensive, having larger nodes can ensure your application has sufficient resources.

### Cons

* High availability is difficult to achieve with a minimal set of nodes. If your application has 50 pods across two nodes (25 pods per node) and a node goes down, you lose 50% of your service.
* Scaling: When autoscaling the cluster, the increment size becomes larger which could result in provisioning more hardware than needed.

## Option 2: more, smaller nodes

### Pros

* High availability is easier to maintain. If you have 50 instances with two pods per node (25 nodes) and one node goes down, you only reduce your service capacity by 4%.

### Cons

* More system overhead to manage all of the nodes.
* Possible under-utilization as the nodes might be too small to add additional services.

## Guidance

For production deployments where high availability is paramount, creating a cluster with more nodes running fewer pods per node is preferable to ensure the health of your deployed service.

> For some applications, you can decide to size one pod per node.

To determine the physical instance type needed, multiply the desired resources for each service by the number of pods per node, plus additional capacity for system overhead. Follow product guidelines to determine system requirements.

### Example service using 3 pods per node

* Each pod is typically deployed with 2 CPU and 4GB RAM which when multiplied by 3 yields:
    * Minimum node requirement: 6 CPU 12 GB RAM
* Add 10% for system overhead

For these requirements in Amazon Web Services (AWS), a `c5.2xlarge` type (8 CPU / 16 GB RAM) might be the instance type selected.

To determine the base number of nodes required, divide the number of pods by 3 to determine your minimum cluster size.  Further, you must ensure that you add definitions for cluster horizontal auto-scaling so the cluster scales in or out as needed.
