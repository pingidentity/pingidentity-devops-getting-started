---
title: Deploy a local Kubernetes Cluster
---
# Deploy a local Kubernetes Cluster

If you do not have access to a managed Kubernetes cluster you can deploy one on your local machine or VM.
This document describes deploying a cluster with [kind](https://kind.sigs.k8s.io/). Refer to the documentation for additional information.

!!! warning "Demo Use Only"
    The instructions in this document are for testing and learning, and not intended for use in production.

!!! note "Why not Docker Desktop?"
    The process outlined on this page will create a Kubernetes in Docker ([kind](https://kind.sigs.k8s.io/)) cluster.  Kind is very similar in functionality to the Docker Desktop implementation of Kubernetes, but the advantage here is that it is more portable (not requiring Docker Desktop). In addition, the files provided will enable and deploy an ingress controller for communicating with the services in the cluster. In the [Getting Started](../get-started/getStartedExample.md) example, port-forwarding was needed with Docker Desktop.  With the ingress in place, a port-forward is not required.

## Prerequisites

* [docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* ports 80 and 443 available on machine

!!! info "Docker System Resources"
    Docker on Linux is typically installed with root privileges and thus has access to the full resources of the machine. Docker Desktop for Mac and Windows provides a way to set the resources allocated to Docker. For this documentation, a Macbook Pro was configured to use 3 CPUs and 6 GB Memory. You can adjust these values as necessary for your needs.

!!! note "Kubernetes Version"
    For this guide, the kind implementation of Kubernetes 1.23 is used.

## Steps

1. [Install kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) on your platform.

1. Use the provided [sample kind.yaml](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kubernetes/kind.yaml) file to create a kind cluster named `ping` with ingress enabled.  From the root of the repository code, run:

    ```sh
    kind create cluster --config=./20-kubernetes/kind.yaml
    ```

    Output:

    <img src="/../images/kindDeployOutput.png"/>

1. Test cluster health by running the following commands:

    ```sh
    kubectl cluster-info

    Kubernetes control plane is running at https://127.0.0.1:58527
    CoreDNS is running at https://127.0.0.1:58527/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    
    kubectl version --short
    
    < output removed >
    Server Version: v1.23.6

    kubectl get nodes

    NAME                 STATUS   ROLES                  AGE   VERSION
    ping-control-plane   Ready    control-plane,master   14m   v1.23.6
    ```

1. Next, install the nginx-ingress-controller for `kind`. In the event the Github file is unavailable, a copy has been made to this repository [here](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kubernetes/kind-nginx.yaml).

To use the Github file:
    ```sh
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/1.23/deploy.yaml
    ```

To use the local copy:
    ```sh
    kubectl apply -f ./20-kubernetes/kind-nginx.yaml
    ```

1. To wait for the Nginx ingress to reach a healthy state, run the following command.  You can also observe the pod status using k9s or by running `kubectl get pods --namespace ingress-nginx`. You should see one controller pod running when the ingress controller is ready.  This command should exit after no more than 90 seconds or so, depending on the speed of your computer:

    ```sh
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s
    ```

1. Verify nginx-ingress-controller is working:

    ```sh
    curl localhost
    ```

    Output:
    ```sh
    <html>
    <head><title>404 Not Found</title></head>
    <body>
    <center><h1>404 Not Found</h1></center>
    <hr><center>nginx</center>
    </body>
    </html>
    ```

Our examples will use the Helm release name `myping` and DNS domain suffix `*ping-local.com` for accessing applications.  You can add all expected hosts to `/etc/hosts`:

```sh
echo '127.0.0.1 myping-pingaccess-admin.ping-local.com myping-pingaccess-engine.ping-local.com myping-pingauthorize.ping-local.com myping-pingauthorizepap.ping-local.com myping-pingdataconsole.ping-local.com myping-pingdelegator.ping-local.com myping-pingdirectory.ping-local.com myping-pingdatagovernance.ping-local.com myping-pingdatagovernancepap.ping-local.com myping-pingfederate-admin.ping-local.com myping-pingfederate-engine.ping-local.com myping-pingcentral.ping-local.com' | sudo tee -a /etc/hosts > /dev/null
```

Setup is complete.  This local Kubernetes environment should be ready to deploy our [Helm examples](https://helm.pingidentity.com/examples)

## Stop the cluster

When you are finished, you can remove the cluster by running the following command.  Doing so will require you to create the cluster and install the ingress controller when you want another cluster.

```sh
kind delete cluster --name ping
```
