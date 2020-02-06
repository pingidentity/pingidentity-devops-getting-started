# Deployments to Amazon Web Services EKS

You'll find here information regarding the deployment, management and scaling of our product containers to AWS using Amazon's:

* Elastic Kubernetes Service (EKS).
* Elastic Container Service (ECS)
  * Using Fargate
  * Using EC2

## Prerequisites

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've created a Kubernetes cluster on AWS EKS.
* You've created a Kubernetes secret using your DevOps credentials. See the *For Kubernetes* topic in [Using your DevOps user and key](devopsUserKey.md).
* You've downloaded and installed the [AWS CLI](https://aws.amazon.com/cli/).
* You've downloaded and installed [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
* You've downloaded and installed [eksctl](https://eksctl.io).

We also highly recommend you are familiar with the information in these AWS articles:

* [Getting Started with Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
* [Creating a Cluster with a Fargate Task Using the Amazon ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html)
* [Creating a Cluster with an EC2 Task Using the Amazon ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-ec2.html)

## Create a cluster using the EKS CLI

You'll create a cluster on EKS is with the `eksctl` CLI tool. 

1. If you've not already done so, set up your AWS configuration and credentials using the `aws configure` command.
2. Create a 2 node cluster using `eksctl`. (Use `eksctl create cluster -h` to see all options when creating a cluster). For example:

   > Different versions are available with EKS, depending on your AWS region.

   ```bash
   eksctl create cluster \
       --name ping-devops-test \
       --tags owner=${USER} \
       --version 1.12 \
       --nodegroup-name standard-workers \
       --node-type m5d.large \
       --nodes 2 \
       --nodes-min 1 \
       --nodes-max 4 \
       --node-ami auto
   ```

   It may take several minutes to create the clusters, because virtual private clouds (VPCs), security groups, and EC2 instances will be created in this process. It's ready when you see output similar to this:

   `[✔] EKS cluster "ping-devops-test" in "us-east-2" region is ready`

3. After the cluster is created, you can display the cluster and nodegroup details using:

   ```bash
   eksctl get cluster   --name=ping-devops-test
   ```

   ```bash
   eksctl get nodegroup --cluster=ping-devops-test
   ```

   Get information on the nodes using `kubectl`:

   ```bash
   kubectl get nodes
   ```

4. The cluster we created started with 2 nodes. You can scale the cluster using `eksctl scale nodegroup`. For example:

   ```bash
   eksctl scale nodegroup --cluster=ping-devops-test --nodes=3 standard-workers
   ```

5. When you're ready to delete the cluster, use `eksctl delete cluster`. For example:

   ```bash
   eksctl delete cluster --name=ping-devops-test
   ```

## Create a cluster using the ECS CLI 

### Initial setup

1. Configure your profile and credentials on your host using `ecs-cli`. For example:

   > You'll need to either set a variable for your `$AWS_ACCESS_KEY_ID`  and `$AWS_SECRET_ACCESS_KEY` values, or replace them in the example.

   ```bash
   ecs-cli configure profile \
     --access-key $AWS_ACCESS_KEY_ID \
     --secret-key $AWS_SECRET_ACCESS_KEY
   ```

   This command creates a `~/.ecs/credential` file that looks similar to this:

   ```bash
   $ more ~/.ecs/credentials
   version: v1
   default: default
   ecs_profiles:
     default:
       aws_access_key_id: **** your aws access key id ****
       aws_secret_access_key: **** your aws secret key key ****
   ```

2. Configure a cluster definition on your host using `ecs-cli configure`. For example:

   > The example configures a local cluster, creating a future cluster in `us-east-2`. You should changes this to a region you want to run in.

   ```bash
   ecs-cli configure \
           --cluster ping-devops-ecs-cluster \
           --default-launch-type FARGATE \
           --region us-east-2  \
           --config-name ping-devops-ecs-config
   ```

   This will create a `~/.ecs/config` file that looks similar to this:

   ```bash
   more ~/.ecs/config
   version: v1
   default: ping-devops-ecs-config
   clusters:
     ping-devops-ecs-config:
       cluster: ping-devops-ecs-cluster
       region: us-east-2
       default_launch_type: FARGATE
   ```

### Provide access to CloudWatch logs

Amazon ECS needs permissions for your Fargate task to store logs in AWS's CloudWatch monitoring service. These permissions are covered by the Task Execution IAM role. 

To create the Task Execution IAM role using the AWS CLI:

1. Create a file named `task-execution-assume-role.json` with this content:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "",
         "Effect": "Allow",
         "Principal": {
           "Service": "ecs-tasks.amazonaws.com"
         },
         "Action": "sts:AssumeRole"
       }
     ]
   }
   ```

2. Create the task execution role as follows:

   ```bash
   aws iam --region us-west-2 create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://task-execution-assume-role.json
   ```

3. Attach the task execution role policy as follows:

   ```bash
   aws iam --region us-west-2 attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
   ```

See [Amazon ECS Task Execution IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html) and [Creating a Cluster with a Fargate Task Using the Amazon ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html) for more information.

### Create the cluster on ECS

You need to create an ECS cluster on which to host services and containers. Using the ECS CLI, you have a choice. You can either:

* Create all related aspects of a cluster (VPC, Subnets, Security-groups) during cluster creation. 
* Leverage existing resources. 

#### Create all related aspects of a cluster on ECS during cluster creation

Your AWS ID or Role needs to have the AWS authorization necessary to create a cluster.

1. To create a cluster on ECS, enter either: 
 
   ```bash
   ecs:CreateCluster
   ```

   or, if you have a role that is used within your `.aws/config`:

   ```bash
   ecs:CreateCluster --aws-profile <profile-name>
   ```

2. Start the cluster. Enter:

   ```bash
   ecs-cli up
   ```

   The resulting ouput will be similar to this:

   ```text
   INFO[0001] Created cluster                               cluster=ping-devops-ecs-cluster region=us-east-2
   INFO[0002] Waiting for your cluster resources to be created...
   INFO[0002] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
   INFO[0064] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
   VPC created: vpc-*********************
   Subnet created: subnet-*********************
   Subnet created: subnet-*********************
   Cluster creation succeeded.
   ```

3. Capture the VPC and Subnet ID's displayed. You'll use these in subsequent steps.

4. Now that you've started the cluster, you need to create a security group to protect the VPC. You'll use the VPC ID returned in the prior step. Your AWS ID or Role needs to have the AWS authorization necessary to create a security group. To create a security group for the cluster, enter: 
 
   ```bash
   aws ec2 create-security-group \
       --group-name "ping-devops-ecs-sg" \
       --description "Ping DevOps Security Group" \
       --vpc-id "<vpc-id-created-in-prior-step>"
   ```

   or, if you have a role that is used within your `.aws/config`:

   ```bash
   aws ec2 create-security-group \
       --group-name "ping-devops-ecs-sg" \
       --description "Ping DevOps Security Group" \
       --vpc-id "<vpc-id-created-in-prior-step>"
       --profile "<your-profile-name>"
   ```

   The resulting ouput will be similar to this:

   ```text
   {
     "GroupId": "sg-********************"
   }
   ```

5. Use the `GroupId` value returned in the prior step to add an Ingress point of ports 9999 and 9031 to access the PingFederate container that you'll deploy.

   ```bash
   aws ec2 authorize-security-group-ingress \
       --protocol tcp \
       --port 9031 \
       --port 9999 \
       --cidr 0.0.0.0/0 \
       --group-id "<group-id-created-in-prior-step>"
   ```

#### Create a cluster on ECS using existing resources

If you have an existing VPC, security group, and two subnets related to the VPC, you can leverage these resources to create the cluster using the `ecs-cli up` command. For example:  

```bash
ecs-cli up --vpc <vpc-id> --security-group <security-group-id> --subnets <required-subnet-1>,<required-subnet-2>
```

Where \<vpc-id>, \<security-group-id>, and the `--subnets` \<required-subnet-1> and \<required-subnet-2> are all existing resources available to you.

> Ensure the standard PingFederate ports 9031 and 9999 are part of your security group if you wish to use them when deploying PingFederate.

### Deploy PingFederate as a service in an ECS cluster

You'll create `docker-compose.yml` and `ecs-params.yml` files based on these AWS instructions:

> Note the `.yml` extension, as opposed to `.yaml` for the AWS YAML files.

* [Using Docker Compose File Syntax](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-parameters.html)
* [Using Amazon ECS Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-ecsparams.html)

> You'll update these files with your specific configuration details.

1. Create the `docker-compose.yml` file based on the AWS instructions. For example:

   ```yaml
   version: "3"

   services:
     pingfederate:
       image: pingidentity/pingfederate:edge
       environment:
         - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
         - SERVER_PROFILE_PATH=getting-started/pingfederate
       ports:
         - 9031:9031
         - 9999:9999
       logging:
         driver: awslogs
         options:
           awslogs-group: ping-devops-ecs-logs
           awslogs-region: us-east-2
           awslogs-stream-prefix: ping-devops
   ```

2. Create the `ecs-params.yml` file based on the AWS instructions. For example:

   ```yaml
   version: 1
   task_definition:
     task_execution_role: ecsTaskExecutionRole
     ecs_network_mode: awsvpc
     task_size:
       mem_limit: 2.0GB
       cpu_limit: 1024
   run_params:
     network_configuration:
       awsvpc_configuration:
         subnets:
           - "subnet-<replace with subnet 1 from prior step>"
           - "subnet-<replace with subnet 2 from prior step>"
         security_groups:
           - "sg-<replace with security group id from prior step>"
         assign_public_ip: ENABLED
   ```

3. From the directory where you created the `docker-compose.yml` and `ecs-params.yml` files, start the PingFederate service. Enter:

   ```bash
   ecs-cli compose --project-name pingfederate-devops \
       service up \
       --cluster ping-devops-ecs-cluster
       --create-log-groups
   ```

   > Only specify `--create-log-groups` on the first run.


1. To display the PingFederate service status, enter:

   ```bash
   ecs-cli compose --project-name pingfederate-devops service ps
   ```

2. To bring the service down, enter:

   ```bash
   ecs-cli compose service down
   ```

3. When you want to delete the cluster, enter:

   ```bash
   ecs-cli down
   ```

   The resulting output will be similar to this:

   ```bash
   INFO[0004] Waiting for your cluster resources to be deleted...
   INFO[0004] Cloudformation stack status                   stackStatus=DELETE_IN_PROGRESS
   INFO[0066] Deleted cluster                               cluster=ping-devops-ecs-cluster
   ```

