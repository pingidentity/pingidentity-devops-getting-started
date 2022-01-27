---
title: Kubernetes Basics
---

# Kubernetes Basics

This page cannot cover the full depths of Kubernetes. However, we often deal with groups that are new to Kubernetes, and reading other technical documentation may be too involved for our purposes. This document will aim to arm newer Kubernetes consumers with helpful commands and terminology in simple terms with a focus on relevant commands. These concepts will use Ping Identity in DevOps as a background, but will generally apply to any interactions in Kubernetes. As such, this may feel incomplete or inaccurate to veterans. If you'd like to contribute, feel free to open a pull request!

## Kubernetes

### Terms

**Cluster** -  The ice cube tray.

View a "cluster" as a set of resources that you have access to deploy containers onto. A cluster can be as small as your local computer as big as hundreds of VMs, called Nodes,  in a data center. Interaction with the cluster requires authentication and RBAC are given to the authenticated identity within the cluster.
In a cloud provider Kubernetes cluster (AWS EKS, Azure AKS, Google GKE) the cluster can span multiple Availability zones, but only _one_ region. In AWS terms, a cluster can be in the region us-west-2, but have nodes in Availability Zones (AZs) us-west-2a, us-west-2b, and us-west-2c. Kubernetes naturally helps with high availability by distributing applications with multiple instances (called replicas) across available AZs.

**Nodes** - The individual ice cube spaces.

The pieces that provide allocatable resources (namely CPU and Memory) and make up a cluster. Typically these are VMs. In AWS it would be ec2 instances.

**Namespace** - A loosely defined "slice" of the cluster. Meant to be an area scoped for grouped applications to be deployed. It is possible to allocate resource limits available to a namespace, but this isn't needed.

**Context** - Definition in your ~/.kube/config file that specifies which cluster and namespace your `kubectl` commands will be sent to.

**Deployments and Statefulsets** - The drops of water that fill ice cube spots.

Applications are deployed as Deployments or Statefulsets depending on if they require persistent storage or not. Think of these as controllers that define and manage the:

  * name of an application
  * number of instances of an application (replicas)
  * persistent storage

**Pod** - The molecules that makeup drops of water.

A Deployment may define the _amount_ of pods, but each one is defined the same. For example, you may have a `pingfederate-engine` deployment that calls for three replicas with 2 CPUs and 2GB of Memory and that is what you will get. You cannot make one engine bigger or smaller than the others. Like a molecule, a pod may be made of just one container, or it can have multiple containers - called sidecars. For Example, your pod may have a pingfederate container as the main process, but a sidecar container like Splunk Universal Forwarder is used to export logs. Sidecar containers will not overlap ports because they interact with each other using localhost. Each pod has a unique IP.

**PersistentVolume and PersistentVolumeClaim** - Simply put, this is an external storage device/definition that is attached to a container. For Ping Identity applications and in general, when an application requires persistent storage it is managed by a resource called StatefulSet. For example, PingDirectory is a data store with an included database, and each instance of PingDirectory needs persistent storage (to avoid database locking conflicts). A StatefulSet is a type of Kubernetes resource that has a lot of nice orchestration for stateful applications:

  * predictable naming - myping-pingdirectory-0, myping-pingdirectory-1, myping-pingdirectory-2.
  * Health priority - deploys the first instance and waits for it to be healthy before adding another one. Also, all rolling updates occur to instances one at a time starting with the last one (e.g. myping-pingdirectory-2) first.
  * Persistent Storage per instance - If persistent storage

**Service** - A slim Load Balancer within the cluster. Services provide a single IP put in front of Deployments and Statefulsets to distribute traffic. Backchannel communication, like PingFederate using PingDirectory as a user store, should always point to a service name/port rather than the individual pods. Services are given FQDNs in a cluster. Within the same namespace, services are accessible by their name (e.g `https://myping-pingdirectory:443`), but across namespaces, you must be more explicit (`https://myping-pingdirectory.<namespace>:443`). An FQDN would be `https://myping-pingdirectory.<namespace>.svc.cluster.local

**Ingress** - A definition used to expose an application outside of the cluster. For this to work, you need an Ingress Controller. A common pattern is a deployment of Nginx pods fronted by a physical Load Balancer. Where client application traffic hits the Load Balancer is forwarded to Nginx, is evaluated based on the hostname header and path, and forwarded to a corresponding application. For example, a Pingfederate ingress may have a hostname of myping-pingfederate-engine.ping-local.com. If a client app requests https://myping-pingfederate-engine.ping-local.com/pf/heartbeat.ping the traffic follows this path: Client -> Load Balancer -> NGinx -> pingfederate-engine. More Specifically: Client -> Load Balancer (Nginx k8s Service) -> Nginx Pod -> Pingfederate-engine k8s Service -> Pingfederate-engine pod.


## Commands

View the cluster and namespace you are using:



Alternatively

  ```shell
  kubectl config get-contexts
  kubectl config current-context
  kubectl config use-context my-cluster-name

  # Set Namespace
  kubectl config set-context --current --namespace=<namespace>
  ```

### Viewing resources

You may prefer to use [k9s](https://github.com/derailed/k9s) - a great UI built directly into the terminal.

If you cannot use k9s, here we'll discuss standard commands.

You can `kubectl get` any [resource type](https://kubernetes.io/docs/reference/kubectl/overview/#resource-types). (pods, deployments, statefulsets, persistentvolumeclaims). Use shortnames! po - pods, deploy - deployments, sts - statefulsets, ing - ingresses, pvc - persistentvolumeclaims

The most common - get pods.

  ```
  kubectl get pods
  ```

Logs, this shows anything that the container prints to stdout.

  ```
  kubectl logs -f <pod-name>
  ```

Pod with multiple containers:

  ```
  kubectl logs -f <pod-name> -c <container-name>
  ```

Logs of a crashed pod (RESTARTS != 0)

  ```
  kubectl logs -f <pod-name> --previous
  ```

See available hostnames by ingress

  ```
  kubectl get ing
  ```

### Debugging

When a has crashed surprisingly, we want to first identify why.

View logs of the crash:

  ```
  kubectl logs -f <pod-name> --previous
  ```

View the reason for exit:

  ```
  kubectl describe pod <pod-name>
  ```

When looking at describe, there are two main areas to look at:

  - Last State - will show the reason for exiting along with an exit code.
   Common Exit codes:
   Exit Codes

Common exit codes associated with containers are:

  | Exit Code | Description |
  |---|---|
  | Exit Code 0 | Absence of an attached foreground process|
  | Exit Code 1 | Indicates failure due to application error |
  | Exit Code 137 | Indicates failure as container received SIGKILL (Manual intervention or ‘oom-killer’ [OUT-OF-MEMORY]) |
  | Exit Code 139 | Indicates failure as container received SIGSEGV |
  | Exit Code 143 | Indicates failure as a container received SIGTERM |

  - Events -  The Events list is most helpful when your pod is not even getting created. Perhaps it is stuck in `pending` state :
    * There may not be enough resources available for the pod to get created
    * Something about the pod definition is incorrect. There may be a missing volume or secret.