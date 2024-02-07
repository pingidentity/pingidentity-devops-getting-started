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

Now that Kubernetes is installed, modify the `install_list.yaml` file accordingly to enable or disable the components that you want to install.  After making changes, run the **install_others.yaml** playbook.

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

## Resources & References

This guide was built on the work of others. As with many how-to documents, we have contributed our skills and knowledge to pull everything together and fill in the gaps that were experienced.  However, we want to acknowledge at least some of the many sources where we found inspiration, guidance, fixes for errors, and sanity when a step was missed. Not shown here are dozens of places where we went in exploring different options for pieces we did not use or install in the end. *the Ping DevOps Integrations team*

- [How to Deploy MetalLB on Kubernetes - ComputingForGeeks](https://computingforgeeks.com/deploy-metallb-load-balancer-on-kubernetes/)
- [How To: Ubuntu / Debian Linux Regenerate OpenSSH Host Keys - nixCraft](https://www.cyberciti.biz/faq/howto-regenerate-openssh-host-keys)
- [Block Storage Overview - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Storage-Configuration/Block-Storage-RBD/block-storage/#advanced-example-erasure-coded-block-storage)
- [Toolbox - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Troubleshooting/ceph-toolbox/#interactive-toolbox)
- [Quickstart - Rook Ceph Documentation](https://www.rook.io/docs/rook/v1.10/Getting-Started/quickstart)
- [How to Install Kubernetes on Ubuntu 22.04 / Ubuntu 20.04 | ITzGeek](https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/install-kubernetes-on-ubuntu-22-04.html)
- [Kubernetes 1.26 - The electrifying release setup - KubeSimplify](https://blog.kubesimplify.com/kubernetes-126)
- [Containerd Github](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
- [etcd-io Github issue #13670](https://github.com/etcd-io/etcd/issues/13670)
