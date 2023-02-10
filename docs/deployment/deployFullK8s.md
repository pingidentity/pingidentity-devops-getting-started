---
title: Deploy a robust local Kubernetes Cluster
---
# Deploy a robust local Kubernetes Cluster

In some cases, a single-node cluster is insufficient for more complex testing scenarios.  If you do not have access to a managed Kubernetes cluster and want something more similar to what you would find in a production environment, this guide can help.

This document describes deploying a multi-node cluster using the [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm//) utility, running under virtual machines. When completed, the cluster will consist of:

- 3 nodes, a master with two worker nodes (to conserve resources, the master will also be configured to run workloads)
- Kubernetes 1.26.1 using the **containerd** or **cri-o** runtime (no Docker installed)
- Load balancer
- Block storage support for PVC/PV implementations
- (Optional) Ingress controller
- (Optional) Istio service mesh
- (Optional) supplementary tools for tracing and monitoring

!!! warning "Demo Use Only"
    While a full Kubernetes installation, the instructions in this document only create an environment sufficient for testing and learning.  The cluster is not intended for use in production environments.

## Prerequisites

In order to complete this guide, you will need:

  - A laptop or desktop with sufficient resources.
    - 64 GB of RAM (32GB might be enough if you reduce the VM RAM allocation to 8GB each)
    - At least 150 GB of free disk
    - Modern processor with multiple cores
  - Virtualization solution.  For this guide, VMware Fusion is used, but other means of creating and running a VM (Virtualbox, KVM) can be adapted.
  - Access to Ubuntu LTS 22.04.1 server installation media
  - Patience
  - **A working knowledge of Kubernetes**, such as knowing how to port-forward, install objects using YAML files, and so on. Details on performing some actions will be omitted, and it is assumed the reader will know what to do.

## Virtual machines

Create 3 VMs were created as described here.  The worker nodes are created by cloning a snapshot of the master after preliminary configuration is performed.  To begin with you will only create the master node.

  - 4 vCPU
  - 12GB RAM
  - 2 disks: 80 GB disk for the primary / 60 GB as secondary
  - Attached to a network that allows internet access (bridged or NAT), using a fixed IP address
    - 192.168.163.0/24 was the IP space used; adjust to your environment accordingly.

	| VM | Hostname | IP address |
    | --- | --- | --- |
    | Master node | k8s126master | 192.168.163.10 |
	| Worker | k8s126node01 | 192.168.163.11 |
	| Worker | k8s126node02 | 192.168.163.12 |

## Preliminary setup
Perform these actions on the master node VM.

### Install the Operating System

Install the operating system as default, using the first disk (80GB) as the installation target.  For this guide, the installation disk was formatted to use the entire disk as the root partition, without LVM support.

After installation and reboot, upgrade all packages to the latest:

```sh
# Upgrade all packages
sudo apt-get update -y && sudo apt-get upgrade -y

# Modify the /etc/hosts file, adding these entries
# Adjust the IP addresses accordingly
192.168.163.10 k8smaster
192.168.163.11 k8snode01
192.168.163.12 k8snode02

# Load the overlay and br_netfilter kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure the system to load the kernel modules at each boot
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
br_netfilter
overlay
EOF

# Enable IP forwarding for iptables
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Disable swap
sudo sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab
```
## Install container platform (containerd or cri-o)
At this point, you will choose either the **containerd** runtime or **cri-o**.

!!! error "Choose only one"
    Only install one of the two runtimes.

Skip to the **cri-o** section if you want to use that runtime.

### containerd > 1.59
Kubernetes 1.26+ requires `containerd` runtime >= 1.6. The default installation from the Ubuntu repositories installs version 1.59.  The solution in this guide is to use the Docker repository for the installation of these packages.  At the time of this writing, 1.16.12-1 is installed in this manner.
```sh
# Install and configure containerd
# Add the Docker repository for Ubuntu
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y

# Install containerd
sudo apt install -y containerd.io
sudo mkdir -p /etc/containerd

# Generate a default configuration
containerd config default | sudo tee /etc/containerd/config.toml

# Start containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
```

#### Fix / confirm settings

In order for the etcd pod to remain stable, the `SystemdCgroup` flag for the runc options must be set to true.  The default configuration sets this boolean to false.

Modify **/etc/containerd/config.toml**.   The `runtime_type` is probably correct, but the `SystemdCgroup` default was **false**.  The two values to confirm or modify were at lines 112 and 125 at the time of this writing.

```txt
version = 2
  [plugins]
    [plugins."io.containerd.grpc.v1.cri"]
      [plugins."io.containerd.grpc.v1.cri".containerd]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
```

Restart containerd: `sudo systemctl restart containerd`

Skip to the section **Installing the Kubernetes components**.

## CRI-O (no network piece)

Install cri-o and cri-o-runc

```sh
# Install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2  software-properties-common bzip2 tar 

# CRIO does not have an Ubuntu 22.04 version released
# The 20.04 version works fine
export OS_VERSION=xUbuntu_20.04
export CRIO_VERSION=1.23

# Add the repositories
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

sudo apt-get update

# Install cri-o
sudo apt-get install -y cri-o cri-o-runc

# Refresh systemctl and start crio
sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio

# Confirm.  Status should be 'running'
sudo systemctl status crio
```

## Install Kubernetes installation pieces

```sh
# Install prerequisites
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates \
  curl gnupg2 software-properties-common \
  bzip2 tar vim git wget net-tools

# Get the key and add the Kubernetes repository
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
# Install latest (1.26.1)
sudo apt-get install -y kubelet kubeadm kubectl

################################################
##### Optional to install specific version #####
################################################
# determine version available
# curl -s https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages | grep Version | awk '{print $2}'
# install version from list generated by previous command, for example:
# sudo apt-get install -y kubelet=1.24.9-00 kubectl=1.24.9-00 kubeadm=1.24.9-00
################################################
#####        end optional section          #####
################################################

# Lock K8s version
sudo apt-mark hold kubelet kubeadm kubectl
```

## Create snapshot 'pre-kube-init'

Halt the VM by running `sudo shutdown -h now`.

Create a snapshot of the VM, naming it **pre-kube-init**. This snapshot provides a rollback point in case the installation of Kubernetes fails.  You will use snapshots at several other key points for the same purpose. After installation is compete, these intermediate snapshots can be removed.

## Clone and update new VMs

From the **pre-kube-init** snapshot on the master, create a full clone to serve as a worker node, naming it accordingly.

When the clone is complete, perform the following actions:

- Regenerate the mac address on the network adaper and start up the new VM
- Update the network IP address by modifying **/etc/netplan/00-installer-config.yaml**
- Regenerate the SSH key:
  ```sh
  sudo /bin/rm -v /etc/ssh/ssh_host_*
  sudo dpkg-reconfigure openssh-server
  sudo systemctl restart ssh
  ```
- Update the hostname by running`sudo hostnamectl set-hostname <newname>`
- Update line 2 of **/etc/hosts** to match the new hostname
- Shutdown & snapshot with same snapshot name (pre-kube-init) as the master

Repeat for the second worker node.


# Install Kubernetes

Boot all three VMs.

**On the master only**, run `kubeadm init`.  Adjust the IP address accordingly.
```sh
# On the master node only
# Pod CIDR is default for flannel
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs \
	       --apiserver-advertise-address=192.168.163.30 \
	       --control-plane-endpoint=192.168.163.30  \
	       --cri-socket unix:///run/containerd/containerd.sock

# When finished, copy off the join command for use on the other nodes
# Configure kubectl for the non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI (flannel in this example)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

Sample output of the installation
```text
# Sample output from init
[init] Using Kubernetes version: v1.26.1
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s126master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.163.30]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s126master localhost] and IPs [192.168.163.30 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s126master localhost] and IPs [192.168.163.30 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 8.502840 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
5029ec6e95870b685ad365a845aa3b8a5f827f8409ba4ba310aa95db1134b111
[mark-control-plane] Marking the node k8s126master as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s126master as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 7xzbum.hv4em4pzy6jivlqo
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.163.30:6443 --token 7xzbum.hv4em4pzy6jivlqo \
	--discovery-token-ca-cert-hash sha256:ac9e95221e9ea5920e85dfce70dce89a7449ce3920123b8de6b855df746632ca \
	--control-plane --certificate-key 5029ec6e95870b685ad365a845aa3b8a5f827f8409ba4ba310aa95db1134b111

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.163.30:6443 --token 7xzbum.hv4em4pzy6jivlqo \
	--discovery-token-ca-cert-hash sha256:ac9e95221e9ea5920e85dfce70dce89a7449ce3920123b8de6b855df746632ca
```

### Remove taint from master

Removing the **_NoSchedule_** taint will allow workloads to run on the master node:
	`kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-`

### Add other nodes

On the worker nodes, run the join command as indicated in the output.  You can confirm that all nodes are working by running `kubectl get nodes` on the master.

#### Confirm operations with a simple deployment

Create a file named _nginx-deploy.yml_ with these contents:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
Apply the file to create the objects.  You should see the nginx deployment, and be able to access the landing page by port-forwarding to the service.
	`kubectl apply -f nginx-deploy.yaml`

After confirming, remove it: `kubectl delete -f nginx-deploy.yaml`

### (optional) Install k9s
If you want the [k9s](https://github.com/derailed/k9s) utility, follow these steps.  Run these only on the master.

```sh
wget https://github.com/derailed/k9s/releases/download/v0.27.2/k9s_Linux_amd64.tar.gz
wget https://github.com/derailed/k9s/releases/download/v0.27.2/checksums.txt

# This command should return OK for the one file we downloaded; ignore other output
sha256sum -c checksums.txt

# Extract to /usr/local/bin
sudo tar Cxzvf /usr/local/bin k9s_Linux_amd64.tar.gz
```

## Create snapshot 'k8sInstalled'

Shutdown the VMs, and snapshot each one.  See the helper script at the end for automating things under VMware.

## MetalLB

A bare metal installation of Kubernetes does not provide a load balancer, which makes simulating some actions difficult.  In this section, you will install and configure the MetalLB load balancer.

```sh
# Get latest tag
MetalLB_RTAG=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest \
|grep tag_name \
|cut -d '"' -f 4|sed 's/v//')

# Confirm version
echo $MetalLB_RTAG

# Grab and apply the native definition
mkdir ~/metal && cd ~/metal
wget https://raw.githubusercontent.com/metallb/metallb/v$MetalLB_RTAG/config/manifests/metallb-native.yaml
kubectl apply -f metallb-native.yaml
```

Create an IP pool that corresponds to the IP space in your environment.  Line 9 will vary depending on your IP space:

```yaml
# ipaddress_pool_metal.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: production
  namespace: metallb-system
spec:
  addresses:
  - 192.168.163.151-192.168.163.250

---

apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
```

Apply the file to create the pool:
```sh
# Apply the file
kubectl apply -f ipaddress_pool_metal.yaml

ipaddresspool.metallb.io/production created
l2advertisement.metallb.io/l2-advert created
```

### Confirm operations

Apply the test file to the cluster. The service should get an IP address from pool, reachable with a browser or curl call.

```yaml
# testLB.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
  namespace: default
spec:
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: httpd
        image: httpd:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-server-service
  namespace: default
spec:
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```
Install and confirm
```sh
# Apply the file
kubectl apply -f testLB.yaml

# Get IP address assigned
kubectl get svc

NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)        AGE
kubernetes           ClusterIP      10.96.0.1        <none>            443/TCP        87m
web-server-service   LoadBalancer   10.105.178.203   192.168.163.151   80:32671/TCP   96s

# Confirm with curl from outside the VM
curl 192.168.163.151
<html><body><h1>It works!</h1></body></html>

# Confirm in browser if desired at http://192.168.163.151
```

### Clean up

Remove the application by running `kubectl delete -f testLB.yaml`

## Create snapshot 'k8sMetal'

Shutdown the VMs, and snapshot each one.  See the helper script at the end for automating things under VMware.

## ROOK & CEPH

	- # Confirm prereqs
		- ```sh
		  # Confirm no filesystem on second disk
		  # lsbkl -f should show no FSTYPE
		  # run on each node
		  lsblk -f |grep sdb
		  ```
		- Configure for admission controller
			- `kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml`
		- LVM package installation, needed for raw device support
			- `sudo apt-get install -y lvm2`
		-
	- ## Install
		- Get the code
			- ```sh
			  git clone --single-branch --branch v1.10.8 https://github.com/rook/rook.git
			  cd rook/deploy/examples
			  ```
		- Deploy Rook Operator
			- ```sh
			  # Apply the necessary files
			  kubectl apply -f crds.yaml -f common.yaml -f operator.yaml
			  
			  # Verify the rook-ceph-operator is in the `Running` state before proceeding
			  kubectl -n rook-ceph get pod
			  
			  # Use production config
			  kubectl apply -f cluster.yaml
			  ```
		- Confirm
			- Deploy will take several minutes.  Confirm all pods are running before continuing.  This example is for three nodes:
			- ```sh
			  kubectl get pod -n rook-ceph
			  
			  NAME                                                     READY   STATUS      RESTARTS   AGE
			  csi-cephfsplugin-56mq6                                   2/2     Running     0          3m29s
			  csi-cephfsplugin-fxhtv                                   2/2     Running     0          3m29s
			  csi-cephfsplugin-jzrnz                                   2/2     Running     0          3m29s
			  csi-cephfsplugin-provisioner-7d7d99b967-hw68h            5/5     Running     0          3m29s
			  csi-cephfsplugin-provisioner-7d7d99b967-hzr8m            5/5     Running     0          3m29s
			  csi-rbdplugin-fstww                                      2/2     Running     0          3m29s
			  csi-rbdplugin-provisioner-97c94dd94-5pgcq                5/5     Running     0          3m29s
			  csi-rbdplugin-provisioner-97c94dd94-ch6r2                5/5     Running     0          3m29s
			  csi-rbdplugin-q6428                                      2/2     Running     0          3m29s
			  csi-rbdplugin-xmw9j                                      2/2     Running     0          3m29s
			  rook-ceph-crashcollector-k8s126master-7dbf54bf85-m727n   1/1     Running     0          111s
			  rook-ceph-crashcollector-k8s126node01-756f8c79fb-dv769   1/1     Running     0          110s
			  rook-ceph-crashcollector-k8s126node02-6d5df99ddf-j27m4   1/1     Running     0          2m7s
			  rook-ceph-mgr-a-79c6cc8b98-g76f7                         3/3     Running     0          2m25s
			  rook-ceph-mgr-b-bdbc85cdf-4x787                          3/3     Running     0          2m24s
			  rook-ceph-mon-a-58dd8f758b-fkstm                         2/2     Running     0          3m21s
			  rook-ceph-mon-b-7fdbbfcfc4-dkhlz                         2/2     Running     0          2m48s
			  rook-ceph-mon-c-b779d6577-v7mn5                          2/2     Running     0          2m37s
			  rook-ceph-operator-56b85d8f69-mqrvj                      1/1     Running     0          5m25s
			  rook-ceph-osd-0-768848cf7c-fhwzr                         2/2     Running     0          110s
			  rook-ceph-osd-1-6584b848fd-qfjk7                         2/2     Running     0          111s
			  rook-ceph-osd-2-ff8f5d785-bjw4w                          2/2     Running     0          110s
			  rook-ceph-osd-prepare-k8s126master-4dbzp                 0/1     Completed   0          79s
			  rook-ceph-osd-prepare-k8s126node01-d78rf                 0/1     Completed   0          75s
			  rook-ceph-osd-prepare-k8s126node02-txctz                 0/1     Completed   0          72s
			  ```
		- Deploy toolbox pd for storage commands commands
			- ```sh
			  kubectl create -f toolbox.yaml
			  
			  kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
			  ```
	- ## Confirm
	  collapsed:: true
		- To verify that the cluster is in a healthy state, connect to the Rook toolbox and run the `ceph status` command.
			- All mons should be in quorum
			- A mgr should be active
			- At least one OSD should be active
			- ```sh
			  # Overall status of the ceph cluster
			  ceph status
			  
			    cluster:
			      id:     184f1c82-4a0b-499a-80c6-44c6bf70cbc5
			      health: HEALTH_WARN
			              1 pool(s) do not have an application enabled
			  
			    services:
			      mon: 3 daemons, quorum a,b,c (age 3m)
			      mgr: a(active, since 2m), standbys: b
			      osd: 3 osds: 3 up (since 3m), 3 in (since 3m)
			  
			    data:
			      pools:   1 pools, 1 pgs
			      objects: 2 objects, 449 KiB
			      usage:   61 MiB used, 180 GiB / 180 GiB avail
			      pgs:     1 active+clean
			  
			  # Ceph object storage daemon (osd) status
			  ceph osd status
			  
			  ID  HOST           USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE
			   0  k8s126node01  20.4M  59.9G      0        0       0        0   exists,up
			   1  k8s126master  20.4M  59.9G      0        0       0        0   exists,up
			   2  k8s126node02  20.4M  59.9G      0        0       0        0   exists,up
			  
			  # Free disk available
			  ceph df
			  
			  --- RAW STORAGE ---
			  CLASS     SIZE    AVAIL    USED  RAW USED  %RAW USED
			  hdd    180 GiB  180 GiB  61 MiB    61 MiB       0.03
			  TOTAL  180 GiB  180 GiB  61 MiB    61 MiB       0.03
			  
			  --- POOLS ---
			  POOL  ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
			  .mgr   1    1  449 KiB        2  1.3 MiB      0     57 GiB
			  
			  # Reliable autonomic distributed object store (RADOS) view
			  rados df
			  
			  POOL_NAME     USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS      RD  WR_OPS       WR  USED COMPR  UNDER COMPR
			  .mgr       1.3 MiB        2       0       6                   0        0         0      96  82 KiB     113  1.3 MiB         0 B          0 B
			  
			  total_objects    2
			  total_used       61 MiB
			  total_avail      180 GiB
			  total_space      180 GiB
			  ```
	- ## Create storage class
	  collapsed:: true
		- Apply the storage class YAML file to create the storage class
			- ```yaml
			  #sc-ceph-block.yaml
			  apiVersion: ceph.rook.io/v1
			  kind: CephBlockPool
			  metadata:
			    name: replicapool
			    namespace: rook-ceph
			  spec:
			    failureDomain: host
			    replicated:
			      size: 3
			  ---
			  apiVersion: storage.k8s.io/v1
			  kind: StorageClass
			  metadata:
			     name: rook-ceph-block
			  # Change "rook-ceph" provisioner prefix to match the operator namespace if needed
			  provisioner: rook-ceph.rbd.csi.ceph.com
			  parameters:
			      # clusterID is the namespace where the rook cluster is running
			      clusterID: rook-ceph
			      # Ceph pool into which the RBD image shall be created
			      pool: replicapool
			  
			      # (optional) mapOptions is a comma-separated list of map options.
			      # For krbd options refer
			      # https://docs.ceph.com/docs/master/man/8/rbd/#kernel-rbd-krbd-options
			      # For nbd options refer
			      # https://docs.ceph.com/docs/master/man/8/rbd-nbd/#options
			      # mapOptions: lock_on_read,queue_depth=1024
			  
			      # (optional) unmapOptions is a comma-separated list of unmap options.
			      # For krbd options refer
			      # https://docs.ceph.com/docs/master/man/8/rbd/#kernel-rbd-krbd-options
			      # For nbd options refer
			      # https://docs.ceph.com/docs/master/man/8/rbd-nbd/#options
			      # unmapOptions: force
			  
			      # RBD image format. Defaults to "2".
			      imageFormat: "2"
			  
			      # RBD image features
			      # Available for imageFormat: "2". Older releases of CSI RBD
			      # support only the `layering` feature. The Linux kernel (KRBD) supports the
			      # full complement of features as of 5.4
			      # `layering` alone corresponds to Ceph's bitfield value of "2" ;
			      # `layering` + `fast-diff` + `object-map` + `deep-flatten` + `exclusive-lock` together
			      # correspond to Ceph's OR'd bitfield value of "63". Here we use
			      # a symbolic, comma-separated format:
			      # For 5.4 or later kernels:
			      #imageFeatures: layering,fast-diff,object-map,deep-flatten,exclusive-lock
			      # For 5.3 or earlier kernels:
			      imageFeatures: layering
			  
			      # The secrets contain Ceph admin credentials.
			      csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
			      csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
			      csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
			      csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
			      csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
			      csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
			  
			      # Specify the filesystem type of the volume. If not specified, csi-provisioner
			      # will set default as `ext4`. Note that `xfs` is not recommended due to potential deadlock
			      # in hyperconverged settings where the volume is mounted on the same node as the osds.
			      csi.storage.k8s.io/fstype: ext4
			  
			  # Delete the rbd volume when a PVC is deleted
			  reclaimPolicy: Delete
			    
			  # Optional, if you want to add dynamic resize for PVC.
			  # For now only ext3, ext4, xfs resize support provided, like in Kubernetes itself.
			  allowVolumeExpansion: true
			  ```
			- Run: `kubectl create -f sc-ceph-block.yaml`
		- Test with mysql and wordpress examples from Rook
			- ```sh
			  cd 
			  cd rook/deploy/examples
			  
			  kubectl create -f mysql.yaml
			  kubectl create -f wordpress.yaml
			  
			  kubectl get pvc
			  
			  kubectl get svc wordpress
			  
			  # Access WP int he browser
			  
			  
			  ```
		- Set default storage class (`storageclass.kubernetes.io/is-default-class=true`)
		- ```
		  
		  
		  # Before
		  kd sc rook-ceph-block
		  Name:                  rook-ceph-block
		  IsDefaultClass:        No
		  Annotations:           <none>
		  ...
		  kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
		  
		  # After
		  kd sc rook-ceph-block
		  Name:                  rook-ceph-block
		  IsDefaultClass:        Yes
		  Annotations:           <none>
		  ...
		  ```
		- Cleanup
			- ```sh
			  kubectl delete -f wordpress.yaml
			  kubectl delete -f mysql.yaml
			  kubectl delete pvc/mysql-pv-claim pvc/wp-pv-claim
			  ```
- # Snapshot 'k8sMetalRook'
  collapsed:: true
	- Shutdown the VMs, and snapshot each one.  See the helper script at the end for automating things under VMware.
- # Ingress controller and Istio
  collapsed:: true
	- ## Ingress
		- TODO: Research how to replace ingress completely with Istio ingressgateway via helm or whatever
		- Installation
			- ```sh
			  helm upgrade --install ingress-nginx ingress-nginx \
			    --repo https://kubernetes.github.io/ingress-nginx \
			    --namespace ingress-nginx --create-namespace
			  ```
			- After installation completes, you should have the nginx controller running in the ingress-nginx namespace, and a service attached to the load balancer for the ingress
				- ```sh
				  # List the pod
				  kubectl get po -n ingress-nginx
				  NAME                                        READY   STATUS    RESTARTS   AGE
				  ingress-nginx-controller-65dc77f88f-nqnc6   1/1     Running   0          7m1s
				  
				  # Examine the service
				  # Note the external IP from the MetalLB pool
				  kubectl get svc -n ingress-nginx
				  NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                      AGE
				  ingress-nginx-controller             LoadBalancer   10.98.47.72     192.168.163.151   80:30056/TCP,443:31316/TCP   7m36s
				  ingress-nginx-controller-admission   ClusterIP      10.96.230.188   <none>            443/TCP                      7m36s
				  ```
				-
	- ## Istio
		- Installation will use the demo profile; this will add the ingress and egress gateways and size the Envoy sidecar smaller.
		- ## Prerequisites
			- In order to install Istio, you will need the `istioctl` utility.  On the Mac, you can use brew to install this application, or you can download the archive for your platform from the []release page](https://github.com/istio/istio/releases/tag/1.16.2).  You will need this archive to get the profile and add-on software. Download the latest version (1.16.2 at the time of this writing). On the test system in question, the istioctl binary was installed using brew but the one contained in the archive can be used instead. The instructions for a manual installation are [here](https://istio.io/latest/docs/setup/getting-started/).
		- ## Installation
			- Extract the archive to a known location on your filesystem.
				- ```sh
				  # Downloads directory is assumed.
				  cd ~/Downloads
				  
				  # Extract the archive
				  tar xvzf istio-1.16.2-osx.tar.gz
				  
				  # Navigate to the profile directory and install
				  cd istio-1.16.2/manifests/profiles/
				  istioctl install -f demo.yaml
				  
				  This will install the Istio 1.16.2 default profile with ["Istio core" "Istiod" "Ingress gateways" "Egress gateways"] components into the cluster. Proceed? (y/N) y
				  ✔ Istio core installed
				  ✔ Istiod installed
				  ✔ Ingress gateways installed 
				  ✔ Egress gateways installed 
				  ✔ Installation complete
				  Making this installation the default for injection and validation.
				  
				  Thank you for installing Istio 1.16. Please take a few minutes to tell us about your install/upgrade experience! https://forms.gle/99uiMML96AmsXY5d6
				  ```
		- ## Add ons (optional)
			- The add-ons are the Kiali UI, Jaeger, Grafana and Prometheus. The Kubernetes yaml files are included with each release of Istio and are specific to that release:
				- ```sh
				  # Navigate to the root of the extracted archive
				  cd ../..
				  
				  # Apply the files to install the products
				  kubectl apply -f samples/addons
				  ```
- # Snapshot 'k8sComplete'
  collapsed:: true
	- Shutdown the VMs, and snapshot each one.  See the helper script at the end for automating things under VMware.
-
- ## Resources & References
	- https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-kubernetes-on-ubuntu-22-04.html
	- https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-cri-o-on-ubuntu-22-04.html
	- [https://computingforgeeks.com/deploy-metallb-load-balancer-on-kubernetes/](https://computingforgeeks.com/deploy-metallb-load-balancer-on-kubernetes/)
	- [https://github.com/openebs/cstor-operators/blob/develop/docs/quick.md](https://github.com/openebs/cstor-operators/blob/develop/docs/quick.md)
	- [https://github.com/openebs/zfs-localpv](https://github.com/openebs/zfs-localpv)
	- https://mayastor.gitbook.io/introduction
	- [How To: Ubuntu / Debian Linux Regenerate OpenSSH Host Keys - nixCraft](https://www.cyberciti.biz/faq/howto-regenerate-openssh-host-keys)
	- [Block Storage Overview - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Storage-Configuration/Block-Storage-RBD/block-storage/#advanced-example-erasure-coded-block-storage)
	- [Toolbox - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Troubleshooting/ceph-toolbox/#interactive-toolbox)
	- [Quickstart - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Getting-Started/quickstart)
	- [How to Install Kubernetes on Ubuntu 22.04 / Ubuntu 20.04 | ITzGeek](https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-kubernetes-on-ubuntu-22-04.html)
	- [How to install CRI-O on Ubuntu 22](https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-cri-o-on-ubuntu-22-04.html)
	- **Best guide** https://blog.kubesimplify.com/kubernetes-126
	- https://github.com/containerd/containerd/blob/main/docs/getting-started.md
	- HUGE FIX for containerd implementation https://github.com/etcd-io/etcd/issues/13670
	-
	-