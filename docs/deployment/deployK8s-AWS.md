---
title: Prepare AWS EKS for Multi-Region Deployments
---
# Preparing AWS EKS for Multi-Region Deployments

## Overview

In this guide you will deploy two Kubernetes clusters, each in a different Amazon Web Services (AWS) region. An AWS virtual private cloud (VPC) is assigned and dedicated to each cluster. Throughout this document, "VPC" is synonymous with "cluster".

## Prerequisites

Before you begin, you must have:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

* [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html), the current version

* AWS account permissions to create clusters

## Configuring the AWS CLI

If you have not already done so, configure the AWS CLI to use your profile and credentials:

1. To assign your profile and supply your `aws_access_key_id` and `aws_secret_access_key`, run the following command:

      ```sh
      aws configure --profile=<aws-profile>
      ```

      When prompted, provide your `aws_access_key_id` and `aws_secret_access_key`.

1. Open the `~/.aws/credentials` file in a text editor and add your AWS `role_arn`.

      For example:

      ```sh
      “role_arn = arn:aws:iam::xxxxxxxx4146:role/xxx”
      ```

## Create the multi-region clusters

1. Create the YAML files to configure the the clusters.

      You will create the clusters in different AWS regions. For this example, we use the `ca-central-1` region and the `us-west-2` region.

      * First cluster, using the `ca-central-1` region and the reserved CIDR `172.16.0.0`:

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

         > For production purposes, select a VPC with a private IP. The `ssh` entry is optional, allowing you to SSH in to your cluster.

      * Second cluster, using the `us-west-2` region and the reserved CIDR `10.0.0.0`:

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

         > For production purposes, select a VPC with a private IP. The `ssh` entry is optional, allowing you to SSH in to your cluster.

2. Create the clusters using `eksctl`.

      * Create the first cluster: 

         ```shell
         eksctl create cluster -f ca-central-1.yaml --profile <aws-profile>
         ```

      * Create the second cluster:

         ```shell
         eksctl create cluster -f us-west-2.yaml --profile <aws-profile>
         ```

3. Sign on to the AWS console and navigate to the **VPC** service.  Select **Your VPCs** (under Virtual Private Cloud), and record the VPC details for the clusters that were just created.

      > Make note of the `VpcId` values for the `ca-central-1` and `us-west-2` VPCs for use in subsequent steps.

4. Set up VPC peering between the two clusters.

      Create a peering connection from the cluster in the `us-west-2` region to the cluster in the `ca-central-1` region, using the VPC Dashboard as in the previous step.

      * At the top right of the page, select the **Oregon** (us-west-2) region.

      * Select **Peering Connections** and click **Create Peering Connection**.

      * Assign a unique name for the peering connection (for example, us-west-2-to-ca-central-1).

      * Under the **Select a local VPC to peer with** section, enter the `VpcId` value for the `us-west-2` VPC.

      * In the **Select another VPC to peer with** list, select **My account** --> **Another region** --> **Canada Central** (ca-central-1).

      * Under the **VPC (Accepter)** section, enter the `VpcId` value for the `ca-central-1` region.

      * Click **Create Peering Connection** and when you receive a confirmation message, click **OK** to continue.

      * At the top right of the page, change the region to **Canada Central**.

      * Select **Peering Connections**.

         > The peering connection status for `us-west-2` will show as `Pending Acceptance`.

      * Select the `ca-central-1` connection, click the **Actions** list, and select **Accept Request** and confirm when prompted.

         > The VPC peering connection status should now show as `Active`.

5. Get the subnet information for each cluster node.

      Each cluster node uses a different subnet, so there are three subnets assigned to each VPC. The information displayed contains the subnet ID for each subnet. Use the subnet IDs in the subsequent step to get the associated routing tables.

      * At the top right of the page, change the region to **Oregon**.

      * Go to the **EC2** service, and select **Instances**. Apply a filter, if needed, to find your nodes for the cluster.

      * Select each node and record the **Subnet ID** for use in a subsequent step.

      * At the top right of the page, change the region to **Canada Central**, and repeat these steps to find and record the subnet IDs for this VPC.

6. Get the routing table associated with the subnets for each VPC.

      * Go to the **VPC** service for the Canada Central region.

      * In the VPC Dashboard, select **Subnets**.

      * For each subnet displayed, record the **Routing Table** value. You might have a single routing table for all of your subnets. You will use the routing table ID or IDs in a subsequent step.

      * At the top right of the page, change the region to **Oregon**, and repeat these steps to find and record the routing table ID or IDs for this VPC.

7. Modify the routing table or tables for each VPC to add a route to the other VPC using the peering connection that was created.

      * In the VPC Dashboard, select **Route Tables** for the Oregon region.

      * Select the route table you recorded for the `us-west-2` (Oregon) VPC, and click the `Routes` button.

         Two routes are displayed.

      * Click **Edit Routes** --> **Add Route**, and for **Destination**, enter the CIDR block for the `ca-central-1` cluster (172.16.0.0/16).

      * For **Target**, select the VPC peering connection you created in a prior step. Click **Save Routes**.

         A route for the `ca-central-1` cluster directed to the peering connection is displayed.

      * If more than one routing table is used for the `us-west-2` VPC, repeat the previous steps for each routing table.

      * At the top right of the page, change the region to **Canada Central**.

      * Select the route table you recorded for the `ca-central-1` (Canada Central) VPC, and click the `Routes` button.

         Two routes are displayed.

      * Click **Edit Routes** --> **Add Route**, and for **Destination**, enter the CIDR block for the `us-west-2` cluster (10.0.0.0/16).

      * For **Target**, select the VPC peering connection you created in a prior step. Click **Save Routes**.

        A route for the `us-west-2` cluster directed to the peering connection is displayed.

      * If more than one routing table is used for the `ca-central-1` VPC, repeat the previous steps for each routing table.

8. Update the Security Groups for each VPC. Note the Security Group IDs for each VPC and add inbound and outbound rules for both the `us-west-2` VPC, and the `ca-central-1` VPC.

      * In the VPC Dashboard, select **Security Groups** for the Canada Central region.

      * Apply a filter to find the security groups for the `ca-central-1` cluster, and select the security group with “-nodegroup” in the name.  This security group is used for the firewall settings for all the worker nodes in the `ca-central-1` cluster.

      * Click **Inbound Rules** --> **Add Rule**.

      * Select these values for the rule:

         * Type:  Custom TCP Rule

         * Protocol: TCP

         * Port Range: 7600-7700

         > These ports are for are specific to PingFederate Clustering; adjust based on your products.

         * Source: Custom, and enter the CIDR block for the `us-west-2` (10.0.0.0/16) cluster.

      * Click **Save Rules** to save the inbound security group rule for the `ca-central-1` cluster.

      * Click **Outbound Rules** --> **Add Rule**.

      * Select these values for the rule:

         * Type:  Custom TCP Rule

         * Protocol: TCP

         * Port Range: 7600-7700

         > As before, these ports are for are specific to PingFederate Clustering; adjust based on your products.

         * Source: Custom, and enter the CIDR block for the `us-west-2` (10.0.0.0/16) cluster.

      * Click **Save Rules** to save the outbound security group rule for the `ca-central-1` cluster.

      * At the top right of the page, change the region to **Oregon**. The process for configuring these security groups will mirror the previous steps.

      * Apply a filter to find the security groups for the `us-west-2` cluster, and select the security group with “-nodegroup” in the name. This security group is used for the firewall settings for all the worker nodes in the `us-west-2` cluster.

      * Click **Inbound Rules** --> **Add Rule**.

      * Select these values for the rule:

         * Type:  Custom TCP Rule

         * Protocol: TCP

         * Port Range: 7600-7700

         > Again, PingFederate Clustering is used in this example; adjust based on your products.

         * Source: Custom, and enter the CIDR block for the `ca-central-1` (172.16.0.0/16) cluster.

      * Click **Save Rules** to save the inbound security group rule for the `us-west-2` cluster.

      * Click **Outbound Rules** --> **Add Rule**.

      * Select these values for the rule:

         * Type:  Custom TCP Rule

         * Protocol: TCP

         * Port Range: 7600-7700

         > PingFederate Clustering again

         * Source: Custom and enter the CIDR block for the `ca-central-1` (172.16.0.0/16) cluster.

      * Click **Save Rules** to save the outbound security group rule for the `us-west-2` cluster.
