# Deploy Multi Region PingFederate Cluster in AWS



## Prerequisites

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

## Procedure

1. Configure the AWS CLI. See [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for more information.

2. Create the YAML files to configure the the clusters. You'll create the clusters in different AWS regions. We'll be using the `ca-central-1` region and the `us-west-2` region in this document.
   
   a. Configure the first cluster. For example, using the `ca-central-1` region and the reserved CIDR 172.16.0.0:
   
   ```yaml
   apiVersion: eksctl.io/v1alpha5
   kind: ClusterConfig

   metadata:
     name: pingfed-dev-chrisa-aws-ca-central-1
     region: ca-central-1
     version: "1.4"

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
     name: pingfed-dev-chrisa-aws-us-west-2
     region: us-west-2
     version: "1.4"

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

3. Create the clusters using `eksctl`. 
   
   a. Create the first cluster. For example:

   ```shell
   eksctl create cluster --config-file=./ca-central-1.yaml --set-kubeconfig-context=true --profile=<your-aws-cli-profile>
   ```

   b. Create the second cluster. For example:

   ```shell
   eksctl create cluster --config-file=./us-west-2.yaml --set-kubeconfig-context=true --profile=<your-aws-cli-profile>
   ```

4. Verify the details for the VPCs you created. Enter:
   
   ```shell
   aws ec2 describe-vpcs
   ```

   This will display information for all of your VPCs. Alternatively, you can log in to AWS and go the the VPC Dashboard page to display the information for selected VPCs.

5. Set up VPC peering between the two clusters. You'll create a peering connection from one VPC and accept the peering connection from the other VPC.
   
   a. Create a peering connection from the cluster in the `ca-central-1` region to the cluster in the `us-west-2` region. For example:

   ```shell
   aws ec2 create-vpc-peering-connection --vpc-id <id-for-canada-central-1> --peer-region ca-central-1 --peer-vpc-id <id-for-us-west-2> --peer-region us-west-2
   ```

   b. Verify that the peering connection is in the "pending acceptance" state. Enter:

   ```shell
   aws ec2 describe-vpc-peering-connections --filters Name=status-code,Values=pending-acceptance
   ```

   c. Copy the `VpcPeeringConnectionId` value from the resulting output for the VPC in the `us-west-2` region.

   d. Accept the peering connection for the `us-west-2` VPC (initiated by the `ca-central-1` VPC). Enter:

   ```shell
   aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id <us-west-2-VpcPeeringConnectionId>
   ```

6. Get the subnets for each cluster. Each cluster instance uses a different subnet, so there'll be three subnets assigned to each cluster.
   
   a. Get the information about the `ca-central-1` cluster. The subnet IDs are included. Enter:

   ```shell
   aws eks describe-cluster --name <ca-central-1-cluster-name>
   ```

   In the YAML file you used to configure the `ca-central-1` cluster, &lt;ca-central-1-cluster-name&gt; is the initial entry (`name:`)in the `metadata:` section.

   b. Get the information about the `us-west-2` cluster. The subnet IDs are included. Enter:

   ```shell
   aws eks describe-cluster --name <us-west-2-cluster-name>
   ```

   In the YAML file you used to configure the `us-west-2` cluster, &lt;us-west-2-cluster-name&gt; is the initial entry (`name:`)in the `metadata:` section.


7. Get the routing tables associated with the subnets for each cluster.
   
   a. First get the instances and associated subnets for the `ca-central-1` cluster. For example:

   ```shell
   aws ec2 describe-instances \
           --instance-id $instanceId \
           --query "Reservations[*].Instances[].SubnetId" \
           --output text



8. 
