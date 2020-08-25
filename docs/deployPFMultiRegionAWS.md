# Deploy a multi-region PingFederate cluster in AWS

In this example, we'll use 2 PingFederate clusters, each in a different Amazon Web Services (AWS) region. An AWS virtual private cloud (VPC) is assigned and dedicated to each cluster. Throughout this document, "VPC" is synonymous with "cluster".

## Prerequisites

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

* [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

* AWS account permissions to create clusters
  
## Procedure

1. Configure the AWS CLI. See the AWS document [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for more information.

2. Create the YAML files to configure the the clusters. You'll create the clusters in different AWS regions. We'll be using the `ca-central-1` region and the `us-west-2` region in this document.
   
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

   nodeGroups:
     - name: base
       instanceType: c5.4xlarge
       minSize: 3
       maxSize: 3
       desiredCapacity: 3
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

   nodeGroups:
     - name: base
       instanceType: c5.4xlarge
       minSize: 3
       maxSize: 3
       desiredCapacity: 3
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

3. Create the clusters using `eksctl`. 
   
   a. Create the first cluster. For example:

   ```shell
   eksctl create cluster -f ca-central-1.yaml
   ```

   b. Create the second cluster. For example:

   ```shell
   eksctl create cluster -f us-west-2.yaml
   ```

4. Verify the details for the clusters (VPCs) you created. Enter:
   
   ```shell
   aws ec2 describe-vpcs
   ```

   This will display information for all of your VPCs. Alternatively, you can log in to AWS and go the the VPC Dashboard page to display the information for selected VPCs.

   > Retain the `VpcId` values for the `ca-central-1` and `us-west-2` VPCs. You'll use these in subsequent steps.

5. Set up VPC peering between the two clusters. You'll create a peering connection from one VPC and accept the peering connection from the other VPC.
   
   a. Create a peering connection from the cluster in the `ca-central-1` region to the cluster in the `us-west-2` region. For example:

   ```shell
   aws ec2 create-vpc-peering-connection --vpc-id <id-for-ca-central-1> --peer-region ca-central-1 --peer-vpc-id <id-for-us-west-2> --peer-region us-west-2
   ```

   The `VpcId` for the `ca-central-1` VPC was displayed in the prior step (`aws ec2 describe-vpcs`).

   b. Verify that the peering connection is in the "pending acceptance" state. For example:

   ```shell
   aws ec2 describe-vpc-peering-connections --filters Name=status-code,Values=pending-acceptance
   ```

   c. Copy the `VpcPeeringConnectionId` value from the resulting output for the VPC in the `us-west-2` region.

   > Retain the `VpcPeeringConnectionId` value. You'll use this in a subsequent step.

   d. Accept the peering connection for the `us-west-2` VPC (initiated by the `ca-central-1` VPC). For example:

   ```shell
   aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id <us-west-2-VpcPeeringConnectionId>
   ```

6. Get the subnets information for each VPC. Each cluster instance uses a different subnet, so there'll be three subnets assigned to each VPC. The information returned will contain the subnet ID for each subnet. You'll use the subnet IDs in the subsequent step to get the associated routing tables.
   
   a. Get the subnets information for the `ca-central-1` VPC. For example:

   ```shell
   aws ec2 describe-subnets --filters "Name=vpc-id,Values=<id-for-ca-central-1>"
   ```

   Where &lt;id-for-ca-central-1&gt; is the `VpcId` of the `ca-central-1` VPC.

   > Retain the `SubnetId` value for each subnet. You'll use these in a subsequent step.

   b. Get the subnets information for the `us-west-2` VPC. For example:

   ```shell
   aws ec2 describe-subnets --filters "Name=vpc-id,Values=<id-for-us-west-2>"
   ```

   Where &lt;id-for-us-west-2&gt; is the `VpcId` of the `us-west-2` VPC.

   > Retain the `SubnetId` value for each subnet. You'll use these in the next step to get the associated routing tables.

7. Get the routing table associated with the subnets for each VPC.
   
   a. Get the routing table for each subnet in the `ca-central-1` VPC. For example:

   ```shell
   aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=<ca-central-1-SubnetId>"
   ```

   There may be only one routing table associated with all of the subnets for a VPC.

   > Retain the `RouteTableId` value for each routing table. You'll use this in a subsequent step.

   b. Repeat the above step for each of the remaining subnets in the `ca-central-1` cluster.

   c. Get the routing tables for each subnet in the `us-west-2` cluster. For example:

   ```shell
   aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=<us-west-2-SubnetId>"
   ```

   d. Repeat the above step for each of the remaining subnets in the `ca-central-1` cluster.

   > Retain the `RouteTableId` for each routing table. You'll use this in the next step.

8. Modify the routing tables for each VPC to add a route to the other VPC.
   
   a. Add a route to the routing table for the `ca-central-1` VPC to the `us-west-2` VPC. For example:

   ```shell
   aws ec2 create-route --route-table-id <ca-central-1-RouteTableId> --destination-cidr-block 10.0.0.0/16 --vpc-peering-connection-id <VpcPeeringConnectionId-value>
   ```

   Where &lt;VpcPeeringConnectionId-value&gt; is the ID for the peering connection you created in a prior step.

   b. If more than one routing table is used for the VPC, repeat the above step for each routing table (`RouteTableId` value).

   c. Add a route to the routing table for the `us-west-2` VPC to the `ca-central-1` VPC. For example:

   ```shell
   aws ec2 create-route --route-table-id <us-west-2-RouteTableId> --destination-cidr-block 172.16.0.0/16 --vpc-peering-connection-id <VpcPeeringConnectionId-value>
   ```

   Where &lt;VpcPeeringConnectionId-value&gt; is the ID for the peering connection you created in a prior step.

   d. If more than one routing table is used for the VPC, repeat the above step for each routing table (`RouteTableId` value).

9. Update the Security Groups for each VPC. You'll get the Security Group IDs for each VPC, then add inbound and outbound rules to both the `us-west-2` VPC, and to the `ca-central-1` VPC.
    
   a. Get the Security Group information for the `us-west-2` VPC. For example:

   ```shell
   aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<us-west-2-VpcId>"
   ```

   Where `VpcId` is the `us-west-2` VPC ID value you saved from a prior step. 

   > Retain the `GroupId` value displayed for the Security Group. You'll use this in a subsequent step.

   b. Get the Security Group information for the `ca-central-1` VPC. For example:

   ```shell
   aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<ca-central-1-VpcId>"
   ```

   Where `VpcId` is the `ca-central-1` VPC ID value you saved from a prior step. 

   > Retain the `GroupId` value displayed for the Security Group. You'll use this in the next step.

   c. Add an inbound rule for the Security Group associated with the `us-west-2` VPC. For example:

   ```shell
   aws ec2 authorize-security-group-ingress \
    --group-id <us-west-2-GroupId> \
    --protocol tcp \
    --port 7600-7700 \
    --source-group <ca-central-1-GroupId>
   ```

   d. Add an outbound rule for the Security Group associated with the `us-west-2` VPC. For example:

   ```shell
   aws ec2 authorize-security-group-egress \
    --group-id <ca-central-1-GroupId> \
    --protocol tcp \
    --port 7600-7700 \
    --source-group <us-west-2-GroupId>
   ```

   e. Add an inbound rule for the Security Group associated with the `ca-central-1` VPC. For example:

   ```shell
   aws ec2 authorize-security-group-ingress \
    --group-id <ca-central-1-GroupId> \
    --protocol tcp \
    --port 7600-7700 \
    --source-group <us-west-2-GroupId>
   ```

   f. Add an outbound rule for the Security Group associated with the `ca-central-1` VPC. For example:

   ```shell
   aws ec2 authorize-security-group-egress \
    --group-id <us-west-2-GroupId> \
    --protocol tcp \
    --port 7600-7700 \
    --source-group <ca-central-1-GroupId>
   ```

10. 

