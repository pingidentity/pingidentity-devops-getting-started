---
title: Helm Basics
---

# Helm Basics

This page cannot cover the full depths of Helm. However, for those who are new to Helm reading other technical documentation may be too involved for our purposes. This document will aim to arm Helm consumers with helpful commands and terminology in simple terms with a focus on relevant commands. These concepts will use Ping Identity in DevOps as a background, but will generally apply to any interactions in Kubernetes. As such, this may feel incomplete or inaccurate to veterans. If you'd like to contribute, feel free to open a pull request! For more in-depth documentation around Helm, check out [helm.sh](https://helm.sh).

## **Helm**

!!! info "PingIdentity Devops and Helm"
    All of our examples and guidance will focus on the usage of our [PingIdentity DevOps Helm chart](https://helm.pingidentity.com). If you do not wish to or cannot use the PingIdentity DevOps Helm chart in production, it is still recommended to at least use it for generating your direct Kubernetes manifest files. This will give Ping Identity the best opportunity to support your environment.

Everything in Kubernetes is deployed by defining what is desired and allowing Kubernetes to achieve the desired state.

Helm simplifies your interaction as the consumer by building deployment patterns into templates with variables. A Helm chart includes Kubernetes templates _and_ default values (maintained by Ping Identity in this case). So all you have to worry about is providing values to the template variables that matter to you.

For example, a service definition looks like this:

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

Here, we ask Kubernetes to create a `service` resource with the name `myping-pingdirectory`.

With Helm, this entire resource, along with all other required resources for a basic deployment, would be automatically defined just by setting `pingdirectory.enabled=true`.

### **Terms**

**Manifests** - the final Kubernetes yaml files that are sent to the cluster for resource creation. Looks like the service defined above.

**Helm Templates** - Go Template versions of Kubernetes yaml files.

**Values and values.yaml** - the setting that you pass to a helm chart so the templates will produce manifests that you want. Values can be passed one by one, but more commonly they are put on a file called values.yaml

  ```yaml
  pingdirectory:
    enabled: true
  ```

This is a very simple values yaml that would produce a Kubernetes manifest file over 200 lines long.

**release** - When you deploy _something_ with Helm, you provide a name for identification. This name and the resources deployed along with it make up a `release`. It is a common pattern to prefix all of the resources managed by a release with the release name. In our examples we will use `myping` as the release name, so you will see products running with names like: `myping-pingfederate-admin`, `myping-pindirectory`, `myping-pingauthorize`.

### Building Helm Values File

This documentation focuses on the [PingIdentity DevOps Helm chart](#helm) and the values passed to the helm chart to achieve your configuration. For the deployment to fit your goals, you will build a [values.yaml](https://helm.sh/docs/chart_template_guide/values_files/).

The most simple values.yaml for our helm chart could look like:

```yaml
global:
  enabled: true
```

By default, `global.enabled=false`, so these two lines are enough to turn on every available PingIdentity software product with a basic configuration.

In the documentation, you may find an example for providing your server profile via Github to PingDirectory and a snippet of values.yaml specific _only_ to that feature:

```yaml
pingdirectory:
  envs:
    SERVER_PROFILE_URL: https://github.com/<your-github-user>/pingidentity-server-profiles
```

This yaml alone will not even turn on PingDirectory, because the default value for `pingdirectory.enabled` is set to false. To take advantage of the feature, you want to merge this snippet into your values.yaml to where you end up with:

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
  helm show values pingidentity/ping-devops
  ```

This will print all the default values that are applied for you, so if you want to overwrite any of them, just copy the snippet out and include it in your values.yaml. Keep in mind, tabbing and spacing matter. If you copy to the left margin and paste at the very beginning of a line in your text editor, this should maintain proper indentation.

Helm also provides a wide variety of plugins. One particularly helpful one is [helm diff](https://github.com/databus23/helm-diff).

This plugin shows what changes will happen between helm upgrade commands.
If anything in a deployment or statefulset shows a change, expect the corresponding pods to be rolled. This is helpful to watch out for a change when you are not prepared for containers to be restarted.


### **Commands**

As you go through our examples, your goal will be to build a values.yaml file that works for you. The end product will vary based on the Ping Identity products and features needed for your environment and can be built off of the examples we provide below if desired.

Deploy a release.

  ```
  helm upgrade --install <release_name> pingidentity/ping-devops -f /path/to/values.yaml
  ```


Clean up a release.

  ```
  helm uninstall <release name>
  ```

Delete PVCs associated with a release

  ```
  kubectl delete pvc --selector=app.kubernetes.io/instance=<release_name>
  ```

### **Example Configs**


The following contains example configs and examples of how to run and configure Ping products
using the Ping Devops Helm Chart. Please review the [Getting Started Page](getStarted.md) before trying them.

| Config       | Description                                    | .yaml                                  |
| ------------ | ---------------------------------------------- | -------------------------------------- |
| Everything   | Example with most products integrated together | [everything.yaml](https://helm.pingidentity.com/examples/everything.yaml)     |
| PingFederate | PingFederate Admin Console & Engine            | [pingfederate.yaml](https://helm.pingidentity.com/examples/pingfederate.yaml) |
| Simple Sync  | PingDataSync and PingDirectory                 | [simple-sync.yaml](https://helm.pingidentity.com/examples/simple-sync.yaml)   |

## To Deploy

```shell
helm upgrade --install my-release pingidentity/ping-devops \
     -f <HTTPS link to yaml>
```

## Uninstall

```shell
helm uninstall my-release
```