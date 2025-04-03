---
title: Deploy a local Kubernetes Cluster
---
# Deploy a local Kubernetes Cluster

If you do not have access to a managed Kubernetes cluster you can deploy one on your local machine or or a virtual machine (VM).
This document describes deploying a cluster with [kind](https://kind.sigs.k8s.io/) and also for [minikube](https://minikube.sigs.k8s.io/docs/).  Refer to the documentation of each product for additional information.

!!! warning "Demo Use Only"
    The instructions in this document are for testing and learning, and not intended for use in production.

!!! note "Why not Docker Desktop?"
    The processes outlined on this page will create either a Kubernetes in Docker ([kind](https://kind.sigs.k8s.io/)) or a [minikube](https://minikube.sigs.k8s.io/docs/) cluster.  In both cases, the cluster you get is very similar in functionality to the Docker Desktop implementation of Kubernetes.  However, a distinct advantage of both offerings is portability (not requiring Docker Desktop). As with the [Getting Started](../get-started/getStartedExample.md) example, the files provided will enable and deploy an ingress controller for communicating with the services in the cluster from your local environment.

!!! warning "Kubernetes in Docker Desktop"
    To use the both examples below, you will need to ensure the Kubernetes feature of Docker Desktop is turned off, as it will conflict.

!!! info "Docker System Resources"
    This note applies only if using Docker as a backing for either solution. kind uses Docker by default, and it is also an option for minikube.  Docker on Linux is typically installed with root privileges and thus has access to the full resources of the machine. Docker Desktop for Mac and Windows provides a way to set the resources allocated to Docker. For this documentation, a Macbook Pro with the M4 chipset was configured to use 6 CPUs and 12 GB Memory. You can adjust these values as necessary for your needs.
## Kind cluster
This section will cover the **kind** installation process. See the [section further down](#minikube-cluster) for minikube instructions.
### Prerequisites

* [docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* ports 80 and 443 available on machine

!!! note "Kubernetes Version"
    For this guide, the kind implementation of Kubernetes 1.32.2 is used. It is deployed using version 0.27.0 of kind.

!!! note "Docker Desktop Version"
    At the time of the writing of this guide, Docker Desktop was version `4.39.0 (184744)`, running Docker Engine `28.0.1`.

### Install and confirm the cluster

1. [Install kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) on your platform.

1. Use the provided [sample kind.yaml](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kubernetes/kind.yaml) file to create a kind cluster named `ping` with ingress support enabled.  From the root of your copy of the repository code, run:

    ```sh
    kind create cluster --config=./20-kubernetes/kind.yaml
    ```

    Output:

    <img src="/../images/kindDeployOutput.png" alt="kind cluster start output"/>

1. Test cluster health by running the following commands:

    ```sh
    kubectl cluster-info

    # Output - port will vary
    Kubernetes control plane is running at https://127.0.0.1:64129
    CoreDNS is running at https://127.0.0.1:64129/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

    ------------------

    kubectl version

    < output clipped >
    Server Version: v1.32.2

    ------------------

    kubectl get nodes

    NAME                 STATUS   ROLES           AGE     VERSION
    ping-control-plane   Ready    control-plane   55m     v1.32.2
    ```

### Enable ingress

1. Next, install the nginx-ingress-controller for `kind` (version 1.12.1 at the time of this writing). In the event the Github file is unavailable, a copy has been made to this repository [here](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kubernetes/kind-nginx.yaml).

To use the Github file:
    ```sh
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/release-1.12/deploy/static/provider/kind/deploy.yaml
    ```

To use the local copy:
    ```sh
    kubectl apply -f ./20-kubernetes/kind-nginx.yaml
    ```

Output:
    ```
    namespace/ingress-nginx created
    serviceaccount/ingress-nginx created
    serviceaccount/ingress-nginx-admission created
    role.rbac.authorization.k8s.io/ingress-nginx created
    role.rbac.authorization.k8s.io/ingress-nginx-admission created
    clusterrole.rbac.authorization.k8s.io/ingress-nginx created
    clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
    rolebinding.rbac.authorization.k8s.io/ingress-nginx created
    rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
    clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
    clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
    configmap/ingress-nginx-controller created
    service/ingress-nginx-controller created
    service/ingress-nginx-controller-admission created
    deployment.apps/ingress-nginx-controller created
    job.batch/ingress-nginx-admission-create created
    job.batch/ingress-nginx-admission-patch created
    ingressclass.networking.k8s.io/nginx created
    validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
    ```

1. To wait for the Nginx ingress to reach a healthy state, run the following command.  You can also observe the pod status using k9s or by running `kubectl get pods --namespace ingress-nginx`. You should see one controller pod running when the ingress controller is ready.  This command should exit after no more than 90 seconds or so, depending on the speed of your computer and internet connection to pull the image:

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

Our examples will use the Helm release name `myping` and DNS domain suffix `pingdemo.example` for accessing applications.  You can add all expected hosts to `/etc/hosts`:

```sh
echo '127.0.0.1 myping-pingaccess-admin.pingdemo.example myping-pingaccess-engine.pingdemo.example myping-pingauthorize.pingdemo.example myping-pingauthorizepap.pingdemo.example myping-pingdataconsole.pingdemo.example myping-pingdelegator.pingdemo.example myping-pingdirectory.pingdemo.example myping-pingfederate-admin.pingdemo.example myping-pingfederate-engine.pingdemo.example myping-pingcentral.pingdemo.example' | sudo tee -a /etc/hosts > /dev/null
```

Setup is complete.  This local Kubernetes environment should be ready to deploy our [Helm examples](./deployHelm.md)

### Deploy the Example Stack

1. Create a namespace for running the stack in your Kubernetes cluster:

    ```sh
    # Create the namespace
    kubectl create ns pinghelm
    
    # Set the kubectl context to the namespace
    kubectl config set-context --current --namespace=pinghelm
    
    # Confirm
    kubectl config view --minify | grep namespace:
    ```

1. Create a secret in the namespace you will be using to run the example (pinghelm) using the `pingctl` utility. This secret will obtain an evaluation license based on your Ping DevOps username and key:

    ```sh
    pingctl k8s generate devops-secret | kubectl apply -f -
    ```

1. To install the chart, go to your local `"${PING_IDENTITY_DEVOPS_HOME}"/pingidentity-devops-getting-started/30-helm` directory and run the command shown here.  In this example, the release (deployment into Kubernetes by Helm) is called `myping`, forming the prefix for all objects created. The `ingress-demo.yaml` file configures the ingresses for the products to use the **_ping-local_** domain:

    ```sh
    helm upgrade --install myping pingidentity/ping-devops \
    -f everything.yaml -f ingress-demo.yaml
    ```

At this point, the flow will be the same as found in the [Getting Started Example](../get-started/getStartedExample.md) after the products are deployed using helm.  The URLs will be prefaced with `myping` rather than `demo`.

### Stop the cluster

When you are finished, you can remove the cluster by running the following command, which removes the cluster completely.  You will be required to recreate the cluster and reinstall the ingress controller to use `kind` again.

```sh
kind delete cluster --name ping
```
## Minikube cluster
In this section, a minikube installation with ingress is created.  Minikube is simpler than kind overall to configure, but ends up needing one step to configured a tunnel to the cluster that must be managed.  For this guide, the Docker driver will be used.  As with `kind` above, Kubernetes in Docker Desktop must be disabled.

### Prerequisites

* Container or virtual machine manager, such as: [Docker](https://minikube.sigs.k8s.io/docs/drivers/docker/), [QEMU](https://minikube.sigs.k8s.io/docs/drivers/qemu/), [Hyperkit](https://minikube.sigs.k8s.io/docs/drivers/hyperkit/), [Hyper-V](https://minikube.sigs.k8s.io/docs/drivers/hyperv/), [KVM](https://minikube.sigs.k8s.io/docs/drivers/kvm2/), [Parallels](https://minikube.sigs.k8s.io/docs/drivers/parallels/), [Podman](https://minikube.sigs.k8s.io/docs/drivers/podman/), [VirtualBox](https://minikube.sigs.k8s.io/docs/drivers/virtualbox/), or [VMware Fusion/Workstation](https://minikube.sigs.k8s.io/docs/drivers/vmware/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

!!! note "Minikube and Kubernetes Version"
    At the time of the writing of this guide, minikube was version `1.35.0`, which installs Kubernetes version `1.32.0`.

### Install and configure minikube

1. Install minikube for your platform.  See the product [Get Started!](https://minikube.sigs.k8s.io/docs/start/) page for details.

1. Configure the minikube resources and virtualization driver.  For example, the following options were used on an Apple Macbook Pro with Docker as the backing platform:

    ```sh
    minikube config set cpus 6
    minikube config set driver docker
    minikube config set memory 12g
    ```

    !!! note "Configuration"
        See [the documentation](https://minikube.sigs.k8s.io/docs/handbook/config/) for more details on configuring minikube.

1. Start the cluster.  Optionally you can include a profile flag (`--profile <name>`). Naming the cluster enables you to run multiple minikube clusters simultaneously.  If you use a profile name, you will need to include it on other minikube commands.

    ```sh
    minikube start --addons=ingress --kubernetes-version=v1.32.0
    ```

    Output:

    <img src="/../images/minikubeStartOutput.png" alt="minikube start output"/>

1. Test cluster health by running the following commands:

    ```sh
    kubectl cluster-info

    # Output - Port will vary
    Kubernetes control plane is running at https://127.0.0.1:51042
    CoreDNS is running at https://127.0.0.1:51042/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

    ------------------

    kubectl version

    < output clipped >
    Server Version: v1.32.0

    ------------------

    kubectl get nodes

    NAME       STATUS   ROLES           AGE    VERSION
    minikube   Ready    control-plane   6m2s   v1.32.0
    ```

### Confirm ingress

1.  Confirm ingress is operational:

    ```sh
    kubectl get po -n ingress-nginx
    
    NAME                                        READY   STATUS      RESTARTS   AGE
    ingress-nginx-admission-create-hnmhx        0/1     Completed   0          6m14s
    ingress-nginx-admission-patch-c4mct         0/1     Completed   1          6m14s
    ingress-nginx-controller-56d7c84fd4-qqffn   1/1     Running     0          6m14s
    ```

1.  Deploy a test application

    Use the following YAML file to create a Pod, Service and Ingress:

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: example-web-pod
      labels:
        role: webserver
    spec:
      containers:
        - name: web
          image: nginx
          ports:
            - name: web
              containerPort: 80
              protocol: TCP
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: example-svc
    spec:
      selector:
        role: webserver
      ports:
        - protocol: TCP
          port: 80
    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: example-ingress
      namespace: default
      annotations:
        spec.ingressClassName: nginx
    spec:
      rules:
        - host: example.k8s.local
          http:
            paths:
              - backend:
                  service:
                    name: example-svc
                    port:
                      number: 80
                path: /
                pathType: Prefix
    ```

    ```sh
    kubectl apply -f test.yaml

    pod/example-web-pod created
    service/example-svc created
    ingress.networking.k8s.io/example-ingress created
    ```

1.  Add an alias to the application to `/etc/hosts`

    ```sh
    echo '127.0.0.1 example.k8s.local' | sudo tee -a /etc/hosts > /dev/null
    ```

1.  Start a tunnel.  This command will tie up the terminal:

    ```sh
    minikube tunnel

    ✅  Tunnel successfully started

    📌  NOTE: Please do not close this terminal as this process must stay alive for the tunnel to be accessible ...
    
    ❗  The service/ingress example-ingress requires privileged ports to be exposed: [80 443]
    🔑  sudo permission will be asked for it.
    🏃  Starting tunnel for service example-ingress.
    ```

    Open a browser to `http://example.k8s.local`.  You should see the Nginx landing page.

1. Clean up tests

    ```sh
    kubectl delete -f test.yaml
    ```

Our examples will use the Helm release name `myping` and DNS domain suffix `pingdemo.example` for accessing applications.  You can add all expected hosts to `/etc/hosts`:

```sh
echo '127.0.0.1 myping-pingaccess-admin.pingdemo.example myping-pingaccess-engine.pingdemo.example myping-pingauthorize.pingdemo.example myping-pingauthorizepap.pingdemo.example myping-pingdataconsole.pingdemo.example myping-pingdelegator.pingdemo.example myping-pingdirectory.pingdemo.example myping-pingfederate-admin.pingdemo.example myping-pingfederate-engine.pingdemo.example myping-pingcentral.pingdemo.example' | sudo tee -a /etc/hosts > /dev/null
```

Setup is complete.  This local Kubernetes environment should be ready to deploy our [Helm examples](./deployHelm.md)
### Optional features

#### Dashboard
Minikube provides other add-ons that enhance your experience when working with your cluster.  One such add-on is the Dashboard, which can also provide metrics as follows:

```sh
minikube addons enable metrics-server
minikube dashboard
```
#### Multiple nodes
If you have enough system resources, you can create a multi-node cluster.

For example, to start a 3-node cluster:
```sh
minikube start --nodes 3
```
!!! warning "Resources"
    Keep in mind that each node will receive the RAM/CPU/Disk configured for minikube.  Using the example configuration provided above, a 3-node cluster would need 36GB of RAM and 18 CPUs.

### Stop the cluster

When you are finished, you can stop the cluster by running the following command.  Stopping retains the configuration and state of the cluster (namespaces, deployments, and so on) that will be restored when starting the cluster again.  

```sh
minikube stop
```

You can also pause and unpause the cluster:

```sh
minikube pause
minikube unpause
```

Alternatively, you can delete the minikube environment, which will do a reset and recreate everything the next time it is started.

```sh
minikube delete 
```
