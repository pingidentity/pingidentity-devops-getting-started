---
title: Kubernetes and Helm Basics
---

# Kubernetes and Helm Basics

Although this document can't cover the depths of these tools, brand-new Kubernetes or Helm users might find other technical documentation too involved for Ping Identity DevOps purposes. This document aims to equip new users with helpful terminology in simple terms, with a focus on relevant commands.

!!! note
This overview uses Ping Identity DevOps as a guide, but generally applies to any interactions in Kubernetes. Therefore, this document might feel incomplete or inaccurate to veterans. If you'd like to contribute, feel free to open a pull request!

## Kubernetes

### Terms

**Cluster** - The ice cube tray.

Think of a cluster as a set of resources that you can deploy containers onto. A cluster can be as small as your local computer or as large as hundreds of virtual machines (VMs), called nodes, in a data center. Interaction with the cluster requires authentication and role-based access control (RBAC) is given to the authenticated identity within the cluster.

In a cloud provider Kubernetes cluster, such as Amazon Web Services (AWS) EKS, Azure AKS, or Google GKE, the cluster can span multiple Availability Zones (AZs), but only _one_ region. In AWS terms, a cluster can be in the region us-west-2 but have nodes in the AZs us-west-2a, us-west-2b, and us-west-2c. Kubernetes naturally helps with high availability by distributing applications with multiple instances, called replicas, across available AZs.

**Nodes** - The individual ice cube spaces in the tray.

The pieces that provide allocatable resources, such as CPU and memory, and make up a cluster. Typically, these are VMs. In AWS, they would be EC2 instances.

**Namespace** - A loosely defined slice of the cluster.

Namespaces are intended to be an area scoped for grouped applications to be deployed.

!!! note
You can allocate resource limits available to a namespace, but this isn't required.

**Context** - A definition in your ~/.kube/config file that specifies which cluster and namespace your `kubectl` commands are sent to.

**Deployments and Statefulsets** - The water that fills ice cube spots.

Applications are deployed as Deployments or Statefulsets depending on whether they require persistent storage or not. Think of these as controllers that define and manage the following:

- Name of an application
- Number of instances of an application (replicas)
- Persistent storage

**Pod** - The molecules that make up the water.

A Deployment can define the _number_ of pods, but each pod is defined the exact same. For example, you can have a `pingfederate-engine` deployment that calls for three replicas with two CPUs and 2 GB of memory, but you cannot make one engine larger or smaller than the others.

Like a molecule, a pod can consist of just one container, or it can have multiple containers, called sidecars. For example, your pod can have a PingFederate container as the main process and a sidecar container, such as Splunk Universal Forwarder, to export logs. Sidecar containers do not overlap ports because they interact with each other using localhost. Each pod has its own IP.

**PersistentVolume and PersistentVolumeClaim** - Simply put, this is an external storage device or definition attached to a container. For Ping Identity applications and in general, when an application requires persistent storage, it's managed by a resource called StatefulSet. For example, PingDirectory is a datastore with its own database, and each instance of PingDirectory needs its own persistent storage to avoid database locking conflicts. A StatefulSet is a type of Kubernetes resource that has a lot of orchestration for stateful applications:

- Predictable naming - myping-pingdirectory-0, myping-pingdirectory-1, myping-pingdirectory-2
- Health priority - deploys the first instance and waits for it to be healthy before adding another. Additionally, all rolling updates occur to instances one-at-a-time starting with the most recent (myping-pingdirectory-2) first.
- Persistent Storage per instance - if persistent storage is requested

**Service** - A slim LoadBalancer within the cluster.

Services provide a single IP address put in front of Deployments and Statefulsets to distribute traffic. Backchannel communication, such as PingFederate using PingDirectory as a user store, should always point to a service name and port rather than the individual pods. Services are given fully-qualified domain names (FQDNs) in a cluster. Within the same namespace, services are accessible by their name (`https://myping-pingdirectory:443`), but across namespaces, you must be more explicit (`https://myping-pingdirectory.<namespace>:443`). An FQDN would be `https://myping-pingdirectory.<namespace>.svc.cluster.local`.

**Ingress** - A definition used to expose an application outside of the cluster. For this to work, you need an Ingress Controller.

A common pattern is a deployment of Nginx pods fronted by a physical LoadBalancer. The location where client application traffic hits the LoadBalancer is forwarded to Nginx, then evaluated based on the host name header and path and forwarded to a corresponding application.

For example, say a PingFederate ingress has a host name of myping-pingfederate-engine.ping-local.com. If a client app makes a request to https://myping-pingfederate-engine.ping-local.com/pf/heartbeat.ping, the traffic flow is: Client -> LoadBalancer (Nginx k8s Service) -> Nginx Pod -> Pingfederate-engine k8s Service -> Pingfederate-engine pod.

### Commands

To see which cluster and namespace you are using, use the [kubectx](https://github.com/ahmetb/kubectx#installation) tool.

Alternatively, you can run the following commands:

```shell
kubectl config get-contexts
kubectl config current-context
kubectl config use-context my-cluster-name

# Set Namespace
kubectl config set-context --current --namespace=<namespace>
```

#### Viewing resources

You can use [k9s](https://github.com/derailed/k9s), which is a UI built directly into the terminal.

If you cannot use k9s, we'll review the standard commands here.

You can `kubectl get` any [resource type](https://kubernetes.io/docs/reference/kubectl/overview/#resource-types), such as pods, Deployments, Statefulsets, and persistentvolumeclaims. Remember to use short names:

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

To show the logs of a pod with multiple containers:

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

When a pod crashes unexpectedly, identify why.

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
  - There aren't enough resources available for the pod to be created.
  - Something about the pod definition is incorrect, such as a missing volume or secret.

Common exit codes associated with containers are:

| Exit Code     | Description                                                                                           |
| ------------- | ----------------------------------------------------------------------------------------------------- |
| Exit Code 0   | Absence of an attached foreground process                                                             |
| Exit Code 1   | Indicates failure due to application error                                                            |
| Exit Code 137 | Indicates failure as container received SIGKILL (manual intervention or ‘oom-killer’ [OUT-OF-MEMORY]) |
| Exit Code 139 | Indicates failure as container received SIGSEGV                                                       |
| Exit Code 143 | Indicates failure as a container received SIGTERM                                                     |

## Helm

!!! info "Ping Identity DevOps and Helm"
All of our instructions and examples are based on the [Ping Identity DevOps Helm chart](https://helm.pingidentity.com). If you're not using the Ping Identity DevOps Helm chart in production, we still recommend using it for generating your direct Kubernetes manifest files. This gives Ping Identity the best opportunity to support your environment.

Everything in Kubernetes is deployed by defining what you want and allowing Kubernetes to achieve the desired state.

Helm simplifies your interaction by building deployment patterns into templates with variables. The Ping Identity Helm chart includes Kubernetes templates and default values maintained by Ping Identity. All you have to worry about is providing values to your desired template variables.

For example, a service definition looks like:

```yaml
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

In the previous example, we ask Kubernetes to create a `service` resource with the name `myping-pingdirectory`.

Using Helm, you can automatically define this entire resource and all other required resources for a basic deployment by setting `pingdirectory.enabled=true`.

### Terminology

**Manifests** - the final Kubernetes .yaml files that are sent to the cluster for resource creation. These look like the service defined above.

**Helm Templates** - Go Template versions of Kubernetes .yaml files.

**Values and values.yaml** - the setting that you pass to a Helm chart so the templates produce manifests that you want. Values can be passed one by one, but more commonly they are defined on a file called values.yaml.

```yaml
pingdirectory:
  enabled: true
```

This is a simple values.yaml that would produce a Kubernetes manifest file over 200 lines long.

**release** - When you deploy something with Helm, you provide a name for identification. This name and the resources deployed along with it make up a `release`. It's a common pattern to prefix all of the resources managed by a release with the release name. In our examples, `myping` is the release name, so you will see products running with names like `myping-pingfederate-admin`, `myping-pindirectory`, and `myping-pingauthorize`.

### Building Helm Values File

This documentation focuses on the [Ping Identity DevOps Helm chart](#helm) and the values passed to the Helm chart to achieve your configuration. To have your deployment fit your goals, you must build a [values.yaml](https://helm.sh/docs/chart_template_guide/values_files/) file.

The most simple values.yaml for our Helm chart could look like:

```yaml
global:
  enabled: true
```

By default, `global.enabled=false`, so these two lines are enough to turn on every available Ping Identity software product with a basic configuration.

In our documentation, you can find an example for providing your own server profile through GitHub to PingDirectory and a snippet of values.yaml specific to that feature:

```yaml
pingdirectory:
  envs:
    SERVER_PROFILE_URL: https://github.com/<your-github-user>/pingidentity-server-profiles
```

This .yaml alone will not turn on PingDirectory, because the default value for `pingdirectory.enabled` is false. To use this feature, add the snippet into your own values.yaml file:

```yaml
global:
  enabled: true
pingdirectory:
  envs:
    SERVER_PROFILE_URL: https://github.com/<your-github-user>/pingidentity-server-profiles
```

This values.yaml turns on all products, including PingDirectory, and overwrites the default `pingdirectory.envs.SERVER_PROFILE_URL` to use `https://github.com/<your-github-user>/pingidentity-server-profiles`.

As you can see, Helm simplifies ease of deployment. To have full customization of your deployment, you can see all available options:

```sh
helm show values pingidentity/ping-devops
```

This command prints all of the default values applied to your deployment. To overwrite any values, copy the snippet and include it in your own values.yaml file. Remember that tabbing and spacing matters. Copying all the way to the left margin and pasting at the very beginning of a line in your text editor should maintain proper indentation.

Helm also provides a wide variety of plugins. One helpful one is [Helm diff](https://github.com/databus23/helm-diff).

This plugin shows what changes will happen between Helm upgrade commands.
If anything in a Deployment or Statefulset shows a change, expect the corresponding pods to be rolled. Watch out for changes when you're not prepared for containers to be restarted.

### Additional commands

As you go through our examples, your goal is to build a values.yaml file that works for you.

Deploy a release:

```sh
helm upgrade --install <release_name> pingidentity/ping-devops -f /path/to/values.yaml
```

Clean up a release:

```sh
helm uninstall <release name>
```

Delete PVCs associated to a release:

```sh
kubectl delete pvc --selector=app.kubernetes.io/instance=<release_name>
```
