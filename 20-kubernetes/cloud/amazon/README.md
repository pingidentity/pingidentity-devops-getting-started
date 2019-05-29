# Amazon Elastic Container Service for Kubernetes (Amazon EKS)
This directory contains scripts and deployment files to help with the deployment, management and scaling of 
Ping Identity DevOps Docker Containers to AWS using:

* Elastic Container Service for Kubernetes (EKS)
* Elastic Container Service (ECS)
  * Using Fargate Task
  * Using EC2 Task

## Getting started
We highly recommend you read the AWS articles on:
* [EKS getting-started guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
* [ECS getting-started with Fargate Task guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html)
* [ECS getting-started with EC2 Task guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-ec2.html)

# Steps for running Ping Identity DevOps Containers with EKS CLI

## Creating a cluster on EKS
The easiest way to create a cluster on Amazon EKS is with the `eksctl` CLI tool.  The
examples below assume you have first downloaded and installed:

* [AWS CLI](https://aws.amazon.com/cli/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [eksctl](https://eksctl.io)

Assuming you have setup your aws config/credientals using the `aws configure` command, an example 
of how to create a cluster looks like.  Note that depending on the AWS Region you are in, 
different versions (1.12 shown below) are available, along with the EKS service.

```
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

> Note: It may take several minutes to create the clusters as vpcs, security groups and 
ec2 instances will be created in this process.  You will note that it is ready when you see
the output:

`[✔]  EKS cluster "ping-devops-test" in "us-east-2" region is ready`

To see all the options when creating a cluster, simply run `eksctl create cluster -h`.

## Retrieving cluster information
Once created, some helpful commands to see the cluster details and nodegroup 
details using eksctl:

* `eksctl get cluster   --name=ping-devops-test`
* `eksctl get nodegroup --cluster=ping-devops-test`

And using `kubectl` you can get information on the nodes with:

* `kubectl get nodes`

## To Manually scale the cluster
In the above example, the cluster starts with 2 nodes.  If you wan to scale down/up, use
the command:

* `eksctl scale nodegroup --cluster=ping-devops-test --nodes=3 standard-workers`

## To Delete cluster
When you want to delete the cluster, you can do so with the command:

* `eksctl delete cluster --name=ping-devops-test`

# Steps for running Ping Identity DevOps Containers with ECS CLI

## Installing and Configuring ECS CLI
The easiest way to create a cluster on Amazon ECS is with the `ecs-cli` CLI tool.  The
examples below assume you have first downloaded and installed:

* [ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)

To configure the profile/credentials to `ecs-cli` on your host:

>Note: You will need to either set a variable for you personal AWS_ACCESS_KEY_ID and
AWS_SECRET_ACCESS_KEY values, or replace them in the command below.

```
ecs-cli configure profile \
        --access-key $AWS_ACCESS_KEY_ID \
        --secret-key $AWS_SECRET_ACCESS_KEY
```

This should create a `~/.ecs/credential` file that looks like`:

```
$ more ~/.ecs/credentials
version: v1
default: default
ecs_profiles:
  default:
    aws_access_key_id: **** your aws access key id ****
    aws_secret_access_key: **** your aws secret key key ****
```

To configure a cluster definition on your host:

>Note: The example below will configure a local cluster/config creating a future 
cluster in `us-east-2`.  You should changes this to a region you would like to run in.

```
ecs-cli configure \
        --cluster ping-devops-ecs-cluster \
        --default-launch-type FARGATE \
        --region us-east-2  \
        --config-name ping-devops-ecs-config
```

This should create a `~/.ecs/config` file that looks like`:

```
more ~/.ecs/config
version: v1
default: ping-devops-ecs-config
clusters:
  ping-devops-ecs-config:
    cluster: ping-devops-ecs-cluster
    region: us-east-2
    default_launch_type: FARGATE
```

## Creating a cluster on ECS
Now that we have created the credentials and config for a cluster, we can now bring
the cluster up.

>Note: Your AWS ID/Role needs to have the authorization created within AWS to create a 
cluster (`ecs:CreateCluster`) to perform this step.  If you have a role that is used
witnin your `.aws/config` you may add a parameters `--aws-profile <profile-name>`

```
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

>Note: Capture the VPC and Subnet ID's to be used in fute steps

## Creating a Security Group for the Cluster
Now that we have brought a cluster up, you should create a security group to protect the VPC.

>Note: Again, your AWS ID/Role needs to have the authorization created within AWS to create a 
security group (`CreateSecurityGroup`) to perform this step.  If you have a role that is used
witnin your `.aws/config` you may add a parameters `--profile <profile-name>`

```
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

```
aws ec2 authorize-security-group-ingress \
    --protocol tcp \
    --port 9031 \
    --port 9999 \
    --cidr 0.0.0.0/0 \
    --group-id "<sg-id-created-above>"
```

## Startup up PingFederate service in ECS Cluster
Now you can create a PingFederate service in an ECS Cluster using the example `docker-compose.yml` and
`ecs-params.yml` files below.

Details on these files imputs can be found at:

* [Using Docker Compose File Syntax](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-parameters.html)
* [Using Amazon ECS Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cmd-ecs-cli-compose-ecsparams.html)

Example PingFederate Docker Compose .yaml (docker-compose.yml)
```
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

Example ECS Params .yaml (ecs-params.yml)
```
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

Placing these into a directory named `ping-devops-ecs-service` and running the following command
in that directory will startup a PingFederate instance.  You will need to look at the task infomation
from an AWS Console to see the External IP to login to PingFederate.

```
ecs-cli compose service up \
    --create-log-groups \
    --cluster-config ping-devops-ecs-config
```

## To Bring Service Down

```
ecs-cli compose service down \
    --cluster-config ping-devops-ecs-config
```

## To Delete cluster
When you want to delete the cluster, you can do so with the command:

```
ecs-cli down

### OUPTPUT ###
# INFO[0004] Waiting for your cluster resources to be deleted...
# INFO[0004] Cloudformation stack status                   stackStatus=DELETE_IN_PROGRESS
# INFO[0066] Deleted cluster                               cluster=ping-devops-ecs-cluster
###############
```


