---
title: Kubernetes Basics
---

# Kubernetes Basics

Although this document cannot cover all aspects of these tools, new Kubernetes users might find other technical documentation too involved for purposes of using Ping Identity images. This document aims to equip new users with helpful terminology in simple terms, with a focus on relevant commands.

!!! note
    This overview uses Ping Identity images and practices as a guide, but generally applies to any interactions in Kubernetes. With these assumptions, this document might feel incomplete or inaccurate to veterans. If you would like to contribute to this document, feel free to open a pull request!

## Kubernetes

### Terms

**Cluster** - The ice cube tray.

You can consider a Kubernetes cluster as a set of resources into which you can deploy containers. A cluster can be as small as your local computer or as large as hundreds of virtual machines (VMs), called **nodes**, in a data center. Interaction with the cluster is through an API requiring authentication and role-based access control (RBAC) that allows the actions necessary within the cluster.

In a cloud provider Kubernetes cluster, such as Amazon Web Services (AWS) EKS, Azure AKS, or Google GKE, the cluster can span multiple Availability Zones (AZs), but only _one_ region. In AWS terms, a cluster can be in the region us-west-2 but have nodes in the AZs us-west-2a, us-west-2b, and us-west-2c. Kubernetes provides high availability by distributing applications with multiple instances of containers, called replicas, across available AZs.

**Nodes** - The individual ice cube spaces in the tray.

The nodes are the pieces that provide allocatable resources, such as CPU and memory, and make up a cluster. Typically, these are VMs, and for example in AWS, they would be EC2 instances.

**Namespace** - A loosely defined slice of the cluster.

Namespaces are intended to be an segment scoped for deploying grouped applications.

!!! note
    You can allocate resource limits available to a namespace, but this is not required.

**Context** - A definition in your ~/.kube/config file that specifies the cluster and namespace where your `kubectl` commands where executed.

**Deployments and Statefulsets** - The water that fills ice cube spots.

Applications are deployed as Deployments or Statefulsets. You can consider both of these objects as controllers that define and manage the following:

- Name of an application
- Number of instances (pods) of an application (replicas)
- Persistent storage

Though they are similar, Deployments differ from Statefulsets in a few fundamental ways.

##### Deployments

* Deployments are typically used for stateless applications - if a pod is lost or removed, any other pod in the same deployment can take on the activity the lost pod was performing.
* Pod names are inconsequential because each pod is identical with no state information required.  As a result, the name of the pod does not matter and names are suffixed with a randomly generated string.
* The order in which pods are started is also inconsequential.  When starting a deployment all pods are launched at the same time.  
* When updating a deployment, you can cycle one, many, or all pods at the same time.

##### Statefulsets

StatefulSets are more structured in the manner in which the pods are handled.  

* StatefulSets - as the name implies - are used for applications in which a known state is required.  For example, many clustered products have an instance in the cluster that is considered the leader and all pods in the set need to know which pod is acting in this capacity.  A controlled scale-up and scale-down process is needed to maintain known state as application nodes or instances join or leave the cluster or are restarted.  
* Pod names are _sticky_ in that each pod in the StatefulSet has a known name, with each pod receving an ordinal indicator (unlike the random pod name found in Deployments).  For example, a StatefulSet will have pod names similar to:  myping-pingdirectory-0, myping-pingdirectory-1, myping-pingdirectory-2
* Controlled startup with health priority: unlike a Deployment, a StatefulSet deploys the first instance (pod name appended with -0) and waits for it to be healthy before adding another.
* Updates occur to instances in a rolling fashion, one-at-a-time, starting with the most recent pod(myping-pingdirectory-2) first.
* With a known Pod name, persistent storage can be maintained for each pod.  After persistent storage is created and assigned, the same storage object is provided to the same-named pod every time.

**Pod** - The molecules that make up the water.

A Deployment/StatefulSet specifies _number_ of pods to run for a given application. For example, you can have a `pingfederate-engine` deployment that calls for three replicas with two CPUs and 2 GB of memory, but you cannot make one engine larger or smaller than the others.

Like a molecule, a pod can consist of just one container, or it can have multiple containers, called sidecars. For example, your pod can have a PingFederate container as the main process and a sidecar container, such as Splunk Universal Forwarder, to export logs. All containers in a pod, including these sidecars, share a namespace and IP address.

Pods are are considered disposable and by default do not persist any data.  To maintain state or data, external storage or a database of some kind is needed.

**PersistentVolume (PV) and PersistentVolumeClaim (PVC)** - A virtual external storage device or definition attached to a Pod.

The PV is the storage object and PVC is the claim that a given pod makes for that storage. 

**Service** - A slim LoadBalancer within the cluster.

Pods can come and go, be disposed of or restarted.  Every time a Pod is started, it will receive an IP address which often changes. In order to access the application hosted in the Pod, a fixed, known location or address is required.

Services provide a single IP address and cluster-internal DNS resolution that is placed in front of Deployments and Statefulsets to distribute traffic. For service-to-service communication, such as PingFederate using PingDirectory as a user store, the application should be configured to point to a service name and port rather than the individual pods. Services are given fully-qualified domain names (FQDNs) in a cluster. Within the same namespace, services are accessible by their name (`https://myping-pingdirectory:443`), but across namespaces, you must be more explicit (`https://myping-pingdirectory.<namespace>:443`). A FQDN would be `https://myping-pingdirectory.<namespace>.svc.cluster.local`.

**Ingress** - A network definition used to expose an application external to the cluster. In order for an ingress to work, you need an Ingress Controller.

A common pattern is a deployment of Nginx pods fronted by a physical loadbalancer. The location the client application traffic hits the loadbalancer is forwarded to Nginx. The header information (hostname and path) of the request is evaluated and forwarded to a corresponding application.

For example, suppose a PingFederate ingress has a host name of **myping-pingfederate-engine.ping-local.com**. If a client application makes a request to `https://myping-pingfederate-engine.ping-local.com/pf/heartbeat.ping`, the traffic flow of the request would be:

* Client -> LoadBalancer (Nginx k8s Service) -> Nginx Pod -> Pingfederate-engine k8s Service -> Pingfederate-engine pod

### Commands

To see which cluster and namespace you are using, use the [kubectx](https://github.com/ahmetb/kubectx#installation) tool.

Alternatively, you can run the following commands:

```shell
# Retrieve and set context
kubectl config get-contexts
kubectl config current-context
kubectl config use-context my-cluster-name

# Set Namespace
kubectl config set-context --current --namespace=<namespace>
```

#### Viewing resources

You can use [k9s](https://github.com/derailed/k9s), which is a UI designed to run in a terminal.

If you cannot use k9s, review the standard commands here.

You can run `kubectl get` for any [resource type](https://kubernetes.io/docs/reference/kubectl/overview/#resource-types), such as Pods, Deployments, Statefulsets, and PVCs. Many resources have short names:

- `po` = pods
- `deploy` = Deployments
- `sts` = Statefulsets
- `ing` = ingresses
- `pvc` = persistentvolumeclaims

The most common command is `get pods`:

```sh
kubectl get pods
```

To show anything that the container prints to `stdout`, use `logs`:

```sh
kubectl logs -f <pod-name>
```

To show the logs of a pod with multiple containers, specify the container to view with the `-c` option:

```sh
kubectl logs -f <pod-name> -c <container-name>
```

To show the logs of a crashed pod (`RESTARTS != 0`):

```sh
kubectl logs -f <pod-name> --previous
```

To see available host names by ingress:

```sh
kubectl get ing
```

#### Debugging

When a pod crashes unexpectedly, you can mine information about the cause with the following commands.

To view logs of the crash:

```sh
kubectl logs -f <pod-name> --previous
```

To view the reason for exit:

```sh
kubectl describe pod <pod-name>
```

When looking at `describe`, there are two main sections of the output to note:

- lastState - shows the exit code and the reason for exit.
- Events - this list is most helpful when your pod is not being created. It might be stuck in pending state if:
  - There are not enough resources available for the pod to be created.
  - Something about the pod definition is incorrect, such as a missing volume or secret.

Common exit codes associated with containers are:

| Exit Code | Description |
| ------------- | ----------------------------------------------------------------------------------------------------- |
| Exit Code 0 | Absence of an attached foreground process |
| Exit Code 1 | Indicates failure due to application error |
| Exit Code 137 | Indicates failure as container received SIGKILL (manual intervention or ‘oom-killer’ [OUT-OF-MEMORY]) |
| Exit Code 139 | Indicates failure as container received SIGSEGV |
| Exit Code 143 | Indicates failure as a container received SIGTERM |