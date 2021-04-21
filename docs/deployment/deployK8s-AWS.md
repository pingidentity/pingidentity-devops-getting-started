---
title: Prepare AWS EKS for Multi-Region Deployments
---
# Prepare AWS EKS for Multi-Region Deployments

In this example, we'll deploy 2 Kubernetes clusters, each in a different Amazon Web Services (AWS) region. An AWS virtual private cloud (VPC) is assigned and dedicated to each cluster. Throughout this document, "VPC" is synonymous with "cluster".

## Prerequisites

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

* [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html), the current version.

* AWS account permissions to create clusters.

## Configure the AWS CLI

If you've not already done so, configure the AWS CLI to use your profile and credentials:

1. Assign your profile and supply your `aws_access_key_id` and `aws_secret_access_key`. Enter:

   ```shell
   aws configure --profile=<aws-profile>
   ```

   Then enter your `aws_access_key_id` and `aws_secret_access_key`.

2. Open your `~/.aws/credentials` file in a text editor and add your AWS `role_arn`. For example:

   ```shell
   “role_arn = arn:aws:iam::xxxxxxxx4146:role/xxx”
   ```

## Create the multi-region clusters

1. Create the YAML files to configure the the clusters. You'll create the clusters in different AWS regions. We'll be using the `ca-central-1` region and the `us-west-2` region in this document.

   a. Configure the first cluster. For example, using the `ca-central-1` region and the reserved CIDR 172.16.0.0:

   ```yaml
   apiVersion: eksctl.io/v1alpha5
   kind: ClusterConfig

   metadata:
     name: pingfed-ca-central-1
     region: ca-central-1
     version: "1.17"

   vpc:
     cidr: 172.16.0.0/16

   managedNodeGroups:
     - name: us-west-2a-worker-nodes
       instanceType: t3a.2xlarge
       labels: {}
       tags: {}
       minSize: 1
       maxSize: 2
       desiredCapacity: 1
       volumeSize: 12
       privateNetworking: true
       ssh:
         publicKeyPath: ~/.ssh/id_rsa.pub
       iam:
         withAddonPolicies:
           imageBuilder: true
           autoScaler: true
           externalDNS: true
           certManager: true
           appMesh: true
           ebs: true
           fsx: true
           efs: true
           albIngress: true
           xRay: true
           cloudWatch: true
     - name: us-west-2b-worker-nodes
     instanceType: t3a.2xlarge
     labels: {}
     tags: {}
     minSize: 1
     maxSize: 2
     desiredCapacity: 1
     volumeSize: 12
     privateNetworking: true
     ssh:
       publicKeyPath: ~/.ssh/id_rsa.pub
     iam:
       withAddonPolicies:
           imageBuilder: true
           autoScaler: true
           externalDNS: true
           certManager: true
           appMesh: true
           ebs: true
           fsx: true
           efs: true
           albIngress: true
           xRay: true
           cloudWatch: true
   ```

   > For production purposes, select a VPC with a private IP.

   > The `ssh` entry is optional, allowing you to SSH in to your cluster.

   b. Configure the second cluster. For example, using the `us-west-2` region and the reserved CIDR 10.0.0.0:

   ```yaml
   apiVersion: eksctl.io/v1alpha5
   kind: ClusterConfig

   metadata:
     name: pingfed-us-west-2
     region: us-west-2
     version: "1.17"

   vpc:
     cidr: 10.0.0.0/16

   managedNodeGroups:
     - name: us-west-2a-worker-nodes
       instanceType: t3a.2xlarge
       labels: {}
       tags: {}
       minSize: 1
       maxSize: 2
       desiredCapacity: 1
       volumeSize: 12
       privateNetworking: true
       ssh:
         publicKeyPath: ~/.ssh/id_rsa.pub
       iam:
         withAddonPolicies:
           imageBuilder: true
           autoScaler: true
           externalDNS: true
           certManager: true
           appMesh: true
           ebs: true
           fsx: true
           efs: true
           albIngress: true
           xRay: true
           cloudWatch: true
     - name: us-west-2b-worker-nodes
     instanceType: t3a.2xlarge
     labels: {}
     tags: {}
     minSize: 1
     maxSize: 2
     desiredCapacity: 1
     volumeSize: 12
     privateNetworking: true
     ssh:
       publicKeyPath: ~/.ssh/id_rsa.pub
     iam:
       withAddonPolicies:
           imageBuilder: true
           autoScaler: true
           externalDNS: true
           certManager: true
           appMesh: true
           ebs: true
           fsx: true
           efs: true
           albIngress: true
           xRay: true
           cloudWatch: true
   ```

   > For production purposes, select a VPC with a private IP.

   > The `ssh` entry is optional, allowing you to SSH in to your cluster.

2. Create the clusters using `eksctl`.

   a. Create the first cluster. For example:

   ```shell
   eksctl create cluster -f ca-central-1.yaml --profile <aws-profile>
   ```

   b. Create the second cluster. For example:

   ```shell
   eksctl create cluster -f us-west-2.yaml --profile <aws-profile>
   ```

3. Log in to the AWS console, go to the **VPC** service, select **Your VPCs** (under Virtual Private Cloud), and note the VPC details for the clusters you've created.

   > Retain the `VpcId` values for the `ca-central-1` and `us-west-2` VPCs. You'll use these in subsequent steps.

4. Set up VPC peering between the two clusters. You'll create a peering connection from the cluster in the `us-west-2` region to the cluster in the `ca-central-1` region. You'll do this from the VPC Dashboard as in the prior step.

   a. In the top right of the page, select the **Oregon** (us-west-2) region.

   b. Select **Peering Connections**, and click **Create Peering Connection**.

   c. Assign a unique name for the peering connection (for example, us-west-2-to-ca-central-1).

   d. Under **Select a local VPC to peer with**, enter the `VpcId` value for the `us-west-2` VPC.

   e. Under **Select another VPC to peer with**, select **My account** --> **Another region** --> **Canada Central** (ca-central-1).

   f. Under **VPC (Accepter)**, enter the `VpcId` value for the `ca-central-1` region.

   g. Click **Create Peering Connection**. When successful, a confirmation is displayed. Click **OK** to continue.

   h. In the top right of the page, change the region to **Canada Central**.

   i. Select **Peering Connections**.

   > Notice that the peering connection status for `us-west-2` shows as `Pending Acceptance`.

   j. Select the `ca-central-1` connection, click the **Actions** dropdown list, and select **Accept Request**. You'll be prompted to confirm.

   > The VPC peering connection status should now show as `Active`.

5. Get the subnets information for each cluster node. Each cluster node uses a different subnet, so there'll be three subnets assigned to each VPC. The information displayed will contain the subnet ID for each subnet. You'll use the subnet IDs in the subsequent step to get the associated routing tables.

   a. In the top right of the page, change the region to **Oregon**.

   b. Go to the **EC2** service, and select **Instances**. Apply a filter, if needed, to find your nodes for the cluster.

   c. Select each node, and record the **Subnet ID** of each. You'll use the subnet IDs in a subsequent step.

   d. In the top right of the page, change the region to **Canada Central**, and repeat the 2 previous steps to find and record the subnet IDs for this VPC.

6. Get the routing table associated with the subnets for each VPC.

   a. Go to the **VPC** service. (You're still using the Canada Central region.)

   b. In the VPC Dashboard, select **Subnets**.

   c. For each subnet displayed, record the **Routing Table** value. You may have a single routing table for all of your subnets. You'll use the routing table ID or IDs in a subsequent step.

   d. In the top right of the page, change the region to **Oregon**, and repeat the 2 previous steps to find and record the routing table ID or IDs for this VPC.

7. Modify the routing table or tables for each VPC to add a route to the other VPC using the peering connection you created.

   a. In the VPC Dashboard, select **Route Tables**. (You're still using the Oregon region.)

   b. Select the route table you recorded for the `us-west-2` (Oregon) VPC, and click the `Routes` button. You should see 2 routes displayed.

   c. Click **Edit Routes** --> **Add Route**, and for **Destination**, enter the CIDR block for the `ca-central-1` cluster (172.16.0.0/16).

   d. For **Target**, select the VPC peering connection you created in a prior step. Click **Save Routes**.

      A route for the `ca-central-1` cluster directed to the peering connection is displayed.

   e. If more than one routing table is used for the `us-west-2` VPC, repeat the previous steps for each routing table.

   f. In the top right of the page, change the region to **Canada Central**.

   g. Select the route table you recorded for the `ca-central-1` (Canada Central) VPC, and click the `Routes` button. You should see 2 routes displayed.

   h. Click **Edit Routes** --> **Add Route**, and for **Destination**, enter the CIDR block for the `us-west-2` cluster (10.0.0.0/16).

   i. For **Target**, select the VPC peering connection you created in a prior step. Click **Save Routes**.

      A route for the `us-west-2` cluster directed to the peering connection is displayed.

   j. If more than one routing table is used for the `ca-central-1` VPC, repeat the previous steps for each routing table.

8.  Update the Security Groups for each VPC. You'll get the Security Group IDs for each VPC, then add inbound and outbound rules for both the `us-west-2` VPC, and the `ca-central-1` VPC.

       a. In the VPC Dashboard, select **Security Groups**.  (You're still using the Canada Central region.)

       b. Apply a filter to find the security groups for the `ca-central-1` cluster, and select the security group with “-nodegroup” in the name. This is the security group used for the firewall settings for all the worker nodes in the `ca-central-1` cluster.

       c. Click **Inbound Rules** --> **Add Rule**.

       d. Select these values for the rule:

    *	Type:  Custom TCP Rule

    *	Protocol: TCP

    *	Port Range: 7600-7700
        > These ports are for are specific to PingFederate Clustering, adjust based on your products.

    *	Source: Custom, and enter the CIDR block for the `us-west-2` (10.0.0.0/16) cluster.

       e. Click **Save Rules** to save the inbound security group rule for the `ca-central-1` cluster.

       f. Click **Outbound Rules** --> **Add Rule**.

       g. Select these values for the rule:

    *	Type:  Custom TCP Rule

    *	Protocol: TCP

    *	Port Range: 7600-7700
        > These ports are for are specific to PingFederate Clustering, adjust based on your products.

    *	Source: Custom, and enter the CIDR block for the `us-west-2` (10.0.0.0/16) cluster.

       h. Click **Save Rules** to save the outbound security group rule for the `ca-central-1` cluster.

       i. In the top right of the page, change the region to **Oregon**. You'll now repeat the previous steps to add inbound and outbound rules for the `us-west-2` cluster.

       j. Apply a filter to find the security groups for the `us-west-2` cluster, and select the security group with “-nodegroup” in the name. This is the security group used for the firewall settings for all the worker nodes in the `us-west-2` cluster.

       k. Click **Inbound Rules** --> **Add Rule**.

       l. Select these values for the rule:

    *	Type:  Custom TCP Rule

    *	Protocol: TCP

    *	Port Range: 7600-7700
        > These ports are for are specific to PingFederate Clustering, adjust based on your products.

    *	Source: Custom, and enter the CIDR block for the `ca-central-1` (172.16.0.0/16) cluster.

       m. Click **Save Rules** to save the inbound security group rule for the `us-west-2` cluster.

       n. Click **Outbound Rules** --> **Add Rule**.

       o. Select these values for the rule:

    *	Type:  Custom TCP Rule

    *	Protocol: TCP

    *	Port Range: 7600-7700
        > These ports are for are specific to PingFederate Clustering, adjust based on your products.

    *	Source: Custom, and enter the CIDR block for the `ca-central-1` (172.16.0.0/16) cluster.

       p. Click **Save Rules** to save the outbound security group rule for the `us-west-2` cluster.


