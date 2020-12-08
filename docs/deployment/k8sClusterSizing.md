# Sizing Kubernetes clusters

When creating your Kubernetes cluster, it's important that you size the nodes appropriately.

## Kubernetes cluster capacity

When determining the capacity of your cluster, there are a number of ways to approach sizing the nodes. For example, if you calculated a cluster sizing of 16 cpu and 64GB RAM, you could break down the node sizing into these options:

1. 2 nodes: 8 CPU / 32 Gb RAM

2. 4 nodes: 4 CPU / 16 Gb RAM

3. 8 nodes: 2 CPU / 8 Gb RAM

4. 16 nodes: 1 CPU / 4 Gb RAM

To understand which sizing option to select, let's examine the pros and cons.

> You can generally assume that instance cost per CPU/RAM is linear among the major cloud platforms.

## Option 1: fewer, larger nodes

### Pros

* If you have applications that are CPU or RAM intensive, having a larger number of nodes will ensure your application has sufficient resources.

### Cons

* High availability is difficult to achieve with a minimal set of nodes. If your application has 50 instances with 25 pods per node and a node goes down, you've lost 50% of your service.
  
* Scaling: When autoscaling your cluster, the increment size becomes larger, which may result in provisioning more hardware than what is required.

## Option 2: more, smaller nodes

### Pros

* High availability is easier to maintain. If you have 50 instances with 2 pods per node and one node goes down, you've only reduced your service by 4%.

### Cons

* More system overhead to manage all of the nodes.
  
* Possible under-utilization, as the nodes may be too small to add additional services.

## Guidance

For production deployments where high availability is paramount, creating a cluster with more nodes and having less pods per node is preferable to ensure the health of your deployed service.

> For some applications, you may decide to size 1 pod per node.

To determine the physical instance type, multiply the desired resources for each service by the number of pods per node, plus additional for system overhead. Follow product guidelines to determine system requirements.

### Example service using 3 pods per node

* Typically deployed with 2 CPU and 4GB RAM.
  
* Multiply by 3.

* Node requirement: 6 CPU 12 GB RAM.

* Add 10% for system overhead.

For these requirements in Amazon Web Services (AWS), a `c5.2xlarge` type (8 CPU / 16 Gb RAM) may be the instance type selected.

To determine the base number of nodes required, divide the number of pods by 3 to determine your minumum cluster size.

Ensure that you add definitions for cluster horizontal auto-scaling to ensure your cluster scales in or out as needed.
