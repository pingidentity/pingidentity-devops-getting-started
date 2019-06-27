# Amazon

## Amazon Elastic Container Service for Kubernetes \(Amazon EKS\)

This directory contains scripts and deployment files to help with the deployment, management and scaling of Ping Identity DevOps Docker Containers to AWS using:

* [Elastic Container Service for Kubernetes \(EKS\)](amazon.md#creating-a-cluster-on-eks)
* [Elastic Container Service \(ECS\)](amazon.md#steps-for-running-ping-identity-devops-containers-with-ecs-cli)
  * Using Fargate Task
  * Using EC2 Task

### Getting started

We highly recommend you read the AWS articles on:

* [EKS getting-started guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
* [ECS getting-started with Fargate Task guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html)
* [ECS getting-started with EC2 Task guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-ec2.html)

## Steps for running Ping Identity DevOps Containers with EKS CLI

### Creating a cluster on EKS

The easiest way to create a cluster on Amazon EKS is with the `eksctl` CLI tool. The examples below assume you have first downloaded and installed:

* [AWS CLI](https://aws.amazon.com/cli/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [eksctl](https://eksctl.io)

Assuming you have setup your aws config/credientals using the `aws configure` command, an example of how to create a cluster looks like. Note that depending on the AWS Region you are in, different versions \(1.12 shown below\) are available, along with the EKS service.

```text
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

> Note: It may take several minutes to create the clusters as vpcs, security groups and ec2 instances will be created in this process. You will note that it is ready when you see the output:

`[✔] EKS cluster "ping-devops-test" in "us-east-2" region is ready`

To see all the options when creating a cluster, simply run `eksctl create cluster -h`.

### Retrieving cluster information

Once created, some helpful commands to see the cluster details and nodegroup details using eksctl include:

* `eksctl get cluster   --name=ping-devops-test`
* `eksctl get nodegroup --cluster=ping-devops-test`

And using `kubectl` you can get information on the nodes with:

* `kubectl get nodes`

### To Manually scale the cluster

In the above example, the cluster starts with 2 nodes. If you wan to scale down/up, use the command:

* `eksctl scale nodegroup --cluster=ping-devops-test --nodes=3 standard-workers`

### To Delete cluster

When you want to delete the cluster, you can do so with the command:

* `eksctl delete cluster --name=ping-devops-test`

## Steps for running Ping Identity DevOps Containers with ECS CLI

### 1. Installing and Configuring ECS CLI

The easiest way to create a cluster on Amazon ECS is with the `ecs-cli` CLI tool. The examples below assume you have first downloaded and installed:

* [ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)

To configure the profile/credentials to `ecs-cli` on your host:

> Note: You will need to either set a variable for you personal AWS\_ACCESS\_KEY\_ID and AWS\_SECRET\_ACCESS\_KEY values, or replace them in the command below.

```text
ecs-cli configure profile \
        --access-key $AWS_ACCESS_KEY_ID \
        --secret-key $AWS_SECRET_ACCESS_KEY
```

This should create a `~/.ecs/credential` file that looks like\`:

```text
$ more ~/.ecs/credentials
version: v1
default: default
ecs_profiles:
  default:
    aws_access_key_id: **** your aws access key id ****
    aws_secret_access_key: **** your aws secret key key ****
```

To configure a cluster definition on your host:

> Note: The example below will configure a local cluster/config creating a future cluster in `us-east-2`. You should changes this to a region you would like to run in.

```text
ecs-cli configure \
        --cluster ping-devops-ecs-cluster \
        --default-launch-type FARGATE \
        --region us-east-2  \
        --config-name ping-devops-ecs-config
```

This should create a `~/.ecs/config` file that looks like\`:

```text
more ~/.ecs/config
version: v1
default: ping-devops-ecs-config
clusters:
  ping-devops-ecs-config:
    cluster: ping-devops-ecs-cluster
    region: us-east-2
    default_launch_type: FARGATE
```

### 2. Give your user access to CloudWatch Logs

> snippet from AWS \([https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html)\):
>
> #### Create the Task Execution IAM Role

Amazon ECS needs permissions so that your Fargate task can store logs in CloudWatch. These permissions are covered by the task execution IAM role. For more information, see Amazon ECS Task Execution IAM Role.

To create the task execution IAM role using the AWS CLI Create a file named `task-execution-assume-role.json` with the following contents:

```text
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

Create the task execution role:

```text
aws iam --region us-west-2 create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://task-execution-assume-role.json
```

Attach the task execution role policy:

```text
aws iam --region us-west-2 attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### 3. Create a cluster on ECS

We need to create an ECS cluster to host services and containers on. With `ecs-cli` you can create all related aspects of a cluster \(VPC, Subnets, Security-groups\) during cluster creation, or you can leverage existing resources. Examples for both are shown below: Option 1 [Create VPC, Subnets, and Security Groups](amazon.md#option-1). Option 2 [Use Existing Resources](amazon.md#option-2)

#### Option 1

**Create VPC, subnets, security-groups**

> Note: Your AWS ID/Role needs to have the authorization created within AWS to create a cluster \(`ecs:CreateCluster`\) to perform this step. If you have a role that is used within your `.aws/config` you may add the parameter `--aws-profile <profile-name>`

```text
ecs-cli up

### OUPTPUT ###
# INFO[0001] Created cluster                               cluster=ping-devops-ecs-cluster region=us-east-2
# INFO[0002] Waiting for your cluster resources to be created...
# INFO[0002] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
# INFO[0064] Cloudformation stack status                   stackStatus=CREATE_IN_PROGRESS
# VPC created: vpc-*********************
# Subnet created: subnet-*********************
# Subnet created: subnet-*********************
# Cluster creation succeeded.
###############
```

> Note: Capture the VPC and Subnet ID's to be used in future steps

**Creating a Security Group for the Cluster**

Now that we have brought a cluster up, you should create a security group to protect the VPC.

> Note: Again, your AWS ID/Role needs to have the authorization created within AWS to create a security group \(`CreateSecurityGroup`\) to perform this step. If you have a role that is used witnin your `.aws/config` you may add the parameter `--profile <profile-name>`

```text
aws ec2 create-security-group \
    --group-name "ping-devops-ecs-sg" \
    --description "Ping DevOps Security Group" \
    --vpc-id "<vpc-id-created-above>"

### OUPTPUT ###
# {
#     "GroupId": "sg-********************"
# }
```

and, in our example, we will add an 9999 and 9031 ingress point to access the PingFederate instance.

```text
aws ec2 authorize-security-group-ingress \
    --protocol tcp \
    --port 9031 \
    --port 9999 \
    --cidr 0.0.0.0/0 \
    --group-id "<sg-id-created-above>"
```

### Option 2

**Create Cluster with Existing Resources**

```text
ecs-cli up --vpc <vpc-id> --security-group <security-group-id> --subnets <required-subnet-1>,<required-subnet-2>
```

> Note: two subnets related to the VPC is required
>
> Ensure the typical PingFederate ports 9031 and 9999 are part of your security group if you wish to use them.

### 4. Work with PingFederate as service in an ECS Cluster

Use the following two files \(`docker-compose.yml`, `ecs-params.yml`\) as sampples to create in a directory.

> Be sure to update your specific information

Details on these files imputs can be found at:

* [Using Docker Compose File Syntax](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-parameters.html)
* [Using Amazon ECS Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-ecsparams.html)

Example PingFederate `docker-compose.yml`

```text
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

Example `ecs-params.yml`

```text
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
        - "subnet-<replace with subnet 1 from above>"
        - "subnet-<replace with subnet 2 from above>"
      security_groups:
        - "sg-<replace with security group id from above>"
      assign_public_ip: ENABLED
```

After creating these files, `cd` to that directory. Then:

#### To Start a Service

```text
ecs-cli compose --project-name pingfederate-devops \
    service up \
    --cluster ping-devops-ecs-cluster #\on first run add:
    #--create-log-groups
```

#### View Service Status

```text
ecs-cli compose --project-name pingfederate-devops service ps
```

#### To Bring Service Down

```text
ecs-cli compose service down
```

#### To Delete cluster

When you want to delete the cluster, you can do so with the command:

```text
ecs-cli down

### OUPTPUT ###
# INFO[0004] Waiting for your cluster resources to be deleted...
# INFO[0004] Cloudformation stack status                   stackStatus=DELETE_IN_PROGRESS
# INFO[0066] Deleted cluster                               cluster=ping-devops-ecs-cluster
###############
```

