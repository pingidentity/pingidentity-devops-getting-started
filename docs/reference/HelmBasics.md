---
title: Helm Basics
---

# Helm Basics

Although this document cannot cover the depths of this tool, new Helm users might find other technical documentation too involved for the purpose of beginning use of Ping Identity container images. This document aims to equip new users with helpful terminology in simple terms, with a focus on relevant commands. For more in-depth documentation around Helm, check out [helm.sh](https://helm.sh).

!!! note
    This overview uses Ping Identity images and practices as a guide, but generally applies to any interactions using Helm with Kubernetes. With these assumptions, this document might feel incomplete or inaccurate to veterans. If you would like to contribute to this document, feel free to open a pull request!

## Helm

!!! info "Ping Identity DevOps and Helm"
    All of our instructions and examples are based on the [Ping Identity DevOps Helm chart](https://helm.pingidentity.com). If you are not using the Ping Identity DevOps Helm chart in production, we still recommend using it to generate your direct Kubernetes manifest files. Using our provided chart to create your files in this manner gives Ping Identity the best opportunity to support your environment.

Everything in Kubernetes is deployed by defining what you want and allowing Kubernetes to achieve the desired state ([the declarative model](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/)).

Helm simplifies your interaction by building deployment patterns into templates with variables. The Ping Identity Helm chart includes Kubernetes templates and default values maintained by Ping Identity. With these in hand, you only need to provide values for the template variables to match your environment.

For example, a service definition looks like the following file. With this file, Kubernetes is instructed to create a `service` resource with the name `myping-pingdirectory`.

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

Using our Helm chart, you can automatically define this entire resource and all other required resources for a basic deployment by setting `pingdirectory.enabled=true`.

### Terminology

**Manifests** - the final Kubernetes YAML files that are sent to the cluster for resource creation. These files are standard Kubernetes files and will be similar to the service example shown above.

**Helm Templates** - Go Template versions of Kubernetes YAML files. These templates enable the manifest creation to be parameterized.

**Values and values.yaml** - A value is the setting you pass to a Helm chart from which the templates produce the manifests you want. Values can be passed individually on the command line, but more commonly they are collected and defined in a file named **values.yaml**.  For example, if this file conained only this entry, the resulting Kubernetes manifest file would be over 200 lines long.


  ```yaml
  pingdirectory:
    enabled: true
  ```

**release** - When you deploy resources with Helm, you provide a name for identification. The combination of this name and the resources that are deployed using it make up a `release`. When using Helm, it is a common pattern to prefix all resources managed by a release with the release name. In our examples, `myping` is the release name, so you will see products in Kubernetes running with names similar to `myping-pingfederate-admin`, `myping-pingdirectory`, and `myping-pingauthorize`.

### Building the Helm Values File

This documentation focuses on the [Ping Identity DevOps Helm chart](https://github.com/pingidentity/helm-charts) and the values passed to the Helm chart to achieve your configuration. For your deployment to fit your goals, you must create a [values.yaml](https://helm.sh/docs/chart_template_guide/values_files/) file.

The most simple **values.yaml** for our Helm chart would be:

```yaml
global:
  enabled: true
```

By default, this flag is set as `global.enabled=false`. These two lines are sufficient to turn on (deploy) every available Ping Identity software product with a basic configuration.

### Providing your own server profile

In the documentation, there is an example for providing your own server profile stored in GitHub to PingDirectory.  The documenation provides this snippet in the values.yaml specific to that feature:

```yaml
pingdirectory:
  envs:
    SERVER_PROFILE_URL: https://github.com/<your-github-user>/pingidentity-server-profiles
```

This entry alone will not turn on PingDirectory, because the default value for `pingdirectory.enabled` is false. To complete the deployment, add the snippet to turn deploy and configure PingDirectory in the values.yaml file:

```yaml
global:
  enabled: true
pingdirectory:
  envs:
    SERVER_PROFILE_URL: https://github.com/<your-github-user>/pingidentity-server-profiles
```

This example snippet turns on all products, including PingDirectory, and overwrites the default `pingdirectory.envs.SERVER_PROFILE_URL` with `https://github.com/<your-github-user>/pingidentity-server-profiles`.

This use of substitution and parameters is where the power of Helm to simplify ease of deployment begins to shine. To fully customize your deployment, review all available options by running:

  ```sh
  helm show values pingidentity/ping-devops
  ```

This command prints all of the default values applied to your deployment. To overwrite any default values from the chart, copy the corresponding snippe and include it in your own values.yaml file with any modifications needed. Remember with YAML that tabbing and spacing matters. For most editors, copying all the way to the left margin and pasting at the very beginning of a line in your file should maintain proper indentation.

Helm also provides a wide variety of plugins. A useful one is [Helm diff](https://github.com/databus23/helm-diff).  This plugin shows what changes would be applied between Helm upgrade commands. For example, if this plugin indicates anything in a Deployment or Statefulset would change, you can expect the corresponding pods to be cycled. In this example, **Helm diff** is useful to note changes that would occur, particularly when you are not prepared for containers to be restarted.

### Additional Commands

As you go through the Helm examples, the goal is to build a values.yaml file that works in your environment.

##### Deploy a release:

  ```sh
  helm upgrade --install <release_name> pingidentity/ping-devops -f /path/to/values.yaml
  ```

##### Delete a release:

This command will remove all resources except PVC and PV objects associated with the release from the cluster:

  ```sh
  helm uninstall <release name>
  ```

##### Delete PVCs associated to a release:

  ```sh
  kubectl delete pvc --selector=app.kubernetes.io/instance=<release_name>
  ```

### Exit Codes

| Exit Code | Description |
|---|---|
| Exit Code 0 | Absence of an attached foreground process|
| Exit Code 1 | Indicates failure due to application error |
| Exit Code 137 | Indicates failure as container received SIGKILL (manual intervention or ‘oom-killer’ [OUT-OF-MEMORY]) |
| Exit Code 139 | Indicates failure as container received SIGSEGV |
| Exit Code 143 | Indicates failure as a container received SIGTERM |

### Example Configurations

The following links contain example configurations and examples of how to run and configure Ping products using the Ping Devops Helm Chart. Please review the [Getting Started Page](../get-started/introduction.md) before trying them.

| Config       | Description                                    | .yaml                                  |
| ------------ | ---------------------------------------------- | -------------------------------------- |
| Everything   | Example with most products integrated together | [everything.yaml](https://helm.pingidentity.com/examples/everything.yaml)     |
| PingFederate | PingFederate Admin Console & Engine            | [pingfederate.yaml](https://helm.pingidentity.com/examples/pingfederate.yaml) |
| Simple Sync  | PingDataSync and PingDirectory                 | [simple-sync.yaml](https://helm.pingidentity.com/examples/simple-sync.yaml)   |
