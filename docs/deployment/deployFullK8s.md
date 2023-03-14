---
title: Deploy a robust local Kubernetes Cluster
---
# Deploy a robust local Kubernetes Cluster

In some cases, a single-node cluster is insufficient for more complex testing scenarios.  If you do not have access to a managed Kubernetes cluster and want something more similar to what you would find in a production environment, this guide can help.

This document describes deploying a multi-node cluster using the [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm//) utility, running under virtual machines. When completed, the cluster will consist of:

- 3 nodes, a master with two worker nodes (to conserve resources, the master will also be configured to run workloads)
- Kubernetes 1.26.2 using the **containerd** runtime (no Docker installed)
- Load balancer
- Block storage support for PVC/PV needed by some Ping products
- (Optional) Ingress controller
- (Optional) Istio service mesh
- (Optional) supplementary tools for tracing and monitoring

!!! warning "Demo Use Only"
    While the result is a full Kubernetes installation, the instructions in this document only create an environment sufficient for testing and learning.  The cluster is not intended for use in production environments.

!!! info "Manual process"
    At this time, work is underway to automate many, if not all of these steps. In the meantime, you will know more about how the cluster is configured and set up by following this guide.

## Prerequisites

In order to complete this guide, you will need:

- 64 GB of RAM (32 GB might be enough if you have an SSD to handle some memory swapping and reduce the RAM on the VMs to 12 GB)
- At least 150 GB of free disk
- Modern processor with multiple cores
- Virtualization solution.  For this guide, VMware Fusion is used, but other means of creating and running a VM (Virtualbox, KVM) can be adapted.
- Access to [Ubuntu LTS 22.04.2 server](https://ubuntu.com/download/server) installation media
- **A working knowledge of Kubernetes**, such as knowing how to port-forward, install objects using YAML files, and so on. Details on performing some actions will be omitted, and it is assumed the reader will know what to do.
- Patience

## Virtual machines

Create 3 VMs were created as described here.  The worker nodes are created by cloning a snapshot of the master after preliminary configuration is performed.  To begin, you will only create the master node. If cloning is not an option, you will need to perform all steps up to the `kubeadm init` command on all three VMs, configuring them in an identical fashion to each other except for hostname and IP.

- 4 vCPU
- 16 GB RAM
- 2 disks: 80 GB disk for the primary / 60 GB as secondary
- Attached to a network that allows internet access (bridged or NAT), using a fixed IP address

!!! info "IP Space"
    192.168.163.0/24 was the IP space used in this guide; adjust to your environment accordingly.

  | VM | Hostname | IP address |
    | --- | --- | --- |
    | Master node | k8s126master | 192.168.163.40 |
  | Worker | k8s126node01 | 192.168.163.41 |
  | Worker | k8s126node02 | 192.168.163.42 |

## Preliminary setup

Perform these actions on the master node VM.

### Install the Operating System

Install the operating system as default, using the first disk (80 GB) as the installation target.  For this guide, the installation disk was formatted to use the entire disk as the root partition, without LVM support.

After installation and reboot, upgrade all packages to the latest and perform the basic configuration needed:

```sh
# Upgrade all packages
sudo apt-get update -y && sudo apt-get upgrade -y

# Modify the /etc/hosts file, adding these entries
# Adjust the IP addresses accordingly
192.168.163.40 k8smaster
192.168.163.41 k8snode01
192.168.163.42 k8snode02

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

## Install container platform (containerd)

At this point, you will install the **containerd** runtime.

### containerd > 1.5.9

Kubernetes 1.26+ requires `containerd` runtime >= 1.6. The default installation from the Ubuntu repositories installs version 1.5.9.  The solution in this guide is to use the Docker repository for the installation of these packages.  At the time of this writing, 1.6.18-1 is installed in this manner.

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

In order for the **etcd** pod to remain stable, the `SystemdCgroup` flag for the runc options must be set to true.  The default configuration sets this boolean to false.

Modify **/etc/containerd/config.toml**.   The `runtime_type` is probably correct, but the `SystemdCgroup` default was **false**.  The two values to confirm or modify were at lines 112 and 125 at the time of this writing.

```txt
version = 2
  [plugins]
    [plugins."io.containerd.grpc.v1.cri"]
      [plugins."io.containerd.grpc.v1.cri".containerd]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"  <-- confirm or modify
            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true  <-- confirm or modify
```

Restart containerd: `sudo systemctl restart containerd`

## Install Kubernetes components

```sh
# Install prerequisites
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates \
  curl gnupg2 software-properties-common \
  bzip2 tar vim git wget net-tools lvm2

# Get the key and add the Kubernetes repository
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
# Install latest (1.26.2)
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

### Clone and update new VMs

From the **pre-kube-init** snapshot on the master, create a full clone to serve as a worker node, naming it accordingly.

When the clone is complete, perform the following actions:

- Regenerate the mac address on the network adapter and start up the new VM
- Update the network IP address by modifying **/etc/netplan/00-installer-config.yaml**
- Regenerate the SSH key:

  ```sh
  sudo /bin/rm -v /etc/ssh/ssh_host_*
  sudo dpkg-reconfigure openssh-server
  sudo systemctl restart ssh
  ```

- Update the hostname by running`sudo hostnamectl set-hostname <newname>`
- Update line 2 of **/etc/hosts** to match the new hostname
- Shutdown & snapshot with same snapshot name (**pre-kube-init**) as the master

Repeat for the second worker node.

## Install Kubernetes

Boot all three VMs.

**On the master only**, run `kubeadm init`.  

!!! error "IP address"
    Adjust the IP address accordingly for the `apiserver-advertise-address` and `control-plane-endpoint`f.

```sh
# On the master node only
# Pod CIDR is default for flannel
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs \
        --apiserver-advertise-address=192.168.163.40 \
        --control-plane-endpoint=192.168.163.40  \
        --cri-socket unix:///run/containerd/containerd.sock

# When finished, copy off the join command from the output for use on the other nodes
# Configure kubectl for the non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install CNI (flannel in this example)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

<details>
  <summary>Sample output of the installation</summary>

```text
# Sample output from init
[init] Using Kubernetes version: v1.26.2
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s126master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.163.40]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s126master localhost] and IPs [192.168.163.40 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s126master localhost] and IPs [192.168.163.40 127.0.0.1 ::1]
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
[apiclient] All control plane components are healthy after 10.001720 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
f5050f09f6fc60d3f8701b21bee71855f4c55e76b82aacd264afcf90191dc304
[mark-control-plane] Marking the node k8s126master as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s126master as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 7wc3xe.yt76msej78s4mtb9
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

  kubeadm join 192.168.163.40:6443 --token 7wc3xe.yt76msej78s4mtb9 \
 --discovery-token-ca-cert-hash sha256:d22f7753d0c5b28fe386e13fa57cc47a0e261e23cc98aa13b9316645dddefe56 \
 --control-plane --certificate-key f5050f09f6fc60d3f8701b21bee71855f4c55e76b82aacd264afcf90191dc304

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.163.40:6443 --token 7wc3xe.yt76msej78s4mtb9 \
 --discovery-token-ca-cert-hash sha256:d22f7753d0c5b28fe386e13fa57cc47a0e261e23cc98aa13b9316645dddefe56
```

</details>

### Remove taint from master

Removing the **_NoSchedule_** taint will allow workloads to run on the master node:

`kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-`

### Add other nodes

On the worker nodes, run the join command as indicated in the output of the installation on the master.  You can confirm that all nodes are working by running `kubectl get nodes` on the master.

#### Confirm operations with a simple deployment

Create a file named _nginx-deploy.yaml_ with these contents:

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

Apply the file to create the objects:  `kubectl apply -f nginx-deploy.yaml`  You should see the nginx deployment with 2 pods.

After confirming, remove it: `kubectl delete -f nginx-deploy.yaml`

### (optional) Install k9s

If you want the [k9s](https://github.com/derailed/k9s) utility, follow these steps.  Run these commands only on the master.

```sh
wget https://github.com/derailed/k9s/releases/download/v0.27.2/k9s_Linux_amd64.tar.gz
wget https://github.com/derailed/k9s/releases/download/v0.27.2/checksums.txt

# This command should return OK for the one file we downloaded; ignore other output
sha256sum -c checksums.txt

# Extract to /usr/local/bin
sudo tar Cxzvf /usr/local/bin k9s_Linux_amd64.tar.gz
```

## Create snapshot 'k8sInstalled'

Shutdown the VMs, and snapshot each one.  See the helper script in this repository located at `99-helper-scripts/manageCluster.sh` that can be used for automating things under VMware.

## MetalLB

A bare metal installation of Kubernetes does not provide a load balancer, which makes simulating some actions difficult.  In this section, you will install and configure the MetalLB load balancer.

### Installation

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

Create an IP pool that corresponds to the IP space in your environment.  Line 8 of the file will vary depending on your IP space:

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

Apply and confirm

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

# Confirm in a browser if desired at http://192.168.163.151
```

### Clean up

Remove the application by running `kubectl delete -f testLB.yaml`

## Create snapshot 'k8sMetal'

Shutdown the VMs, and snapshot each one.  See the helper script in this repository located at `99-helper-scripts/manageCluster.sh` that can be used for automating things under VMware.

## Rook and Ceph

Some Ping products require persistent storage through volumes, using a PVC/PV model.  In this section, you will install and configure Rook and Ceph to operate as a block storage option to support this need, including a default storage class.

### Confirm requirements

```sh
# Confirm no filesystem on second disk
# lsbkl -f should show no FSTYPE (empty), just the device name
# Run this command on each node
lsblk -f |grep sdb
```

Configure the cluster to support the admission controller by installing cert-manager:

```sh
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.11.0/cert-manager.yaml
```

### Install

```sh
# Get the code
git clone --single-branch --branch v1.10.12 https://github.com/rook/rook.git

# Navigate to the directory with the files we need
cd rook/deploy/examples

# Install the Rook operator
# Apply the necessary files
 kubectl apply -f crds.yaml -f common.yaml -f operator.yaml

# Verify the rook-ceph-operator is in the `Running` state before proceeding
# Alternatively, use k9s to monitor
kubectl -n rook-ceph get pod

# Use the production config (supports redundancy/replication of data)
kubectl apply -f cluster.yaml

# Confirm
# Deploy will take several minutes.  Confirm all pods are running before continuing.  This example is for three nodes:

kubectl get pod -n rook-ceph

NAME                                                     READY   STATUS      RESTARTS   AGE
csi-cephfsplugin-provisioner-68d67c47dd-87h6v            5/5     Running     0          3m27s
csi-cephfsplugin-provisioner-68d67c47dd-8l525            5/5     Running     0          3m27s
csi-cephfsplugin-px6dz                                   2/2     Running     0          3m27s
csi-cephfsplugin-qzn8p                                   2/2     Running     0          3m27s
csi-cephfsplugin-xlt6g                                   2/2     Running     0          3m27s
csi-rbdplugin-lchgj                                      2/2     Running     0          3m27s
csi-rbdplugin-mhbrn                                      2/2     Running     0          3m27s
csi-rbdplugin-provisioner-7686b584f5-mtbdb               5/5     Running     0          3m27s
csi-rbdplugin-provisioner-7686b584f5-vpkdb               5/5     Running     0          3m27s
csi-rbdplugin-xgxpm                                      2/2     Running     0          3m27s
rook-ceph-crashcollector-k8s126master-68f8544cf4-sztnp   1/1     Running     0          2m29s
rook-ceph-crashcollector-k8s126node1-576566657f-d8rzg    1/1     Running     0          118s
rook-ceph-crashcollector-k8s126node2-68f88b6c4d-tfkh8    1/1     Running     0          2m
rook-ceph-mgr-a-6bd475b77b-fpv4m                         3/3     Running     0          2m39s
rook-ceph-mgr-b-5b54874985-fvlmf                         3/3     Running     0          2m38s
rook-ceph-mon-a-7b89d4576d-qkzcq                         2/2     Running     0          4m24s
rook-ceph-mon-b-7668864f8-bsrhp                          2/2     Running     0          3m53s
rook-ceph-mon-c-7cc896d469-hlchp                         2/2     Running     0          3m40s
rook-ceph-operator-659649f647-8c89d                      1/1     Running     0          46m
rook-ceph-osd-0-59d877889d-z5mvp                         2/2     Running     0          2m
rook-ceph-osd-1-66558bd8bc-t4cck                         2/2     Running     0          117s
rook-ceph-osd-2-84886885f4-xnhcm                         2/2     Running     0          119s
rook-ceph-osd-prepare-k8s126master-4plhb                 0/1     Completed   0          2m15s
rook-ceph-osd-prepare-k8s126node1-k5m9w                  0/1     Completed   0          2m15s
rook-ceph-osd-prepare-k8s126node2-xxz7t                  0/1     Completed   0          2m15s
```

### Confirm status of the storage system

Deploy a toolbox pod for storage commands commands

```sh
#Deploy the pod
kubectl create -f toolbox.yaml
```

To verify that the ceph cluster is in a healthy state, connect to the Rook toolbox pod with the `kubectl exec` command and run the `ceph status` command.

```sh
# Access the pod to run commands
# You may have to press Enter to get a prompt
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash

# Overall status of the ceph cluster
## All mons should be in quorum
## A mgr should be active
## At least one OSD should be active
ceph status

  cluster:
    id:     184f1c82-4a0b-499a-80c6-44c6bf70cbc5
    health: HEALTH_WARN
            1 pool(s) do not have an application enabled

  services:
    mon: 3 daemons, quorum a,b,c (age 3m)          <-- mons in quorum
    mgr: a(active, since 2m), standbys: b          <-- active mgr
    osd: 3 osds: 3 up (since 3m), 3 in (since 3m)  <-- 1 or more OSD

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

# (optional) Remove the toolbox pod
kubectl delete -f toolbox.yaml
```

### Create storage class

Apply the storage class YAML file to create the storage class

```yaml
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

Run `kubectl create -f sc-ceph-block.yaml`

Test with mysql and wordpress examples from Rook

```sh
# If necessary, navigate to the examples folder
cd ~/rook/deploy/examples

# Create a MySQL/Wordpress deployment
kubectl create -f mysql.yaml
kubectl create -f wordpress.yaml

# Confirm you can see the PVCs created
kubectl get pvc

NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
mysql-pv-claim   Bound    pvc-a3f95bfb-351e-4270-b9eb-5a18cb857f21   20Gi       RWO            rook-ceph-block   93s
wp-pv-claim      Bound    pvc-78b47636-4a6c-459e-a5b8-05df61007f94   20Gi       RWO            rook-ceph-block   92s

kubectl get service wordpress

NAME              TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)        AGE
wordpress         LoadBalancer   10.97.225.93   192.168.163.151   80:32302/TCP   36s

# Access Wordpress in the browser. It should have an IP address from MetalLB (http://192.168.163.151)
# You may have to force a refresh of your browser.
```

Set the storage class you created as the default (`storageclass.kubernetes.io/is-default-class=true`)

```sh
# Before
kd sc rook-ceph-block
Name:                  rook-ceph-block
IsDefaultClass:        No
Annotations:           <none>
...

# Alter annotation
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# After
kd sc rook-ceph-block
Name:                  rook-ceph-block
IsDefaultClass:        Yes
Annotations:           <none>
...
```

Cleanup the deployment

```sh
kubectl delete -f wordpress.yaml
kubectl delete -f mysql.yaml
kubectl delete pvc/mysql-pv-claim pvc/wp-pv-claim
```

## Snapshot 'k8sMetalRook'

Shutdown the VMs, and snapshot each one.  See the helper script in this repository located at `99-helper-scripts/manageCluster.sh` that can be used for automating things under VMware.

## Ingress controller and Istio

This section is optional.  If you are on a system with fewer resources than recommended, you can skip this part.

### Ingress Nginx

Installation

```sh
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

After installation completes, you should have the Nginx controller running in the ingress-nginx namespace, and a load-balancer attached service for the ingress

```sh
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

### Istio

Installation will use the demo profile; this will add the ingress and egress gateways and size the Envoy sidecar smaller.

#### Prerequisites

In order to install Istio, you will need the `istioctl` utility.  On the Mac, you can use **brew** to install this application, or you can download the archive for your platform from the [release page](https://github.com/istio/istio/releases/tag/1.17.1).  You will need this archive to get the profile and add-on software in either case. Download the latest version (1.17.1 at the time of this writing). On the system used to develop this guide, the **_istioctl_** binary was installed using brew but the one contained in the archive can be used as an alternative. The instructions on installation are [here](https://istio.io/latest/docs/setup/getting-started/).

#### Installation

Extract the archive to a known location on your filesystem.

```sh
# Downloads directory is assumed.
cd ~/Downloads

# Extract the archive
tar xvzf istio-1.17.1-osx.tar.gz

# Navigate to the profile directory and install the demo profile
cd istio-1.17.1/manifests/profiles/
istioctl install -f demo.yaml

This will install the Istio 1.17.1 default profile with ["Istio core" "Istiod" "Ingress gateways" "Egress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Egress gateways installed
✔ Installation complete
Making this installation the default for injection and validation.

Thank you for installing Istio 1.17.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/hMHGiwZHPU7UQRWe9
```

#### Add ons (optional)

The add-ons are the Kiali UI (for Istio), Jaeger, Grafana and Prometheus. The Kubernetes yaml files are included with each release of Istio and are specific to that release:

```sh
# Navigate to the root of the extracted archive
cd ../..

# Apply the files to install the products
kubectl apply -f samples/addons
```

### Configure Optional Applications for Access

With the load balancer in place, you can configure the services for the Istio add-ons to receive an IP address.  Edit the service for each of Grafana, Kiali, Jaeger (tracing service) and Prometheus to use a LoadBalancer instead of a ClusterIP.  When you are done, each should have an address assigned from MetalLB:

```sh
 kubectl get -n istio-system svc

NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)                                                                      AGE
grafana                LoadBalancer   10.111.62.240    192.168.163.155   3000:30319/TCP                                                               25m
istio-egressgateway    ClusterIP      10.96.6.225      <none>            80/TCP,443/TCP                                                               27m
istio-ingressgateway   LoadBalancer   10.103.138.190   192.168.163.152   15021:32732/TCP,80:30065/TCP,443:30886/TCP,31400:30599/TCP,15443:30732/TCP   27m
istiod                 ClusterIP      10.97.52.234     <none>            15010/TCP,15012/TCP,443/TCP,15014/TCP                                        27m
jaeger-collector       ClusterIP      10.100.61.0      <none>            14268/TCP,14250/TCP,9411/TCP                                                 25m
kiali                  LoadBalancer   10.106.88.19     192.168.163.153   20001:31277/TCP,9090:30502/TCP                                               25m
prometheus             LoadBalancer   10.101.166.132   192.168.163.154   9090:32112/TCP                                                               25m
tracing                LoadBalancer   10.96.226.87     192.168.163.156   80:31510/TCP,16685:32309/TCP                                                 25m
zipkin                 ClusterIP      10.109.64.92     <none>            9411/TCP                                                                     25m
```

In the example above, the following URLs would be used to access the user interfaces (UIs) of each product:

- Kiali:  <http://192.168.163.153:20001/>
- Grafana: <http://192.168.163.155:3000/>
- Prometheus: <http://192.168.163.154:9090/>
- Jaeger: <http://192.168.163.156>

## Snapshot 'k8sComplete'

Shutdown the VMs, and snapshot each one.  See the helper script in this repository located at `99-helper-scripts/manageCluster.sh` that can be used for automating things under VMware.

## Resources & References

This guide was built on the work of others. As with many how-to documents, we have contributed our skills and knowledge to pull everything together and fill in the gaps that were experienced.  However, we want to acknowledge at least some of the many sources where we found inspiration, guidance, fixes for errors, and sanity when a step was missed. Not shown here are dozens of places where we went in exploring different options for pieces we did not use or install in the end. *the Ping BRASS team*

- [How to Deploy MetalLB on Kubernetes - ComputingForGeeks](https://computingforgeeks.com/deploy-metallb-load-balancer-on-kubernetes/)
- [How To: Ubuntu / Debian Linux Regenerate OpenSSH Host Keys - nixCraft](https://www.cyberciti.biz/faq/howto-regenerate-openssh-host-keys)
- [Block Storage Overview - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Storage-Configuration/Block-Storage-RBD/block-storage/#advanced-example-erasure-coded-block-storage)
- [Toolbox - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Troubleshooting/ceph-toolbox/#interactive-toolbox)
- [Quickstart - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Getting-Started/quickstart)
- [How to Install Kubernetes on Ubuntu 22.04 / Ubuntu 20.04 | ITzGeek](https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-kubernetes-on-ubuntu-22-04.html)
- [Kubernetes 1.26 - The electrifying release setup - KubeSimplify](https://blog.kubesimplify.com/kubernetes-126)
- [Containerd Github](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
- [etcd-io Github issue #13670](https://github.com/etcd-io/etcd/issues/13670)
