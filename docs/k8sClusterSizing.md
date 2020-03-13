# Kubernetes Cluster Sizing

When creating your Kubernetes cluster, sizing of your nodes is top of mind.

## Kubernetes Cluster Capacity

When determining the capacity of your cluster, there are numerous ways to fullfill that specification. For example, if you calculated sizing of 16 cpu and 64GB RAM you could break that down into these various options:

* 2 nodes: 8 cpu / 32GB RAM
* 4 nodes: 4 cpu / 16GB RAM
* 8 nodes: 2 cpu / 8GB RAM
* 16 nodes: 1 cpu / 4GB RAM

To understand which sizing option to select, let's examine the pros and cons.

> General assumption: Instance cost for cpu/ram is linear with major cloud vendors.

## Option 1: Fewer, larger nodes

### Pros

* If you have applications that are cpu or RAM intensive, having larger nodes will ensure your application has sufficient resources

### Cons

* High Availbility is difficult to achieve if you have a minimal set of nodes. If your application has 50 instances (25 pods/node) and a node goes down. You have lost 50% of your service.
* Scaling: When autoscaling your cluster, the increment size becomes larger which may result in provisioning more hardware that what is required.

## Option 2: More, smaller nodes

### Pros

* High Availability is easier to maintain. If you have 50 instances (2 pods/node) and one node goes down, you have only reduced your service by 4%.

### Cons

* More system overhead to manage all of the nodes
* Under ulitization as the nodes may be too small to add addtional services

## Guidance

For production deployments where high availability is paramount, creating a cluster with more nodes with less pods per node is preferred to ensure the health of your deployed service.

> Note: For some applications, you may decide to size 1 pod per node.

To determine the physical instance type, multiply the desired resources for each service by the number of pods per node, plus additional for system overhead. Follow product guidelines to determine system requirements.

### Example Service (with 3 pods/node)

* Typically deployed with 2 CPU and 4GB RAM
* Multiply by 3
* Node requirement: 6 CPU 12 GB RAM
* Add 10% for system overhead

For these requirements in AWS a c5.2xlarge type (8 CPU / 16GB RAM) could be the instance type selected.

To determine the base number of nodes required, divide the number of pods by 3 to determine your minumum cluster size.

Ensure that you add definitions for cluster horizontal auto-scaling to ensure your cluster scales in/out as needed.
