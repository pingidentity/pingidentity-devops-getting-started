---
title: Deploy a local Kubernetes Cluster
---
# Deploy a local Demo Kubernetes Cluster

If you do not have access to a managed Kubernetes cluster you can deploy one on your local machine or VM.
This document describes deploying a cluster with [kind](https://kind.sigs.k8s.io/). Refer to the documentation for additional information.

!!! warning "Demo Use Only"
    The instructions in this document are for testing and learning, and not intended for use in production.

## Prerequisites

* [docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* ports 80 and 443 available on machine

!!! warning
    The following example was tested with Kubernetes version 1.21 and may not work with later versions.

!!! info "Docker System Resources"
    Docker on Linux is typically installed with root privileges and thus has access to the full resources of the machine. Docker Desktop for Mac and Windows provides a way to set the resources allocated to docker. For this documentation, a Macbook Pro was configured to use 3 CPUs and 6 GB Memory. You can adjust these values as necessary for your needs.

## Steps

1. [Install kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) on your platform.

1. Create a kind cluster with our sample `.yaml` file to enable ingress (application network exposure). Source yaml available [here](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kustomize/99-tools/kind.yaml)

    ```sh
    kind create cluster --config=kind.yaml
    ```

1. Test cluster health by running the following commands:

    ```sh
    kubectl cluster-info
    kubectl version
    kubectl get nodes
    ```

1. Next, install the nginx-ingress-controller for `kind`. The source yaml is available [here](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kustomize/99-tools/kind-nginx.yaml).

    ```sh
    kubectl apply -f kind-nginx.yaml
    ```

1. After the nginx deployment is in a healthy state, run:

    ```sh
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s
    ```

1. Verify nginx-ingress-controller is working:

    ```sh
    curl localhost

    <html>
    <head><title>404 Not Found</title></head>
    <body>
    <center><h1>404 Not Found</h1></center>
    <hr><center>nginx</center>
    </body>
    </html>
    ```

Our examples will use the domain `*ping-local.com` for accessing applications.  You can add all expected hosts to `/etc/hosts`:

```sh
echo '127.0.0.1 myping-pingaccess-admin.ping-local.com myping-pingaccess-engine.ping-local.com myping-pingauthorize.ping-local.com myping-pingauthorizepap.ping-local.com myping-pingdataconsole.ping-local.com myping-pingdelegator.ping-local.com myping-pingdirectory.ping-local.com myping-pingdatagovernance.ping-local.com myping-pingdatagovernancepap.ping-local.com myping-pingfederate-admin.ping-local.com myping-pingfederate-engine.ping-local.com' | sudo tee -a /etc/hosts > /dev/null
```

Setup is complete.

Your local Kubernetes environment should be ready to deploy our [Helm examples](https://helm.pingidentity.com/examples)
