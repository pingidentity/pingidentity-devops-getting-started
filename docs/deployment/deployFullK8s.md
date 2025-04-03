---
title: Deploy a robust local Kubernetes Cluster
---
# Deploy a robust local Kubernetes Cluster

!!! note "Video Demonstration"
    A video demonstrating the manual process outlined on this page is available [here](https://videos.pingidentity.com/detail/videos/devops/video/6324019967112/robust-test-kubernetes-cluster).  An updated video using the ansible playbooks is planned.

In some cases, a single-node cluster is insufficient for more complex testing scenarios.  If you do not have access to a managed Kubernetes cluster and want something more similar to what you would find in a production environment, this guide can help.

This document describes deploying a multi-node cluster using [ansible](https://docs.ansible.com/) and the [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm//) utility, running under virtual machines. When completed, the cluster will consist of:

- 3 nodes, a master with two worker nodes (to conserve resources, the master will also be configured to run workloads)
- (At the time of this writing) Kubernetes 1.32.3 using the **containerd** runtime (no Docker installed)
- (Optional but recommended) Load balancer
- Block storage support for PVC/PV needed by some Ping products
- (Optional) Ingress controller (ingress-nginx)
- (Optional) Istio service mesh
- (Optional) supplementary tools for tracing and monitoring with Istio

!!! warning "Demo Use Only"
    While the result is a full Kubernetes installation, the instructions in this document only create an environment sufficient for testing and learning.  The cluster is not intended for use in production environments.

!!! note "ARM Architecture"
    The ansible playbooks for this guide assume the ARM chip set as found on the Apple M-series chip.  If you are running on an Intel-based processor, you will have to adjust some file packages and names accordingly.

## Prerequisites

In order to complete this guide, you will need:

- 64 GB of RAM (32 GB might be enough if you have an SSD to handle some memory swapping and reduce the RAM on the VMs to 12 GB)
- At least 150 GB of free disk
- Modern processor with multiple cores
- Ansible-playbook CLI tool. You can use brew by running `brew install ansible` or see [the ansible site](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) for instructions on how to install and configure this application.
- Virtualization solution.  For this guide, VMware Fusion is used, but other means of creating and running a VM (Virtualbox, KVM) can be adapted.
- Access to [Ubuntu Server 24.04.2 LTS](https://ubuntu.com/download/server) installation media
- **A working knowledge of Kubernetes**, such as knowing how to port-forward, install objects using YAML files, and so on. Details on performing some actions will be omitted, and it is assumed the reader will know what to do.
- Patience

## Virtual machines

First, create 3 VMs as described here, using a default installation of Ubuntu 24.04.  For this guide, the user created was `ubuntu`. You can use any name with a password of your choice.

- 4 vCPU
- 16 GB RAM
- 2 disks: 80 GB disk for the primary / 60 GB as secondary
- Attached to a network that allows internet access (bridged or NAT), using a fixed IP address

!!! info "IP Space"
    192.168.163.0/24 was the IP space used in this guide; adjust to your environment accordingly.

  | VM          | Hostname  | IP address     |
  | ----------- | --------- | -------------- |
  | Master node | k8smaster | 192.168.163.70 |
  | Worker      | k8snode01 | 192.168.163.71 |
  | Worker      | k8snode02 | 192.168.163.72 |

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
192.168.163.70 k8smaster
192.168.163.71 k8snode01
192.168.163.72 k8snode02
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
The authenticity of host 'k8smaster (192.168.163.70)' can't be established.
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
   k8smaster ansible_host=192.168.163.70
   
   [kubernetes_nodes]
   k8snode01 ansible_host=192.168.163.71
   k8snode02 ansible_host=192.168.163.72
   
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
    k8smaster_ip: "192.168.163.70"
    k8snode01_ip: "192.168.163.71"
    k8snode02_ip: "192.168.163.72"
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
PLAY [Install Kubernetes on all VMs] ******************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************
ok: [k8smaster]
ok: [k8snode01]
ok: [k8snode02]

TASK [Gather architecture info] ***********************************************************************************************************************************************************
ok: [k8smaster]
ok: [k8snode01]
ok: [k8snode02]

TASK [Update package cache] ***************************************************************************************************************************************************************
ok: [k8smaster]
ok: [k8snode02]
ok: [k8snode01]

TASK [Upgrade all packages] ***************************************************************************************************************************************************************
changed: [k8snode02]
changed: [k8snode01]
changed: [k8smaster]

TASK [Add host file entries] **************************************************************************************************************************************************************
changed: [k8snode02]
changed: [k8snode01]
changed: [k8smaster]

TASK [Add the br_netfilter kernel module and configure for load at boot] ******************************************************************************************************************
changed: [k8snode02]
changed: [k8snode01]
changed: [k8smaster]

TASK [Add the overlay kernel module and configure for load at boot] ***********************************************************************************************************************
changed: [k8snode01]
changed: [k8snode02]
changed: [k8smaster]

TASK [Creating kernel modules file to load at boot] ***************************************************************************************************************************************
changed: [k8snode02]
changed: [k8smaster]
changed: [k8snode01]

TASK [Disable swap in fstab by commenting it out] *****************************************************************************************************************************************
changed: [k8snode01]
changed: [k8snode02]
changed: [k8smaster]

TASK [Disable swap] ***********************************************************************************************************************************************************************
changed: [k8snode02]
changed: [k8snode01]
changed: [k8smaster]

TASK [Enable IP forwarding for iptables] **************************************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Update sysctl parameters without reboot - bridge (ipv4)] ****************************************************************************************************************************
changed: [k8snode02]
changed: [k8snode01]
changed: [k8smaster]

TASK [Update sysctl parameters without reboot - bridge (ipv6)] ****************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Update sysctl parameters without reboot - IPforward] ********************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Install containerd] *****************************************************************************************************************************************************************
changed: [k8snode02] => (item=containerd)
changed: [k8snode01] => (item=containerd)
changed: [k8smaster] => (item=containerd)

TASK [Add Kubernetes APT key] *************************************************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Create directory for containerd configuration file] *********************************************************************************************************************************
changed: [k8snode02]
changed: [k8snode01]
changed: [k8smaster]

TASK [Check if containerd toml configuration file exists] *********************************************************************************************************************************
ok: [k8smaster]
ok: [k8snode01]
ok: [k8snode02]

TASK [Create containerd configuration file if it does not exist] **************************************************************************************************************************
changed: [k8snode01]
changed: [k8smaster]
changed: [k8snode02]

TASK [Read config.toml file] **************************************************************************************************************************************************************
ok: [k8snode01]
ok: [k8snode02]
ok: [k8smaster]

TASK [Check if correct containerd.runtimes.runc line exists] ******************************************************************************************************************************
ok: [k8smaster]
ok: [k8snode01]
ok: [k8snode02]

TASK [Error out if the incorrect or missing containerd.runtimes.runc line does not exist] *************************************************************************************************
skipping: [k8smaster]
skipping: [k8snode01]
skipping: [k8snode02]

TASK [Set SystemdCgroup line in file to true if it is currently false] ********************************************************************************************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Restart containerd service] *********************************************************************************************************************************************************
changed: [k8snode02]
changed: [k8smaster]
changed: [k8snode01]

TASK [Install prerequisites for Kubernetes] ***********************************************************************************************************************************************
changed: [k8snode01] => (item=apt-transport-https)
changed: [k8smaster] => (item=apt-transport-https)
changed: [k8snode02] => (item=apt-transport-https)
ok: [k8smaster] => (item=ca-certificates)
ok: [k8snode01] => (item=ca-certificates)
ok: [k8snode02] => (item=ca-certificates)
ok: [k8snode02] => (item=curl)
ok: [k8smaster] => (item=curl)
ok: [k8snode01] => (item=curl)
changed: [k8smaster] => (item=gnupg2)
changed: [k8snode02] => (item=gnupg2)
changed: [k8snode01] => (item=gnupg2)
ok: [k8snode02] => (item=software-properties-common)
ok: [k8smaster] => (item=software-properties-common)
ok: [k8snode01] => (item=software-properties-common)
changed: [k8snode01] => (item=bzip2)
changed: [k8snode02] => (item=bzip2)
changed: [k8smaster] => (item=bzip2)
ok: [k8snode02] => (item=tar)
ok: [k8snode01] => (item=tar)
ok: [k8smaster] => (item=tar)
ok: [k8snode02] => (item=vim)
ok: [k8smaster] => (item=vim)
ok: [k8snode01] => (item=vim)
ok: [k8snode02] => (item=git)
ok: [k8snode01] => (item=git)
ok: [k8smaster] => (item=git)
ok: [k8snode02] => (item=wget)
ok: [k8smaster] => (item=wget)
ok: [k8snode01] => (item=wget)
ok: [k8smaster] => (item=net-tools)
ok: [k8snode02] => (item=net-tools)
ok: [k8snode01] => (item=net-tools)
ok: [k8snode02] => (item=lvm2)
ok: [k8smaster] => (item=lvm2)
ok: [k8snode01] => (item=lvm2)

TASK [Get Kubernetes package signing key] *************************************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Add Kubernetes APT repository] ******************************************************************************************************************************************************
changed: [k8snode01]
changed: [k8smaster]
changed: [k8snode02]

TASK [Update package cache] ***************************************************************************************************************************************************************
ok: [k8smaster]
ok: [k8snode02]
ok: [k8snode01]

TASK [Install Kubernetes components] ******************************************************************************************************************************************************
changed: [k8smaster] => (item=kubelet)
changed: [k8snode02] => (item=kubelet)
changed: [k8snode01] => (item=kubelet)
changed: [k8smaster] => (item=kubeadm)
changed: [k8snode01] => (item=kubeadm)
changed: [k8snode02] => (item=kubeadm)
changed: [k8smaster] => (item=kubectl)
changed: [k8snode01] => (item=kubectl)
changed: [k8snode02] => (item=kubectl)

TASK [Hold Kubernetes packages at current version] ****************************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode01]
changed: [k8snode02]

TASK [Run kubeadm reset to ensure fresh start each time.] *********************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode02]
changed: [k8snode01]

TASK [Remove any files from a previous installation attempt] ******************************************************************************************************************************
skipping: [k8snode01] => (item=/home/ubuntu/.kube)
skipping: [k8snode01]
skipping: [k8snode02] => (item=/home/ubuntu/.kube)
skipping: [k8snode02]
ok: [k8smaster] => (item=/home/ubuntu/.kube)

TASK [Initialize Kubernetes master] *******************************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Check if k8s installation file exists] **********************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
ok: [k8smaster]

TASK [Fail if K8s installed file does not exist] ******************************************************************************************************************************************
skipping: [k8smaster]
skipping: [k8snode01]
skipping: [k8snode02]

TASK [Create .kube directory] *************************************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Copy kubeconfig to user's home directory] *******************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Install Pod network] ****************************************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Remove taint from master node] ******************************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Retrieve join command from master and run it on the nodes] **************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Join worker nodes to the cluster] ***************************************************************************************************************************************************
skipping: [k8snode01] => (item=k8snode01)
skipping: [k8snode01] => (item=k8snode02)
skipping: [k8snode01]
skipping: [k8snode02] => (item=k8snode01)
skipping: [k8snode02] => (item=k8snode02)
skipping: [k8snode02]
changed: [k8smaster -> k8snode01(192.168.163.71)] => (item=k8snode01)
changed: [k8smaster -> k8snode02(192.168.163.72)] => (item=k8snode02)

TASK [Pause for 5 seconds] ****************************************************************************************************************************************************************
Pausing for 5 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [k8smaster]

TASK [Confirm flannel pods are ready] *****************************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Run confirmation command by listing nodes] ******************************************************************************************************************************************
changed: [k8smaster]
changed: [k8snode02 -> k8smaster(192.168.163.70)]
changed: [k8snode01 -> k8smaster(192.168.163.70)]

TASK [Nodes in the cluster] ***************************************************************************************************************************************************************
ok: [k8smaster] => {
    "nodes_command_output.stdout_lines": [
        "NAME        STATUS   ROLES           AGE   VERSION",
        "k8smaster   Ready    control-plane   36s   v1.32.3",
        "k8snode01   Ready    <none>          25s   v1.32.3",
        "k8snode02   Ready    <none>          24s   v1.32.3"
    ]
}
ok: [k8snode01] => {
    "nodes_command_output.stdout_lines": [
        "NAME        STATUS   ROLES           AGE   VERSION",
        "k8smaster   Ready    control-plane   36s   v1.32.3",
        "k8snode01   Ready    <none>          25s   v1.32.3",
        "k8snode02   Ready    <none>          24s   v1.32.3"
    ]
}
ok: [k8snode02] => {
    "nodes_command_output.stdout_lines": [
        "NAME        STATUS   ROLES           AGE   VERSION",
        "k8smaster   Ready    control-plane   36s   v1.32.3",
        "k8snode01   Ready    <none>          25s   v1.32.3",
        "k8snode02   Ready    <none>          24s   v1.32.3"
    ]
}

TASK [Provide cluster connection information] *********************************************************************************************************************************************
skipping: [k8snode01]
skipping: [k8snode02]
changed: [k8smaster]

TASK [Cluster information for your .kube/config file] *************************************************************************************************************************************
ok: [k8smaster] => {
    "msg": [
        "apiVersion: v1",
        "clusters:",
        "- cluster:",
        "    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSnVJVlgvY2Y2UkF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBME1ETXhOREU0TkRoYUZ3MHpOVEEwTURFeE5ESXpORGhhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURLeEpzQW9GNld3eWtkWWJnekZKNDZyc2Q2aVJEenduamRrUlJKaXgzY0k0NU1PUE5PV1NDODB6SUMKZWRyWEtZR2wrWFM3Zk5WK3kyUmJTN1A3STdUcDhRQTRqVXA1VXlCZXVtamN4NnFSc3R4MEFYVTQ3T0tJNHM5UApId2lrczFJQ1ZZV1ZNM3ZkN0c0dWdtNTJjYjRrOFBLbnR6MmREWUVlUXVvUFpPYVJwNEVNRmdzM0RMS2JRZ01mCitnSWFwdm9PUGxwVnlJanRQVFJuRnA2ME41eVgzcGp0ejBsRFZYcDJQU3F3aEtCK3hsYVVaeUQ4RytibmJiRncKUTRLWFIxWjlpazJaQ3JuS2k3VFVXUnZKUGdrZ0poVmdidzhBZlArbUgxUGt6dGxaSDZBbGkyaFZnOFpRQnZkbAppd3l6QUVQbmk2VlBDVTN0Z0drVTJYa0pLbzdCQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSb29KcDJIbTk0S09KUXRhb2tjTG45WEpVRzdqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ3ZIa0ZmZVhKRwpQdlpOMFBjUTJ0Wm81SzVVQ1ZCQytBaVQwUnp5SmU4WTAyT1FPVUlRc1owZ25Ca3I2OXJncEhuSWJLTlVPaktHCmM1a2QydEJJaW5lclBnS2hzS2tKblZYY2hINDMrdDRwS05KUis2Z1ByL1ZQeWRrSW1GUzZrSTRsc291bUZHc1kKL1NBeGZCdGdKL0Z6MXM5aFByZzZFR0xTeXFtSmZaK2RwT2oxZ0tCSUpta2tHaEV4REova2xxZk02OFpXbnU0Vwo2UEZ0SVNiTGM1dzk0Q3NTdnNUVkdLVnNlcVMrSmtPS1g4UE5MTjN5ZVp3RzhoMHRTMkFDbUlmN1grSmE5Y0xNClhib2VjRzFiVmgxMWdNMU1NckNEdjcwTGUvOWw5T3lEOGY1MFpBcVVVck5XazZmRzF5dkpIcnIvY2E3OGNCaHQKcmFFeUk0SG56Z1p5Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
        "    server: https://192.168.163.70:6443",
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
        "    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJVnZqM2xzNFFSMWd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBME1ETXhOREU0TkRoYUZ3MHlOakEwTURNeE5ESXpORGhhTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFEY1BGa1QKdzNtWGlvaHVjWFgvOGFxdS9NYVBFYU5lMWNEOCs2K1p3R3I4T1FzSGZCOHRQQjdHTUd2VXgwUmh1cTlINkw0YQpxTWttdHc0NUVySTZWWjVQYjBvVkpScjdBVzRUQXFPd3ZnT21KN1VUTmlhSjhoQVp3ZElQZGh5akJsMDVEZG51CmdPdVR2ZncyUFlZbDNXMWRzZWxnemQ4Ym1NS0wrMlBNTWErdjhwZUVITVNkTnRsUGFWOWFjMUt0MlQ2b2o0OGsKTXN4dkhJNS85L3NLUlVyMmhmMzR1b2RCa3FHK0JHMllJNGhXUlloVmphMGZEYVJiUG95OTF2TlEwb0graDFjZQp5MjVXV1hkTkQxdk9hQWp5OWwrUXlnL2hSQWJ4Um9IcGJoUTJLejdpeE9RcTVTWUJ0MFdORlZmc3F5MUYyQzdHCk95L0dLNVkyZ0ZnWGhzc3JBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRkdpZ21uWWViM2dvNGxDMQpxaVJ3dWYxY2xRYnVNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJCVUk3UnRCd3ZsQXdpeEZVOEw4cW44LzZXCnZQb2NQT1psM2IwYXdxeHdaMlozTkcrVGp3Uk43UldxR3RFSEs3M0RoT3cySFloeTJQZDZlMFVXb3JWZ0tIeVYKcE1pREh0VW5rcE45QlUvZjJrNUhNNlpyRjR3ZVJ4QUYySEN6RDAxR1hDTzFlbWVsQnMyVjFPMzRnQmh6K0VZNwp1TkhkS0NTayt5Yk13RTEvZ1BaUzJqQm92UDhZdUhuU2w5VXJ1ODB5d2Z0czk0ejNvTjE5ZzNTV3FSeGxUejZNCktLNC9YNE4yTnRhS2VWQUFIZXRtY29zSWdka085S1NvakZkUEtXVWdnY1NRcXhNWkl3SFluSDFqMWpaQS94U04KWnhOTlZrODEwSDJydklwMjZrSUxOUTZPZDJBMld1RXVyaDRySVAwWi9saHBIa2JRZlplU2pDU0hLSnZ2Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
        "    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBM0R4WkU4TjVsNHFJYm5GMS8vR3FydnpHanhHalh0WEEvUHV2bWNCcS9Ea0xCM3dmCkxUd2V4akJyMU1kRVlicXZSK2krR3FqSkpyY09PUkt5T2xXZVQyOUtGU1VhK3dGdUV3S2pzTDREcGllMUV6WW0KaWZJUUdjSFNEM1ljb3daZE9RM1o3b0RyazczOE5qMkdKZDF0WGJIcFlNM2ZHNWpDaS90anpER3ZyL0tYaEJ6RQpuVGJaVDJsZlduTlNyZGsrcUkrUEpETE1ieHlPZi9mN0NrVks5b1g5K0xxSFFaS2h2Z1J0bUNPSVZrV0lWWTJ0Ckh3MmtXejZNdmRielVOS0Ivb2RYSHN0dVZsbDNUUTliem1nSTh2WmZrTW9QNFVRRzhVYUI2VzRVTmlzKzRzVGsKS3VVbUFiZEZqUlZYN0tzdFJkZ3V4anN2eGl1V05vQllGNGJMS3dJREFRQUJBb0lCQUE2bEhLOUp3bDRuWWljbAorRmpLc3pUcnJqQjVWY25Lb1FpeG05MjNnK1c5elZQMEZ3YWxCczdiRFhDYXg1dFFGTFBOY0ViSmpvYTZpWUdXCkVxLzZYWXFldGVodURUcy92eGdZaHRZTDdLWXg0Y0tqU1RESEhmYjRnb1Z3cnpyUUE0YjF1dFkzVUhNRW9TN2kKTEhkOEgvZXBDd0hhN3NraEFWN1ptcXRMYW9saWtzUDRpQURCNFFCTXQwQ0xpYUtlTU9iZEkzNTBELzJCWnpvaApJSG9mNS9wY0dIT2hReVYxNEx6blNoTGkxMFFHQjJPb0lwRHFsQjhxd2k3SDRHK09nOGtyZS9BU0JRYnRuaWlmCnBoS3ZxbjF5YUhSb1FPVHRHekNpanYvZVRMK3Aza09QYUpLWUM4Q1lzR3ZqRzVHTFREUXRKeEJnd2p0TDVXM1AKU3N1SlovRUNnWUVBNWFhR1VvUE9VNzJMSWxldE80L2RsOWZtSkR0TTNCWjcvTXAyQTB6M0NvVmgrdGpxVVloVwpvUzE0QlRUcE5wOEhoN21SeW1MOE5oWFZJQjlSTTFrNjdNMVlJN2lzSU9ESm50VlNUclFJL1BSUmU5cXZLbzRLCkFKVGROTnhSR0xvM2VFY0M1eTZDNWNLZ2hXdStZNFZHMGVIc016TTN2amxhRFRPTlAyYmRRNmNDZ1lFQTlZRkoKSkYyc2owK0JjNUU4bjBYd0twSkdXMDdtdkRWTXdtQVRRdHM5Nms5TTk0Sm1iWHlOU2t5ajl3RVM4K2x6STkrUQoxL3RUUjJZRlhYMmZobTdJbk5qZzVBRlNsRDgrODdYSUs5MUxXNVdQUnl4ZTlmQk4zMzBXUXEvOUc0OU5FWmoxCkZpQ21mVTBMTFZ1RnZ1anRYQUkyUnlVT3pjWEtqNXVqU2Q0ZC9OMENnWUJqR3B2NDIveWNVcjNLVWovbDVrM2cKaTBFNy9ZTkxyMEJPZFNpOGYraFVWLzlTZTIyVFJkenNyV3lRQXFkcDlQTVE5Vm9mRnR4MGtyTm9xMXNsWjZwdwpLcVdRdE05RFdQNXBWdkd3R1MyUHkvZW1GVmRtYSttUkdxempkUGhpVFdwR3M0NWpLY1UvVmVCajgzMDBBWDN3CmNTaTNaN0QwbkZkcVB3Y0RoMmFSSFFLQmdRQ2JBQnBPeEhtckxYWThvY2pWZ2xHRWZ6KytiRTFQTEpPZThRdVkKSFZXMDlvWlFpbHJpNjAxRlNLZ0l6ZnZLVld6bGpFUWxxTDdHaUVvQTRjeHpFc1RFQ2tYS2ptODF1OHlpRC9ZbQpnNXdOWVpySlErRmNnM0NYRnFHVVR3cU5lT2Nlb2lTeTZNQlV3ZXk1b1Z3SzBZTHlvVTdsa2ljTGtjSTI4dnVnCktvVmlYUUtCZ1FEWSttN2JxYjVXSDA3NE5mWTV6dUR6M3lENHdMOXBaa0x3M0VrUWtXby9TNldkbUhqQzdoeW8KYmJsc0U2NXQzZFFqZll2V0xjWUhWR1NVaDIyL0NuQnVYMXE3a3pLNnZZK2hSSjdSaDFpUVZpRW9TYWdza3QzQwpvRjZsdk1qZTl4azZUNkNEUThNQ3Aza3IxSUtLMWE4VEZJVFhLUWpyZDl5L1hXWDdmTkU5Y3c9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
    ]
}
skipping: [k8snode01]
skipping: [k8snode02]

PLAY RECAP ********************************************************************************************************************************************************************************
k8smaster                  : ok=45   changed=33   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
k8snode01                  : ok=32   changed=24   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0
k8snode02                  : ok=32   changed=24   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0
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
- [How To Install Kubernetes on Ubuntu 24.04 LTS](https://idroot.us/install-kubernetes-ubuntu-24-04/)
- [Containerd Github](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
- [etcd-io Github issue #13670](https://github.com/etcd-io/etcd/issues/13670)
