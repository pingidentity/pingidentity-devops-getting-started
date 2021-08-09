---
title: Deploy a Local Kubernetes Cluster
---
# Deploy a Local DEMO Kubernetes Cluster

If you **don't** have access to a managed Kubernetes cluster you can deploy one on your local machine or vm. 
This document descibes deploying a cluster with [kind](https://kind.sigs.k8s.io/). Use the kind site directly to find additional configuration. 

!!! warning "Demo Use Only"
    The instructions in this document are for testing and learning, and _not_ intended for use in production. 

## Prerequisites

* [docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* ports 80 and 443 available on machine

!!! info "Docker System Resources"
    Docker on linux is typically installed with root privileges and thus has access to the full resources of the machine. Docker for Mac and Windows has a UI to set the resources allocated to docker. Our test Docker for Mac is running with 3 CPUs and 6 GB Memory. Adjust as necessary to your needs. 

## Steps

Start by [installing kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) on your platform.

Then, create a kind cluster with our sample `.yaml` file to enable ingress (app exposure).

```
kind create cluster --config=10-kubernetes/99-tools/kind.yaml
```

Test cluster health with: 

```
kubectl cluster-info
kubectl version
kubectl get nodes
```

Next, Install the nginx-ingress-controller for `kind`

```
kubectl apply -f 10-kubernetes/99-tools/kind-nginx.yaml
```

Wait for nginx to become healthy: 

```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

check if nginx-ingress-controller is working:

```
curl localhost

<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```


Our examples will use the domain `*ping-local.com` for accessing applications. Since our applications are set up with host-based routing on `*.ping-local.com` you may want to use a tool like [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html). Alternatively, you can add all expected hosts to /etc/hsots:

```
echo '127.0.0.1 myping-pingaccess-admin.ping-local.com myping-pingaccess-engine.ping-local.com myping-pingauthorize.ping-local.com myping-pingauthorizepap.ping-local.com myping-pingdataconsole.ping-local.com myping-pingdelegator.ping-local.com myping-pingdirectory.ping-local.com myping-pingdatagovernance.ping-local.com myping-pingdatagovernancepap.ping-local.com myping-pingfederate-admin.ping-local.com myping-pingfederate-engine.ping-local.com' | sudo tee -a /etc/hosts > /dev/null
```


You should now be ready to test out some helm examples.