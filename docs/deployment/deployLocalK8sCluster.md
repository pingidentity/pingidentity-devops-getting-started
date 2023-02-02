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

!!! info "Docker System Resources"
    This note applies only if using Docker as a backing for either solution. kind uses Docker by default, and it is also an option for minikube.  Docker on Linux is typically installed with root privileges and thus has access to the full resources of the machine. Docker Desktop for Mac and Windows provides a way to set the resources allocated to Docker. For this documentation, a Macbook Pro was configured to use 3 CPUs and 6 GB Memory. You can adjust these values as necessary for your needs.
## Kind cluster
This section will cover the **kind** installation process. See the [section further down](#minikube-cluster) for minikube instructions.
### Prerequisites

* [docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* ports 80 and 443 available on machine

!!! note "Kubernetes Version"
    For this guide, the kind implementation of Kubernetes 1.25.3 is used.

### Install and confirm the cluster

1. [Install kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) on your platform.

1. Use the provided [sample kind.yaml](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kubernetes/kind.yaml) file to create a kind cluster named `ping` with ingress support enabled.  From the root of your copy of the repository code, run:

    ```sh
    kind create cluster --config=./20-kubernetes/kind.yaml
    ```

    Output:

    <img src="/../images/kindDeployOutput.png"/>

1. Test cluster health by running the following commands:

    ```sh
    kubectl cluster-info

    # Output - port will vary
    Kubernetes control plane is running at https://127.0.0.1:63564
    CoreDNS is running at https://127.0.0.1:63564/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

    ------------------

    kubectl version --short

    < output clipped >
    Server Version: v1.25.3

    ------------------

    kubectl get nodes

    NAME                 STATUS   ROLES           AGE     VERSION
    ping-control-plane   Ready    control-plane   4m26s   v1.24.0
    ```

### Enable ingress

1. Next, install the nginx-ingress-controller for `kind`. In the event the Github file is unavailable, a copy has been made to this repository [here](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/20-kubernetes/kind-nginx.yaml).

To use the Github file:
    ```sh
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/kind/deploy.yaml
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
echo '127.0.0.1 myping-pingaccess-admin.ping-local.com myping-pingaccess-engine.ping-local.com myping-pingauthorize.ping-local.com myping-pingauthorizepap.ping-local.com myping-pingdataconsole.ping-local.com myping-pingdelegator.ping-local.com myping-pingdirectory.ping-local.com myping-pingfederate-admin.ping-local.com myping-pingfederate-engine.ping-local.com myping-pingcentral.ping-local.com' | sudo tee -a /etc/hosts > /dev/null
```

Setup is complete.  This local Kubernetes environment should be ready to deploy our [Helm examples](./deployHelm.md)

### Stop the cluster

When you are finished, you can remove the cluster by running the following command.  Doing so will require you to create the cluster and install the ingress controller when you want another cluster.

```sh
kind delete cluster --name ping
```
## Minikube cluster
In this section, a minikube installation with ingress is created.  Minikube is simpler than kind overall to configure, but does end up with an IP other than localhost that must be discovered.

### Prerequisites

* Container or virtual machine manager, such as: [Docker](https://minikube.sigs.k8s.io/docs/drivers/docker/), [QEMU](https://minikube.sigs.k8s.io/docs/drivers/qemu/), [Hyperkit](https://minikube.sigs.k8s.io/docs/drivers/hyperkit/), [Hyper-V](https://minikube.sigs.k8s.io/docs/drivers/hyperv/), [KVM](https://minikube.sigs.k8s.io/docs/drivers/kvm2/), [Parallels](https://minikube.sigs.k8s.io/docs/drivers/parallels/), [Podman](https://minikube.sigs.k8s.io/docs/drivers/podman/), [VirtualBox](https://minikube.sigs.k8s.io/docs/drivers/virtualbox/), or [VMware Fusion/Workstation](https://minikube.sigs.k8s.io/docs/drivers/vmware/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

!!! note "Kubernetes Version"
    At the time of the writing of this guide, minikube installs Kubernetes version 1.25.3.

### Install and configure minikube

1. Install minikube for your platform.  See the [Get Started!](https://minikube.sigs.k8s.io/docs/start/) page for details.

1. Configure the minikube resources and virtualization driver.  For example, the following was used on an Apple Macbook Pro with VMware Fusion installed as the backing platform:

    ```sh
    minikube config set cpus 6
    minikube config set driver vmware
    minikube config set memory 12g
    ```

    !!! note "Configuration"
        See [the documentation](https://minikube.sigs.k8s.io/docs/handbook/config/) for more details on configuring minikube.

1. Start the cluster.  Optionally you can include a profile flag (`--profile <name>`). Naming the cluster enables you to run multiple minikube clusters simultaneously, if so desired.  If you use a profile name, you will need to include it on other minikube commands.
    ```sh
    minikube start
    ```
    
    Output:

    <img src="/../images/minikubeStartOutput.png"/>

1. Test cluster health by running the following commands:

    ```sh
    kubectl cluster-info

    # Output - IP will vary
    Kubernetes control plane is running at https://172.16.106.134:8443
    CoreDNS is running at https://172.16.106.134:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

    ------------------

    kubectl version --short

    < output clipped >
    Server Version: v1.25.3

    ------------------

    kubectl get nodes

    NAME       STATUS   ROLES           AGE     VERSION
    minikube   Ready    control-plane   6m55s   v1.25.3
    ```

### Enable ingress

1.  Run the command to enable the ingress add-on:
   
    ```sh
    minikube addons enable ingress
    ```

1.  Confirm:

    ```sh
    kubectl get po -n ingress-nginx
    
    NAME                                        READY   STATUS      RESTARTS   AGE
    ingress-nginx-admission-create-gcv6p        0/1     Completed   0          77s
    ingress-nginx-admission-patch-zvvtd         0/1     Completed   0          77s
    ingress-nginx-controller-5959f988fd-mmps9   1/1     Running     0          77s
    ```

1.  Deploy a test application

    Use the following YAML file to create a deployment:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      labels:
        app: nginx
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:latest
            ports:
            - containerPort: 80
    ```

    ```sh
    kubectl apply -f test.yaml

    deployment.apps/nginx-deployment created
    ```

1.  Expose the deployment

    ```sh
    kubectl expose deployment nginx-deployment --type=NodePort --port=80
    ```

1.  Use a browser to connect to the service

    ```sh
    minikube ip

    #Output will vary
    172.16.106.134

    kubectl get service

    # Port (31140 in this example) will vary
    NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP        38m
    nginx-deployment   NodePort    10.109.70.162   <none>        80:31140/TCP   11m
    ```

    Open a browser to http://_minikubeIP_:_port_.  In this example, `http://172.16.106.134:31140`.  You should see the Nginx landing page.

1.  Create an ingress

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: ingress
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$1
    spec:
      rules:
        - host: example.kube.com
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: nginx-deployment
                    port:
                      number: 80
    ```

    ```sh
    kubectl apply -f ingress.yaml

    ingress.networking.k8s.io/ingress created
    ```
    Confirm (use your minikube IP)
    ```sh
    curl -I http://172.16.106.134 -H 'Host: example.kube.com'
    
    HTTP/1.1 200 OK
    Date: Wed, 04 Jan 2023 17:14:11 GMT
    Content-Type: text/html
    Content-Length: 615
    Connection: keep-alive
    Last-Modified: Tue, 13 Dec 2022 15:53:53 GMT
    ETag: "6398a011-267"
    Accept-Ranges: bytes
    ```

1. Clean up tests

    ```sh
    kubectl delete -f test.yaml
    kubectl delete -f ingress.yaml
    ```

Our examples will use the Helm release name `myping` and DNS domain suffix `*ping-local.com` for accessing applications.  You can add all expected hosts to `/etc/hosts`:

```sh
echo '<minikube IP> myping-pingaccess-admin.ping-local.com myping-pingaccess-engine.ping-local.com myping-pingauthorize.ping-local.com myping-pingauthorizepap.ping-local.com myping-pingdataconsole.ping-local.com myping-pingdelegator.ping-local.com myping-pingdirectory.ping-local.com myping-pingfederate-admin.ping-local.com myping-pingfederate-engine.ping-local.com myping-pingcentral.ping-local.com' | sudo tee -a /etc/hosts > /dev/null
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
If you have system resources, you can create a multi-node cluster.

For example, to start a 3-node cluster:
```sh
minikube start --nodes 3
```
!!! warning "Resources"
    Keep in mind that each node will receive the RAM/CPU/Disk configured for minikube.  Using the example configuration provided above, a 3-node cluster would need 36GB of RAM and 18 CPUs.


### Stop the cluster

When you are finished, you can stop the cluster by running the following command.  Stopping will retain the configuration and state of the cluster (namespaces, deployments, and so on) that will be recovered when starting the cluster again.  

```sh
minikube stop
```

You can also pause and unpause the cluster:

```sh
minikube pause
minikube unpause
```
Alternatively, you can delete the minikube environment, which will require reconfiguration the next time you start.

```sh
minikube delete 
```
