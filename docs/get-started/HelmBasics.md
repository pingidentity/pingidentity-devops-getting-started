---
title: Helm Basics
---

# Helm Basics

Although this document can't cover the depths of these tools, brand-new Helm users might find other technical documentation too involved for Ping Identity DevOps purposes. This document aims to equip new users with helpful terminology in simple terms, with a focus on relevant commands. For more in-depth documentation around Helm, check out [helm.sh](https://helm.sh).

!!! note
    This overview uses Ping Identity DevOps as a guide, but generally applies to any interactions in Kubernetes. Therefore, this document might feel incomplete or inaccurate to veterans. If you'd like to contribute, feel free to open a pull request!

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

### Additional Commands

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

### Exit Codes

| Exit Code | Description |
|---|---|
| Exit Code 0 | Absence of an attached foreground process|
| Exit Code 1 | Indicates failure due to application error |
| Exit Code 137 | Indicates failure as container received SIGKILL (manual intervention or ‘oom-killer’ [OUT-OF-MEMORY]) |
| Exit Code 139 | Indicates failure as container received SIGSEGV |
| Exit Code 143 | Indicates failure as a container received SIGTERM |

### Example Configs

The following contains example configs and examples of how to run and configure Ping products
using the Ping Devops Helm Chart. Please review the [Getting Started Page](getStarted.md) before trying them.

| Config       | Description                                    | .yaml                                  |
| ------------ | ---------------------------------------------- | -------------------------------------- |
| Everything   | Example with most products integrated together | [everything.yaml](https://helm.pingidentity.com/examples/everything.yaml)     |
| PingFederate | PingFederate Admin Console & Engine            | [pingfederate.yaml](https://helm.pingidentity.com/examples/pingfederate.yaml) |
| Simple Sync  | PingDataSync and PingDirectory                 | [simple-sync.yaml](https://helm.pingidentity.com/examples/simple-sync.yaml)   |
