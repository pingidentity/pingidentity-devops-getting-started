# Amazon Elastic Container Service for Kubernetes (Amazon EKS)
This directory contains scripts and deployment files to help with the deployment, management and scaling of 
Ping Identity DevOps Docker Images to AWS using Kubernetes

## Getting started
We highly recommend you read the excellent
[EKS getting-started guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)

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


