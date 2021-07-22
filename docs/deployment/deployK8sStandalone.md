---
title: Orchestrate Standalone Deployments
---
# ≈

Use the standalone configurations in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory as the base product configurations with the server profiles in our [pingidentity-server-profiles/getting-started](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/getting-started) repository.

You can use the commands in this topic with or without kustomize. When used without kustomize, as in this topic, the commands return some benign errors regarding `kustomization.yaml`. An example of a benign kustomize error is:

```text
unable to recognize "01-standalone/kustomization.yaml":
   no matches for kind "Kustomization" in version "kustomize.config.k8s.io/v1beta1"
```

You can deploy a single (standalone) product container, or a set of standalone containers using Kubernetes.

## Deploying the Containers

1. Go to any one of the product subdirectories in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory.
1. Orchestrate the deployment using the Kubernetes commands. For example:

      ```sh
      kubectl apply -f pingfederate/
      ```

1. To orchestrate a deployment of all of the products in your `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory, go to your local `pingidentity-devops-getting-started/20-kubernetes` directory and enter:

      ```sh
      kubectl apply -R -f 01-standalone/
      ```

## Cleaning Up

To clean up when you're finished, for a single product container, enter:

```ba
kubectl delete -f <container>/
```

Where &lt;container&gt; is the name of a product container, such as `pingfederate`.

For all products in the `01-standalone` directory, enter:

```ba
kubectl delete -R -f 01-standalone/
```
