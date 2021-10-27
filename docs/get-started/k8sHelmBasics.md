---
title: Kubernetes and Helm Basics
---

# Kubernetes and Helm Basics

This page cannot cover the depths of Kubernetes or Helm. However, we often deal with groups that are new to Kubernetes and Helm and reading other technical documentation may be too involved for our purposes. In this document will aim to arm newer kubernetes and helm consumers with helpful commands and terminology in simple terms with a focus on relevant commands. These concepts will use Ping Identity in DevOps as a background, but will generally apply to any interactions in Kubernetes. As such, this may feel incomplete or inaccurate to veterans. If you'd like to contribute, feel free to open a pull request!

## Kubernetes

### Terms

**Cluster** -  The ice cube tray. 

View a "cluster" as a set of resources that you have access to deploy containers onto. A cluster can be as small as your local computer as big as hundreds of VMs, called Nodes,  in a data center. Interaction with the cluster requires authentication and RBAC is given to the authenticated identity within the cluster. 
In a cloud provider Kubernetes cluster (AWS EKS, Azure AKS, Google GKE) the cluster can span multiple Avalability zones, but only _one_ region. In AWS terms, a cluster can be in the region us-west-2, but have nodes in Availability Zones (AZs) us-west-2a, us-west-2b, and us-west-2c. Kubernetes natually helps with high availability by distributing applications with multiple instacnces (called replicas) across avaiable AZs.

**Nodes** - The individual ice cube spaces. 

The pieces that provide allocatable resources (namely CPU and Memory) and make up a cluster. Typically these are VMs. In AWS it would be ec2 instances.

**Namespace** - A loosely defined "slice" of the cluster. Meant to be an area scoped for grouped applications to be deployed. It is possible to allocate resource limits available to a namespace, but this isn't needed. 

**Context** - Definition in your ~/.kube/config file that specifies which cluster and namespace your `kubectl` commands will be sent to. 

**Deployments and Statefulsets** - The drops of water that fill ice cube spots. 

Applications are deployed as Deployments or Statefulsets depending on if they require persistent storage or not. Think of these as controllers that define and manage the: 
  
  * name of an application
  * number of instances of an application (replicas)
  * persistent storage

**Pod** - The molecules that make up drops of water. 

A Deployment may define the _amount_ of pods, but each one is defined the exact same. For example, you may have a `pingfederate-engine` deployment that calls for three replicas with 2 CPUs and 2gb of Memory and that is what you will get. You cannot make one engine bigger or smaller than the others. Like a molecule, a pod may be made of just one container, or it can have multiple containers - called sidecars. For Example, your pod may have a pingfederate container as the main process, but a sidecar container like Splunk Universal Forwarder that is used export logs. Sidecar containers will not overlap ports because they interact with each other using localhost. Each pod has it's own IP. 

**PersistentVolume and PersistentVolumeClaim** - Simply put, this is an external stoage device/definition that is attached to a container. For Ping Identity applications and in general, when an application requires persistent storage it is managed by a resource called StatefulSet. For example, PingDirectory is a data store with its own database, as such, each instance of PingDirectory needs it's own persistent storage (to avoid database locking conflicts). A StatefulSet is a type of kubernetes resource that has a lot of nice orchestration for stateful applications: 

  * predictable naming - myping-pingdirectory-0, myping-pingdirectory-1, myping-pingdirectory-2. 
  * Health priority - deploys the first instance and waits for it to be healthy before adding another one. Also, all rolling updates occur to instances one at a time starting with the last one (e.g. myping-pingdirectory-2) first. 
  * Persistent Storage per instance - If persistent storage 

**Service** - A slim LoadBalancer within the cluster. Services provide a single IP put in front of Deployments and Statefulsets to distrubute traffic. Backchannel communication, like PingFederate using PingDirectory as a user store, should always point to a service name/port rather than the individual pods. Services are given FQDNs in a cluster. Within the same namespace, services are accessible by their name (e.g `https://myping-pingdirectory:443`), but accross namespaces you must be more explicit (`https://myping-pingdirectory.<namespace>:443`). An FQDN would be `https://myping-pingdirectory.<namespace>.svc.cluster.local

**Ingress** - A definition used to expose an application outside of the cluster. In order for this to work, you need an Ingress Controller. A common pattern is a deployment of Nginx pods fronted by a physical LoadBalancer. Where client application traffic hits the Loadbalancer is forwarded to Nginx, is evaluated based on the hostname header and path and forwarded to a corresponding application. For example a Pingfederate ingress may have a hostname of myping-pingfederate-engine.ping-local.com. If a client app makes a request to https://myping-pingfederate-engine.ping-local.com/pf/heartbeat.ping the traffic follows like: Client -> LoadBalancer -> NGinx -> pingfederate-engine. More Specifically: Client -> LoadBalancer (Nginx k8s Service) -> Nginx Pod -> Pingfederate-engine k8s Service -> Pingfederate-engine pod. 


### Commands

See which cluster and namespace you are using:
Easy tool - [kubectx](https://github.com/ahmetb/kubectx#installation)

Alternatively

  ```shell
  kubectl config get-contexts
  kubectl config current-context
  kubectl config use-context my-cluster-name

  # Set Namespace
  kubectl config set-context --current --namespace=<namespace>
  ```

#### Viewing resources

You may prefer to use [k9s](https://github.com/derailed/k9s) - a great UI built directly into terminal. 

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

#### Debugging

When a has crashed surprisingly, we want to first identify why. 

View logs of the crash: 

  ```
  kubectl logs -f <pod-name> --previous
  ```

View the reason for exit:

  ```
  kubectl describe pod <pod-name>
  ```

When looking at describe, there two main areas to look: 
  
  - Last State - will should the reason for exit and exit code. 
   Common Exit codes: 
   Exit Codes

Common exit codes associated with containers are:

  | Exit Code | Description |
  |---|---|
  | Exit Code 0 | Absence of an attached foreground process|
  | Exit Code 1 | Indicates failure due to application error |
  | Exit Code 137 | Indicates failure as container received SIGKILL (Manual intervention or ‘oom-killer’ [OUT-OF-MEMORY]) |
  | Exit Code 139 | Indicates failure as container received SIGSEGV |
  | Exit Code 143 | Indicates failure as a container recieved SIGTERM |

  - Events -  The Events list is most helpful when your pod is not even getting created. Perhaps it is stuck in `pending` state :
    * There may not be enough resources available for the pod to get created
    * something about the pod definition is incorrect. There may be a missing volume or secret. 


## Helm

!!! info "PingIdentity Devops and Helm"
    All of our examples and guidance will focus on the usage of our [PingIdentity DevOps Helm chart](helm.pingidentity.com). If you do not wish to or cannot use the PingIdentity DevOps Helm chart in production, it is still recommended to at least use it for generating your direct Kubernetes manifest files. This will give Ping Identity the best oportunity to support your environment.

Everything in kubernetes is deployed by defining what is desired and allowing kubernetes to achieve the desired state. 

Helm simplifies consumer (your) interaction by building deployment patterns into templates with variables. A Helm chart includes kubernetes templates _and_ default values (maintained by Ping Identity in this case). So all you have to worry about is providing values to the template variables that matter to you. 

For example, a service definition looks like: 

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/instance: myping
    app.kubernetes.io/name: pingdirectory
  name: myping-pingdirectory
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: 1443
  - name: ldap
    port: 389
    protocol: TCP
    targetPort: 1389
  - name: ldaps
    port: 636
    protocol: TCP
    targetPort: 1636
  selector:
    app.kubernetes.io/instance: myping
    app.kubernetes.io/name: pingdirectory
  type: ClusterIP
```

Here, we ask kubernetes to create a `service` resource with the name `myping-pingdirectory`. 

With Helm this entire resource, along with all other required resources for a basic deployment, would be automatically defined just by setting `pingdirectory.enabled=true`. 

### Terms

**Manifests** - the final kubernetes yaml files that are sent to the cluster for resource creation. Looks like the service defined above. 

**Helm Templates** - Go Template versions of kubernetes yaml files. 

**Values and values.yaml** - the setting that you pass to a helm chart so the templates will product manifests that you want. Values can be passed one by one, but more commonly they are put on a file called values.yaml

  ```yaml
  pingdirectory:
    enabled: true
  ```

This is a very simple values yaml that would produce a kubernetes minifest file over 200 lines long. 

**release** - When you deploy _something_ with Helm, you provide a name for identification. This name and the resources deployed along with it make up a `release`. It is a common pattern to prefix all of the resources managed by a release with the release name. In our examples we will use `myping` as the release name, so you will see products running with names like: `myping-pingfederate-admin`, `myping-pindirectory`, `myping-pingauthorize`. 

### Building Helm Values File

This documentation focuses on the [PingIdentity DevOps Helm chart](#helm) and the values passed to the helm chart in order to achieve your configuration. Which means to have your deployment fit your goals, you will build a [values.yaml](https://helm.sh/docs/chart_template_guide/values_files/). 

The most simple values.yaml for our helm chart could look like: 

```yaml
global: 
  enabled: true
```

By default, `global.enabled=false`, so these two lines are enough to turn on every available PingIdentity software product with a basic configuration. 

In documentation you may find an example for providing your own server profile via Github to PingDirectory and a snippet of values.yaml specific _only_ to that feature:

```yaml
pingdirectory:
  envs:
    SERVER_PROFILE_URL: https://github.com/<your-github-user>/pingidentity-server-profiles
```

This yaml alone will not even turn on PingDirectory, because the default value for `pingdirectory.enabled` is set to false. To take advantage of the feature, you want to merge this snippet into your own values.yaml to where you end up with: 

```yaml
global:
  enabled: true
pingdirectory:
  envs:
    SERVER_PROFILE_URL: https://github.com/<your-github-user>/pingidentity-server-profiles
```

This values.yaml turns on _all_ products including PingDirectory, _and_ overwrites the default `pingdirectory.envs.SERVER_PROFILE_URL` to use `https://github.com/<your-github-user>/pingidentity-server-profiles`. 

As you see, helm simplifies what you have to include for deployment, but as you want to be more customized you will want to see what options are available. To see all options available:

  ```
  helm show values pingidenity/ping-devops
  ```

This will print all the default values that are applied for you, so if you want to overwrite any of it, just copy the snippet out and include it in your own values.yaml. Keep in mind, tabbing and spacing matters. If you copy all the way to the left margin, and paste at the very beginning of a line in your text editor, this should maintain proper indentation. 

Helm also provides a wide variety of plugins. One particularly helpful one is [helm diff](https://github.com/databus23/helm-diff). 

This plugin shows what changes will happen between helm upgrade commands. 
If anything in a deployment or statefulset shows a change, expect the corresponding pods to be rolled. This is helpful to watch out for a change when you are not prepared for containers to be restarted. 


### Commands

As you go though our examples, your goal will be to build a values.yaml file that works for you. The 

Deploy a release. 

  ```
  helm upgrade --install <release_name> pingidentity/ping-devops -f /path/to/values.yaml
  ```


Clean up a release. 

  ```
  helm uninstall <release name>
  ```

Delete PVCs associated to a release

  ```
  kubectl delete pvc --selector=app.kubernetes.io/instance=<release_name>
  ```




