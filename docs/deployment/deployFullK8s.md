---
title: Deploy a robust local Kubernetes Cluster
---
# Deploy a robust local Kubernetes Cluster

!!! note "Video Demonstration"
    A video demonstrating the manual process outlined on this page is available [here](https://videos.pingidentity.com/detail/videos/devops/video/6324019967112/robust-test-kubernetes-cluster).  An updated video using the ansible playbooks is planned.

In some cases, a single-node cluster is insufficient for more complex testing scenarios.  If you do not have access to a managed Kubernetes cluster and want something more similar to what you would find in a production environment, this guide can help.

This document describes deploying a multi-node cluster using [ansible](https://docs.ansible.com/) and the [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm//) utility, running under virtual machines. When completed, the cluster will consist of:

- 3 nodes, a master with two worker nodes (to conserve resources, the master will also be configured to run workloads)
- (At the time of this writing) Kubernetes 1.28.2 using the **containerd** runtime (no Docker installed)
- (Optional but recommended) Load balancer
- Block storage support for PVC/PV needed by some Ping products
- (Optional) Ingress controller (ingress-nginx)
- (Optional) Istio service mesh
- (Optional) supplementary tools for tracing and monitoring with Istio

!!! warning "Demo Use Only"
    While the result is a full Kubernetes installation, the instructions in this document only create an environment sufficient for testing and learning.  The cluster is not intended for use in production environments.

## Prerequisites

In order to complete this guide, you will need:

- 64 GB of RAM (32 GB might be enough if you have an SSD to handle some memory swapping and reduce the RAM on the VMs to 12 GB)
- At least 150 GB of free disk
- Modern processor with multiple cores
- Ansible-playbook CLI tool. You can use brew by running `brew install ansible` or see [the ansible site](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) for instructions on how to install and configure this application.
- Virtualization solution.  For this guide, VMware Fusion is used, but other means of creating and running a VM (Virtualbox, KVM) can be adapted.
- Access to [Ubuntu LTS 22.04.3 server](https://ubuntu.com/download/server) installation media
- **A working knowledge of Kubernetes**, such as knowing how to port-forward, install objects using YAML files, and so on. Details on performing some actions will be omitted, and it is assumed the reader will know what to do.
- Patience

## Virtual machines

First, create 3 VMs as described here, using a default installation of Ubuntu 22.04.  For this guide, the user created was `ubuntu`. You can use any name with a password of your choice.

- 4 vCPU
- 16 GB RAM
- 2 disks: 80 GB disk for the primary / 60 GB as secondary
- Attached to a network that allows internet access (bridged or NAT), using a fixed IP address

!!! info "IP Space"
    192.168.163.0/24 was the IP space used in this guide; adjust to your environment accordingly.

  | VM          | Hostname  | IP address     |
  | ----------- | --------- | -------------- |
  | Master node | k8smaster | 192.168.163.60 |
  | Worker      | k8snode01 | 192.168.163.61 |
  | Worker      | k8snode02 | 192.168.163.62 |

## Preliminary Operating System setup

Perform these actions on all three VMs.

### Install the Operating System

Install the operating system as default, using the first disk (80 GB) as the installation target.  For this guide, the installation disk was formatted to use the entire disk as the root partition, without LVM support.

## Create snapshot 'base-os'

Halt each VM by running `sudo shutdown -h now`.

Create a snapshot of each VM, naming it **base-os**. This snapshot provides a rollback point in case issues arise later. You will use snapshots at several other key points for the same purpose. After installation is complete, these intermediate snapshots can be removed.

Power up each VM set after taking the snapshots.

### Prepare for using Ansible

!!! note "Run on the host machine"
    This block of commands is executed on the host.

```sh

# Add the IP addresses to the local hosts file for convenience
sudo tee -a /etc/hosts >/dev/null <<-EOF
192.168.163.60 k8smaster
192.168.163.61 k8snode01
192.168.163.62 k8snode02
EOF

# Copy the SSH key you will use to access the VMs from your host machine to each VM
# See https://www.ssh.com/academy/ssh/keygen for instructions on generating an SSH key
# For this guide, the ed25519 algorithm was used
# Adjust the key name accordingly in the ssh-copy-id command

export TARGET_MACHINES=("k8smaster" "k8snode01" "k8snode02")

for machine in "${TARGET_MACHINES[@]}"; do
    echo "Copying key to $machine:"
    ssh-copy-id -i ~/.ssh/localvms ubuntu@"$machine"
    echo "======================"
    echo "Confirming access.  You should not be prompted for a password and will be shown the hostname:"
    ssh -i ~/.ssh/localvms ubuntu@"$machine" 'hostname'
    echo
done
```

Sample output:
```txt
Copying key to k8smaster:
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/Users/davidross/.ssh/localvms.pub"
The authenticity of host 'k8smaster (192.168.163.60)' can't be established.
ED25519 key fingerprint is SHA256:qud9m1FRgwzJuwKcEsVVUbZ4bltYmiyKNj5e330ZQCA.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ubuntu@k8smaster's password:

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh 'ubuntu@k8smaster'"
and check to make sure that only the key(s) you wanted were added.

======================
Confirming access.  You should not be prompted for a password and will be shown the hostname:
k8smaster

<The output above is repeated for each node.>
```

After installation and reboot, perform the basic configuration needed for ansible support on the VMs.  The primary change required is to allow `sudo` commands without requiring a password:

!!! note "Per-VM"
    Run these commands on each VM.

```sh
# Modify /etc/sudoers to allow the ubuntu user to sudo without a password
# This configuration grants the user full root access with no password
# DO NOT DO THIS IN PRODUCTION!

echo "ubuntu  ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
```
### Configure Ansible Playbooks for your environment
At this point, you are ready to modify the ansible playbooks for creating your cluster.

1. If you have not already done so, clone the `pingidentity-devops-getting-started` repository to your local `${PING_IDENTITY_DEVOPS_HOME}` directory.

    !!! note "The `${PING_IDENTITY_DEVOPS_HOME}` environment variable was set by running `pingctl config`."

    ```sh
    cd "${PING_IDENTITY_DEVOPS_HOME}"
    git clone \
      https://github.com/pingidentity/pingidentity-devops-getting-started.git
    ```

1. Navigate to the directory with the ansible scripts:
   
   ```sh
   cd "${PING_IDENTITY_DEVOPS_HOME}"/pingidentity-devops-getting-started/99-helper-scripts/ansible
   ```

1. Modify the `inventory.ini`, `ansible.cfg`, `install_kubernetes.yaml` and `install_list.yaml` files accordingly to suit your environment:

   The **inventory.ini** will need modification for your IP addresses, private key file, and user if one other than `ubuntu` was used:
   ```text
   [kubernetes_master]
   k8smaster ansible_host=192.168.163.60
   
   [kubernetes_nodes]
   k8snode01 ansible_host=192.168.163.61
   k8snode02 ansible_host=192.168.163.62
   
   [all:vars]
   ansible_user=ubuntu
   ansible_ssh_private_key_file=/Users/davidross/.ssh/localvms
   ansible_python_interpreter=/usr/bin/python3
   ```

   The **ansible.cfg** file should not need any modification:
   ```text
   [defaults]
   inventory = inventory.ini
   host_key_checking = False
   ```

   The **install_kubernetes.yaml** file will need the following changes to lines 11-13 if your IP address differs from this example:

   ```text
    k8smaster_ip: "192.168.163.60"
    k8snode01_ip: "192.168.163.61"
    k8snode02_ip: "192.168.163.62"
   ```

   Finally, update the **install_list.yaml** file.  By default, no additional components are installed other than block storage, which is needed for some Ping products.  To install other optional components, set the value to **_True_**.  Note that helm is required to install the Ingress controller, and adding K9s, metallb and ingress will provide additional tools for the most production-like implementation:

   ```yaml
   ---
   helm: False
   k9s: False
   metallb: False
   storage: True
   ingress: False
   istio: False
   istioaddons: False
   ...
   ```

## Run the first playbook

With the changes above, you are now ready to run the playbooks.  First, run the **install_kubernetes.yaml** playbook to install Kubernetes.

`ansible-playbook install_kubernetes.yaml -i inventory.ini`

!!! note "Idempotency"
    The playbook was designed to to be idempotent so you can run it multiple times if needed.  An alternative is to reset to the **base-os** snapshot, update the `sudoers` file and run it again.

<details>
  <summary>Sample output</summary>

```text
PLAY [Install Kubernetes on all VMs] *******************************************

TASK [Gathering Facts] *********************************************************
ok: [k8smaster]
ok: [k8snode02]
ok: [k8snode01]

TASK [Update package cache] ****************************************************
ok: [k8snode02]
ok: [k8snode01]
ok: [k8smaster]

TASK [Upgrade all packages] ****************************************************
changed: [k8snode01]
changed: [k8snode02]
changed: [k8smaster]

TASK [Add host file entries] ***************************************************
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Add the br_netfilter kernel module and configure for load at boot] *******
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Add the overlay kernel module and configure for load at boot] ************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Creating kernel modules file to load at boot] ****************************
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Disable swap in fstab by commenting it out] ******************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Disable swap] ************************************************************
changed: [k8snode01]
changed: [k8snode02]
changed: [k8smaster]

TASK [Enable IP forwarding for iptables] ***************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Update sysctl parameters without reboot - bridge (ipv4)] *****************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Update sysctl parameters without reboot - bridge (ipv6)] *****************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Update sysctl parameters without reboot - IPforward] *********************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Install prerequisites] ***************************************************
changed: [k8snode02] => (item=containerd)
changed: [k8smaster] => (item=containerd)
changed: [k8snode01] => (item=containerd)

TASK [Add Kubernetes APT key] **************************************************
changed: [k8snode02]
changed: [k8smaster]
changed: [k8snode01]

TASK [Create directory for containerd configuration file] **********************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Check if containerd toml configuration file exists] **********************
ok: [k8smaster]
ok: [k8snode01]
ok: [k8snode02]

TASK [Create containerd configuration file if it does not exist] ***************
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Read config.toml file] ***************************************************
ok: [k8smaster]
ok: [k8snode01]
ok: [k8snode02]

TASK [Check if correct containerd.runtimes.runc line exists] *******************
ok: [k8smaster]
ok: [k8snode01]
ok: [k8snode02]

TASK [Error out if the incorrect or missing containerd.runtimes.runc line does not exist] ***
skipping: [k8smaster]
skipping: [k8snode01]
skipping: [k8snode02]

TASK [Set SystemdCgroup line in file to true if it is currently false] *********
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Restart containerd service] **********************************************
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Install prerequisites for Kubernetes] ************************************
changed: [k8snode02] => (item=apt-transport-https)
changed: [k8smaster] => (item=apt-transport-https)
changed: [k8snode01] => (item=apt-transport-https)
ok: [k8snode02] => (item=ca-certificates)
ok: [k8snode01] => (item=ca-certificates)
ok: [k8smaster] => (item=ca-certificates)
ok: [k8snode02] => (item=curl)
ok: [k8smaster] => (item=curl)
ok: [k8snode01] => (item=curl)
changed: [k8snode02] => (item=gnupg2)
changed: [k8snode01] => (item=gnupg2)
changed: [k8smaster] => (item=gnupg2)
ok: [k8snode02] => (item=software-properties-common)
ok: [k8snode01] => (item=software-properties-common)
ok: [k8smaster] => (item=software-properties-common)
changed: [k8snode02] => (item=bzip2)
changed: [k8snode01] => (item=bzip2)
changed: [k8smaster] => (item=bzip2)
ok: [k8snode02] => (item=tar)
ok: [k8snode01] => (item=tar)
ok: [k8smaster] => (item=tar)
ok: [k8snode02] => (item=vim)
ok: [k8snode01] => (item=vim)
ok: [k8smaster] => (item=vim)
ok: [k8snode02] => (item=git)
ok: [k8snode01] => (item=git)
ok: [k8smaster] => (item=git)
ok: [k8snode02] => (item=wget)
ok: [k8snode01] => (item=wget)
ok: [k8smaster] => (item=wget)
changed: [k8snode02] => (item=net-tools)
changed: [k8snode01] => (item=net-tools)
changed: [k8smaster] => (item=net-tools)
ok: [k8snode01] => (item=lvm2)
ok: [k8snode02] => (item=lvm2)
ok: [k8smaster] => (item=lvm2)

TASK [Add Kubernetes APT repository] *******************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Install Kubernetes components] *******************************************
changed: [k8snode01] => (item=kubelet)
changed: [k8snode02] => (item=kubelet)
changed: [k8smaster] => (item=kubelet)
changed: [k8snode01] => (item=kubeadm)
changed: [k8snode02] => (item=kubeadm)
changed: [k8smaster] => (item=kubeadm)
ok: [k8snode02] => (item=kubectl)
ok: [k8snode01] => (item=kubectl)
ok: [k8smaster] => (item=kubectl)

TASK [Hold Kubernetes packages at current version] *****************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Run kubeadm reset to ensure fresh start each time.] **********************
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Remove any files from a previous installation attempt] *******************
skipping: [k8snode01] => (item=/home/ubuntu/.kube) 
skipping: [k8snode01]
skipping: [k8snode02] => (item=/home/ubuntu/.kube) 
skipping: [k8snode02]
ok: [k8smaster] => (item=/home/ubuntu/.kube)

TASK [Initialize Kubernetes master] ********************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Check if k8s installation file exists] ***********************************
skipping: [k8snode01]
skipping: [k8snode02]
ok: [k8smaster]

TASK [Fail if K8s installed file does not exist] *******************************
skipping: [k8smaster]
skipping: [k8snode01]
skipping: [k8snode02]

TASK [Create .kube directory] **************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Copy kubeconfig to user's home directory] ********************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Install Pod network] *****************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Remove taint from master node] *******************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Retrieve join command from master and run it on the nodes] ***************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Join worker nodes to the cluster] ****************************************
skipping: [k8snode01] => (item=k8snode01) 
skipping: [k8snode01] => (item=k8snode02) 
skipping: [k8snode01]
skipping: [k8snode02] => (item=k8snode01) 
skipping: [k8snode02] => (item=k8snode02) 
skipping: [k8snode02]
changed: [k8smaster -> k8snode01(192.168.163.61)] => (item=k8snode01)
changed: [k8smaster -> k8snode02(192.168.163.62)] => (item=k8snode02)

TASK [Pause for 5 seconds] *****************************************************
Pausing for 5 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [k8smaster]

TASK [Confirm flannel pods are ready] ******************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Run confirmation command by listing nodes] *******************************
changed: [k8snode01 -> k8smaster(192.168.163.60)]
changed: [k8smaster]
changed: [k8snode02 -> k8smaster(192.168.163.60)]

TASK [Nodes in the cluster] ****************************************************
ok: [k8smaster] => {
    "nodes_command_output.stdout_lines": [
        "NAME        STATUS   ROLES           AGE   VERSION",
        "k8smaster   Ready    control-plane   46s   v1.28.2",
        "k8snode01   Ready    <none>          22s   v1.28.2",
        "k8snode02   Ready    <none>          18s   v1.28.2"
    ]
}
ok: [k8snode01] => {
    "nodes_command_output.stdout_lines": [
        "NAME        STATUS   ROLES           AGE   VERSION",
        "k8smaster   Ready    control-plane   46s   v1.28.2",
        "k8snode01   Ready    <none>          22s   v1.28.2",
        "k8snode02   Ready    <none>          18s   v1.28.2"
    ]
}
ok: [k8snode02] => {
    "nodes_command_output.stdout_lines": [
        "NAME        STATUS   ROLES           AGE   VERSION",
        "k8smaster   Ready    control-plane   46s   v1.28.2",
        "k8snode01   Ready    <none>          22s   v1.28.2",
        "k8snode02   Ready    <none>          18s   v1.28.2"
    ]
}

TASK [Provide cluster connection information] **********************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Cluster information for your .kube/config file] **************************
ok: [k8smaster] => {
    "msg": [
        "apiVersion: v1",
        "clusters:",
        "- cluster:",
        "    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EWXlOakUxTkRjeU1Gb1hEVE16TURZeU16RTFORGN5TUZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT25YCjdiTlRKNi93TGsyM2NSUllFeVI3M2tzRzFKYmlBaVBaYlBETTNXZnJqOFRsYlNhK1QxazNoeTlzNFJBaWdzSzUKaDlnNkE2QSsxWkFxOEw4WWVzZlhYL0ZUb0I2UlN3VWJmd2FVSkpUOWNHQTRvbXZmV2JVVzlrMHp0Qkp2aHREbgo5V2t2dWp4aDhBVEg1Q0JqTVNYWjErYThlS2JkQ3hDNVI5ZWdEaGJGSDIwYmlieG1BS0JvTUhKK2tvUUVTZ212CkRack9GczRDeDlPbWYyZXVFNkRqeGNKVSs2aytxU3hjWHN4ZDJJM0JKSnVxeXFhdDFoMkl1b0ZGMFh4aXVaVWsKWHU4amZhVHZCQ2JJRFZ4SGhaaUswMEs4Q0Naakg2cGxzSnVLT2dXQ0FTcFhGTVJNL3UvRDBubUM0emN3WnhzVQp1d0NYdXQ0QW54eTJqb0hIcDJzQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZJR2w4THREalRUdkJsdGs5a05UV0dWY3dpenZNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBQmpRUy9qSWtadjI0UUp2UkllZgphQ0ZCOVlKMWltTUJSdnprY0hEQjVKSTJpYTJESWxEVS9xMklRb2dUVWIvWmVPK2p1SFJoK2VIbUx3eVZuMTBCClNXb1QzUzlHK3VyK1hDbE8xU2dUMmg2UnlLTWZ2UFpmMFBHNGJIanFWSDJFbk56MGNoTUFBK1RzSGM2WVEyTFEKVnp2OURHb0pFdEkzL0w2M1AwSVVFWEhvalVxcGNHUkZhRFliWnc1NElGUitqdGs5L1lYakhDWUhna0JkMlhjTApwcElZcG40TUpubW9BeUxONGprdVQ4Qi9pTXhjUGxCaWpyZTd0Q3YvbXlnaUp6d0hWcUN1S2FRcG1xUUFuM0MwClNDeTU5ZEJvMmp4Q3ZrNE1xSWNZS1F5eVFsVXhTeEpMc3E4VUlhWi9ZY0ZMT1pJSWJzYzUrbnJuZXNPVkl0OXEKZVhnPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
        "    server: https://192.168.163.60:6443",
        "  name: kubernetes",
        "contexts:",
        "- context:",
        "    cluster: kubernetes",
        "    user: kubernetes-admin",
        "  name: kubernetes-admin@kubernetes",
        "current-context: kubernetes-admin@kubernetes",
        "kind: Config",
        "preferences: {}",
        "users:",
        "- name: kubernetes-admin",
        "  user:",
        "    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJS2xBRDd6VGJmaFl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBMk1qWXhOVFEzTWpCYUZ3MHlOREEyTWpVeE5UUTNNakphTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTRHRmRreEJ0U0RuWS95TFUKUVQ3QnVhMm5tT2kzZ2IvLzdLL3d3UXlqeDBSMFpWWGI3QWw5TU5GVFlUdVJQbm1jVm1CK1FPK215RExsVGlvcwpZQ0dmeHEzS1ZMOU40bXJjUTJwU3dNVTYydVh6bG9MczVZM2VLWlVqL0haZEs0N1ZzSzZBa0duZFFEMGxlRjhHCmY4T3Raek8xOXgwcDZ5WVZIYnJseUxhd1Eybm9FbXdrbWdpUlJpSVFPSDJXQ1JyL1pkeWMyaXE1UmMxMFZTODMKUFdmaEtwZGo2U2VCM3dCdGUyM2dLdzdUSXJIWk0vcWFOOFVJWnB3VE5ibkFlQ2d6VUhmK3kyby9maDNjZ0ZHOQpHUUpRRjdzd1c0MEQ4UGF4eXlZMWFlTWN0OHpBWVhkK0NZamZuNHlLWTdLcnRoTFhnWmVsTUtrcXpYaVljSHVGCjVVQ3N5d0lEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JTQnBmQzdRNDAwN3daYlpQWkRVMWhsWE1Jcwo3ekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBbFlqOXlKREIrSjRsYXhkRnZUQ01KUENlQ0lwcWFUS1FHN01LClk3OVZLbWkyazAwQWFsZGRSeHptckF3V3NLa1B5blAyMEdnS0ZST2w1dUJvZk9VUXoxU21oeEN2bmZmbStCN2wKTDQ5aTBDTTNlMStBYTgxcGh4TkROaXk0N1JmcXJTc0svSVduUVFCbzNVd0M2UXpoMm9xTzZMOHlWZUQ0MXJXSwpIeWJ6dHpRS0hzeE0yUVk1VklUazVPQVBvTzJ3ZnJ2SEFCVGxmUDRLU0E2SWVIdmlzVkdreTlTUlVsbU9paXp5CmV5YVV6VG9kZm51M3JIQ3dHWEoxN25rQjI3MVN3V0kxZGpKamJacWdGb1VaNWRWQ0RnNHZ5dVhnUiswSVNRR3IKa0orZWxndEQ3V1RDeUJVL0pHUmExRVB1RnF2T3lEbkw1T0NQSkF6THRyN0I0SnhVWFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
        "    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBNEdGZGt4QnRTRG5ZL3lMVVFUN0J1YTJubU9pM2diLy83Sy93d1F5angwUjBaVlhiCjdBbDlNTkZUWVR1UlBubWNWbUIrUU8rbXlETGxUaW9zWUNHZnhxM0tWTDlONG1yY1EycFN3TVU2MnVYemxvTHMKNVkzZUtaVWovSFpkSzQ3VnNLNkFrR25kUUQwbGVGOEdmOE90WnpPMTl4MHA2eVlWSGJybHlMYXdRMm5vRW13awptZ2lSUmlJUU9IMldDUnIvWmR5YzJpcTVSYzEwVlM4M1BXZmhLcGRqNlNlQjN3QnRlMjNnS3c3VElySFpNL3FhCk44VUlacHdUTmJuQWVDZ3pVSGYreTJvL2ZoM2NnRkc5R1FKUUY3c3dXNDBEOFBheHl5WTFhZU1jdDh6QVlYZCsKQ1lqZm40eUtZN0tydGhMWGdaZWxNS2txelhpWWNIdUY1VUNzeXdJREFRQUJBb0lCQUFUUzh4RVRYRlllTUVVagorWTVCakNheXpoU2loRGQ4NmtLcmNiQ2sxZXlWMHk3T2pzRGZYMXFxVlhHVXQwV3hsYVBoeFRVZU1lYkIrVjRaCjJBUmxGS3RQMXpiRk9pWnhCN1ZIVnVvZ0UyamJZc1pNb0UwN0pKaWVSVHpMU3F1Q0VhUVB6R0hPZE54SnRFR0gKUVh1RHVIbXNpZS83SjRpUHRBcUVseVllajJHVG5nUVhobU5pVTBTaGY0ekpkTytqZytTNTFRK0J3WnBIRVJaVApRM3BPVlRBUEFpS1dDQmtGMHY2VHc5d3Ywb3hVQk8weGorTGlIVE00WlFGSWE2d0U4OEhsSjhOY1hhaHlFTXprCnVVeWdQSGNJK1NvN2ZYclppNzV4ZTJnbWJ4VXlKaVZ3SjduTVJsNjFqc000ckpobmM1Y3VjVmFyTjVKaGp0MWsKMUJLb0pxa0NnWUVBNjcvMnBibVhIeWpOWTdJTmU2T0c2ZGkrZkJtRHlVUlFrRWJWMWFVNzZKYWhYd1IySkRuNgpoVXlEVHVLQ0lyWVI2QkwrZStVY2t1bTVCZlZwL3cvKzVGSjZUdDVqS0huNlhoRVI4bFh3a0ZjM1h1bjVIai9mCnAzUlB2a0ZqSXpIWjNSK1lUbkxWK0w0MDh0cFJ0ZWZKTHpCS0dqQkdpRlNCN2twbWFBY3NwUjBDZ1lFQTg2ZGsKSmQyV2t0T2JmL1doWkNVdHNrNGZFejcxbHNwUWZnNm1GditXV2VScDVzNS9HR2xDODQ2SFNTbGJVVitmS3pzUApMbW1OQWp4MS8xSGJxaEliNTNVRFliU3VQWkdMQXhNNElFWW16dmJ4S0ozNDkvc0laYnNXejRhazBMWGZZb1BGCkxMQ3VKYjloSXNBclpTckNUTkFkcWd6U0plZ2lPYkVoWXdDOWZRY0NnWUVBM3h6bUNTSUQ2L0Zwc0ppcU9nRWgKaGQ4ako3L2VBWFV0NmQyZ01ub1dvS0V1U0FhbzZOQVdVR0dCUS84S3VsOGx3MFYyb3pyS09DQUtnNkVubDhWRApya0tBam5QWjFFemNybm5wU2pnYlcvK3UzNXovcjZrenVmOVNHUFU1SmUzZ0NtNEVidm92bHlJc2FrcEVXcXZxCnMwWTRXMkNrNEJGYWhuTFRTRkRCNStFQ2dZRUFtb2ZXcDRGVFIwbjMvSDd2M2hFS1cyVGFwcDB1cTNVaStlQVcKak0yTE1QWUNDSVY4N0NHT2VlUXlmejlBa0dxQ0M2d0lZOXBEdVdCWlFoWkxxQ0NXSEFVRm9Ra3ozUTZheU5kKwpxRkYxdVp1NnRaVURXMXVXSnRjeWoyb0l5K29kaEdDb1JFREdJbUN2blplZHJpc2hVaEJJVUJxVGljRWhPOC9RCnFmYkZOeThDZ1lFQXFnN1RIcWFCREliUmZxWWZQcjZwYjltczFxQk5SM1FGL0F2QmRzZnNaU3VqWVQ1ZkZjRFoKc3pHQ2xrUTdLMUZyU0lPcEJBeUdEKzlnZE5vbDhJYU9paU1QQXdpdElMTVllYnJ0QmtUL3ZTVUJyMU5xaldQSQo0djVlbHdHN1F5ZDBrREQ1ZmhzVyt1dGlpNUg2ZEFBcTBRM1UzaWp1SVcrMDV3UEV0QXB0Q1drPQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
    ]
}
skipping: [k8snode01]
skipping: [k8snode02]

PLAY RECAP *********************************************************************
k8smaster   : ok=42   changed=32   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
k8snode01   : ok=29   changed=23   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0
k8snode02   : ok=29   changed=23   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0
```

</details>

### (Optional but recommended) Create snapshot 'k8s-installed'

Halt each VM by running `sudo shutdown -h now`.

Create a snapshot of each VM, naming it **k8s-installed**.

Power up each VM set after taking the snapshot.

## Run the components playbook

Now that Kubernetes is installed, you can install the optional components.  Run the **install_others.yaml** playbook to install Kubernetes.

`ansible-playbook install_others.yaml -i inventory.ini`

!!! note "Idempotency"
    The playbook was designed to to be idempotent so you can run it multiple times if needed.  An alternative is to reset to the **k8s-installed** snapshot and run it again.

!!! note "Monitor progress"
    After K9s is installed on the master, you can launch it in an SSH session and monitor the progress of the pods being instantiated while the playbook is running.

<details>
  <summary>Sample output with everything enabled other than Istio and the Istio-addons</summary>

```text
PLAY [Install Other Components in the Cluster] *********************************

TASK [Gathering Facts] *********************************************************
ok: [k8smaster]

TASK [Get helm installation file] **********************************************
changed: [k8smaster]

TASK [Extract helm] ************************************************************
changed: [k8smaster]

TASK [Remove helm tarball and extracted folder] ********************************
changed: [k8smaster] => (item=/home/ubuntu/linux-amd64)
changed: [k8smaster] => (item=/home/ubuntu/helm-v3.12.1-linux-amd64.tar.gz)

TASK [Get K9s installation file] ***********************************************
changed: [k8smaster]

TASK [Extract k9s] *************************************************************
changed: [k8smaster]

TASK [Remove k9s tarball] ******************************************************
changed: [k8smaster]

TASK [Get latest MetalLB version] **********************************************
changed: [k8smaster]

TASK [Get MetalLB installer] ***************************************************
changed: [k8smaster]

TASK [Apply MetalLB file] ******************************************************
changed: [k8smaster]

TASK [Pause for 10 seconds] ****************************************************
Pausing for 10 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [k8smaster]

TASK [Wait for MetalLB controller and speaker pods to be ready] ****************
changed: [k8smaster] => (item=app=metallb)
changed: [k8smaster] => (item=component=speaker)

TASK [Creating MetalLB configuration file] *************************************
changed: [k8smaster]

TASK [Configure MetalLB] *******************************************************
changed: [k8smaster]

TASK [Remove MetalLB installation yaml files] **********************************
changed: [k8smaster] => (item=/home/ubuntu/ipaddress_pool_metal.yaml)
changed: [k8smaster] => (item=/home/ubuntu/metallb-native.yaml)

TASK [Install CertManager prerequisite] ****************************************
changed: [k8smaster]

TASK [Check if rook directory exists] ******************************************
ok: [k8smaster]

TASK [Remove directory] ********************************************************
skipping: [k8smaster]

TASK [Clone Rook repository] ***************************************************
changed: [k8smaster]

TASK [Install Rook controller] *************************************************
changed: [k8smaster]

TASK [Wait for Rook controller pod to be ready] ********************************
changed: [k8smaster]

TASK [Install Rook components] *************************************************
changed: [k8smaster]

TASK [Pause for 3 1/2 minutes - wait for Rook components to get started] *******
Pausing for 210 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [k8smaster]

TASK [Confirm Rook cluster pods are ready] *************************************
changed: [k8smaster] => (item=app=csi-cephfsplugin)
changed: [k8smaster] => (item=app=csi-cephfsplugin-provisioner)
changed: [k8smaster] => (item=app=csi-rbdplugin)
changed: [k8smaster] => (item=app=rook-ceph-mgr)
changed: [k8smaster] => (item=app=rook-ceph-mon)
changed: [k8smaster] => (item=app=rook-ceph-crashcollector)
changed: [k8smaster] => (item=app=csi-rbdplugin-provisioner)
changed: [k8smaster] => (item=app=rook-ceph-osd)

TASK [Creating Block Storage class] ********************************************
changed: [k8smaster]

TASK [Create block ceph storage class] *****************************************
changed: [k8smaster]

TASK [Creating script to patch storage class (globbing and substitution hack)] ***
changed: [k8smaster]

TASK [Set storage class as default] ********************************************
changed: [k8smaster]

TASK [Remove Rook installation files] ******************************************
changed: [k8smaster] => (item=/home/ubuntu/rook)
changed: [k8smaster] => (item=/home/ubuntu/sc-ceph-block.yaml)
changed: [k8smaster] => (item=/home/ubuntu/patchsc.yaml)

TASK [Install Ingress Nginx] ***************************************************
changed: [k8smaster]

TASK [Pause for 5 seconds] *****************************************************
Pausing for 5 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [k8smaster]

TASK [Confirm ingress controller pod is ready] *********************************
changed: [k8smaster]

TASK [Get Ingress service components for confirmation] *************************
changed: [k8smaster]

TASK [Ingress controller information] ******************************************
ok: [k8smaster] => {
    "msg": [
        "NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)                      AGE",
        "ingress-nginx-controller             LoadBalancer   10.101.36.117    192.168.163.151   80:30865/TCP,443:31410/TCP   31s",
        "ingress-nginx-controller-admission   ClusterIP      10.103.154.247   <none>            443/TCP                      31s"
    ]
}

TASK [Get 'istioctl' installation file] ****************************************
skipping: [k8smaster]

TASK [Extract istioctl] ********************************************************
skipping: [k8smaster]

TASK [Install istio] ***********************************************************
skipping: [k8smaster]

TASK [Pause for 5 seconds] *****************************************************
skipping: [k8smaster]

TASK [Confirm Istio pods are ready] ********************************************
skipping: [k8smaster] => (item=app=istiod) 
skipping: [k8smaster] => (item=app=istio-ingressgateway) 
skipping: [k8smaster] => (item=app=istio-egressgateway) 
skipping: [k8smaster]

TASK [Install Istio add-ons] ***************************************************
skipping: [k8smaster]

TASK [Confirm Istio additional pods are ready] *********************************
skipping: [k8smaster] => (item=app=grafana) 
skipping: [k8smaster] => (item=app=jaeger) 
skipping: [k8smaster] => (item=app=kiali) 
skipping: [k8smaster] => (item=app=prometheus) 
skipping: [k8smaster] => (item=app.kubernetes.io/name=loki) 
skipping: [k8smaster]

TASK [Creating patch file for services] ****************************************
skipping: [k8smaster]

TASK [Patch istio add-on services to use load balancer] ************************
skipping: [k8smaster] => (item=grafana) 
skipping: [k8smaster] => (item=kiali) 
skipping: [k8smaster] => (item=tracing) 
skipping: [k8smaster] => (item=prometheus) 
skipping: [k8smaster]

TASK [Remove istio tarball and extracted folder] *******************************
skipping: [k8smaster] => (item=/home/ubuntu/istio-1.18.0) 
skipping: [k8smaster] => (item=/home/ubuntu/istio-1.18.0-linux-amd64.tar.gz) 
skipping: [k8smaster] => (item=/home/ubuntu/patch-service.yaml) 
skipping: [k8smaster]

PLAY RECAP *********************************************************************
k8smaster                  : ok=33   changed=27   unreachable=0    failed=0    skipped=11   rescued=0    ignored=0   
```

</details>

## Snapshot 'k8sComplete'

Shutdown the VMs, and snapshot each one.  See the helper script in this repository located at `99-helper-scripts/manageCluster.sh` that can be used for automating things under VMware.

At this time,  your cluster is ready for use.  

## Manual Process

This section is for reference only, and the versions of products might be older than above as this section is not being actively maintained.  It is intended to provide context to what is being done in ansible playbooks.  In the manual instructions, the assumption is that you would set up the master to the point of being ready to run `kubeadm` and at that time take a snapshot.  The snapshot is cloned to create the two worker nodes prior to initializing the cluster.

### Preliminary setup

```bash
# Add the IP addresses to the local hosts file for convenience
sudo tee -a /etc/hosts >/dev/null <<-EOF
192.168.163.60 k8smaster
192.168.163.61 k8snode01
192.168.163.62 k8snode02
EOF

# Update packages
sudo apt-get update
sudo apt-get upgrade -y

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

### Install container platform (containerd)

At this point, you will install the **containerd** runtime.  In the latest Ubuntu 22.04 installations, the containerd version available from the APT repository is **1.6.12-0ubuntu1~22.04.1**, so all that is necessary is to install it using apt: `sudo apt-get install -y containerd`

#### Generate a default configuration for containerd:

`containerd config default | sudo tee /etc/containerd/config.toml`

#### Fix / confirm settings

In order for the **etcd** pod to remain stable, the `SystemdCgroup` flag for the runc options must be set to true.  The default configuration sets this boolean to false.

Modify **/etc/containerd/config.toml**.   The `runtime_type` is probably correct, but `SystemdCgroup` defaults to **false**.  The two values to confirm or modify were found at lines 112 and 125 at the time of this writing.

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
    Adjust the IP address accordingly for the `apiserver-advertise-address` and `control-plane-endpoint`.

```sh
# On the master node only
# Pod CIDR is default for flannel
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs \
        --apiserver-advertise-address=192.168.163.60 \
        --control-plane-endpoint=192.168.163.60  \
        --cri-socket unix:///run/containerd/containerd.sock

# When finished, copy the join command from the output for use on the other nodes
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
[init] Using Kubernetes version: v1.28.2
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s126master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.163.60]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s126master localhost] and IPs [192.168.163.60 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s126master localhost] and IPs [192.168.163.60 127.0.0.1 ::1]
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

  kubeadm join 192.168.163.60:6443 --token 7wc3xe.yt76msej78s4mtb9 \
 --discovery-token-ca-cert-hash sha256:d22f7753d0c5b28fe386e13fa57cc47a0e261e23cc98aa13b9316645dddefe56 \
 --control-plane --certificate-key f5050f09f6fc60d3f8701b21bee71855f4c55e76b82aacd264afcf90191dc304

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.163.60:6443 --token 7wc3xe.yt76msej78s4mtb9 \
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
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.11.4/cert-manager.yaml
```

### Install

```sh
# Get the code
git clone --single-branch --branch release-1.11 https://github.com/rook/rook.git

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

# Exit the container shell
exit

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

    # RBD image format. Defaults to "2".
    imageFormat: "2"

    # RBD image features
    # Available for imageFormat: "2". Older releases of CSI RBD
    # support only the `layering` feature. The Linux kernel (KRBD) supports the
    # full complement of features as of 5.4
    # `layering` alone corresponds to Ceph's bitfield value of "2" ;
    imageFeatures: layering

    # The secrets contain Ceph admin credentials.
    csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
    csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
    csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
    csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
    csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
    csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph

    # Specify the filesystem type of the volume. If not specified, csi-provisioner
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

```

Set the storage class you created as the default (`storageclass.kubernetes.io/is-default-class=true`)

```sh
# Before
kubectl describe sc rook-ceph-block
Name:                  rook-ceph-block
IsDefaultClass:        No
Annotations:           <none>
...

# Alter annotation
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# After
kubectl describe sc rook-ceph-block
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

Installation will use the demo profile; completing this section will configure the cluster by adding the ingress and egress gateways.  In addition, the demo profile uses a smaller Envoy sidecar.

#### Prerequisites

In order to install Istio, you will need the `istioctl` utility.  On the Mac, you can use **brew** to install this application, or you can download the archive for your platform from the [release page](https://github.com/istio/istio/releases/tag/1.18.0).  You will need this archive to get the profile and add-on software in either case. Download the latest version (1.18.0 at the time of this writing). On the system used to develop this guide, the **_istioctl_** binary was installed using brew but the one contained in the archive can be used as an alternative. The instructions on installation are [here](https://istio.io/latest/docs/setup/getting-started/).

#### Installation

Extract the archive to a known location on your filesystem.

```sh
# Downloads directory is assumed.
cd ~/Downloads

# Extract the archive
tar xvzf istio-1.18.0-osx.tar.gz

# Navigate to the profile directory and install the demo profile
cd istio-1.18.0/manifests/profiles/
istioctl install -f demo.yaml --skip-confirmation

This will install the Istio 1.18.0 default profile with ["Istio core" "Istiod" "Ingress gateways" "Egress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Egress gateways installed
✔ Installation complete
Making this installation the default for injection and validation.

Thank you for installing Istio 1.18.0.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/hMHGiwZHPU7UQRWe9
```

#### Add ons (optional)

The add-ons are the Kiali UI (for Istio), Jaeger, Grafana and Prometheus. The Kubernetes yaml files are included with each release of Istio and are specific to that release:

```sh
# Navigate to the root of the extracted archive
cd ~/istio-1.18.0/

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

</details>

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
