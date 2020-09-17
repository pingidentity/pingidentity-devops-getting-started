# Kubernetes Multi Region Clustering using Native S3 Ping

## Advanced Use-Case

>Note: the extensive set of pre-requisites required for AWS kubernetes multi-clustering to be successful

## Overview diagram

![PingFederate AWS MultiRegion Deployment Diagram](images/pf_aws_overview_diagram.png)

## What you will do

You will deploy a multi-region adaptive Pingfederate cluster across multiple AWS EKS regional clusters.
The `kustomization.yaml` in the 'engines' and 'admin-console' directories build on top of the standard DevOps PingFederate deployments.
From each of these directories, running `kustomize build .`
will generate kubernetes yaml files that include:

1. Two deployments:
    - `pingfederate-admin` represents the admin console.
    - `pingfederate` represents the engine(s)

1. Two Configmaps. One for each deployment.
    - These configmaps are nearly identical, but define the operational mode separately.

1. The configmaps include a [profile layer](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pf-k8s-multi-clustering-native-s3-ping) that turns on PingFederate Clustering. This layer simply includes:
    - tcp.xml.subst
    - run.properties.subst
    - cluster-adaptive.conf.subst

1. Two Services:
    - One for each of the two deployments (9999 and 9031).

## PingFederate Engine Lifecycle

Some features are added to the PingFederate Engine Deployment to support zero-downtime configuration deployments. explanations for these features are stored as comments in `pingfederate-engine.yaml`.

## Pre-reqs

- Two EKS clusters created with the following requirements:
  - VPC IPs selected from RFC1918 CIDR blocks
  - The two cluster VPCs peered together
  - All appropriate routing tables modified in both clusters to send cross cluster traffic to the VPC peer connection
  - Security groups on both clusters to allow traffic for ports 7600 and 7700 to pass
  - Create an S3 bucket with all appropriate security permissions
    - Non-public
    - Well scoped security policy, giving permissions to the service accounts running the EKS pingfederate clusters
    - Encrypted
  - See example "AWS configuration" instructions [Here](pfMultiRegionAWSPrereq.md)
  - Successfully verified that a pod in one cluster can connect to a pod in the second cluster on ports 7600 and 7700 (directly to the pods back-end IP, not an exposed service)

## Running

Clone this repository to get the kubernetes yaml and configuration files for the exercise, then:

1. Bring up the admin console in the first kubernetes cluster:

   ```bash
   cd admin-console
   ```

   - Modify the 'env_vars.pingfederate-admin' file to include the name of the AWS S3 bucket, and the region of the S3 bucket to be used for the cluster list, as well as the appropriate region for adaptive clustering (PF_NODE_GROUP_ID)

   ```bash
   kustomize build . | kubectl apply -f -
   ```

1. Wait for the pingfederate-admin pod to be running, then validate you can log into the console. You can port-forward the admin service and look at clustering via the admin console.

   ```bash
   kubectl port-forward svc/pingfederate 9999:9999
   ```

1. Bring up one engine in the first kubernetes cluster:

   ```bash
   cd ../engines
   ```

   - Modify the 'env_vars.pingfederate-engine' file to include the name of the AWS S3 bucket, and the region of the S3 bucket to be used for the cluster list, as well as the appropriate region for   adaptive clustering (PF_NODE_GROUP_ID)

   ```bash
   kustomize build . | kubectl apply -f -
   ```

   - You can watch the admin console to make sure the engine appears in the cluster list.   It would also be wise at this point to check the contents of the S3 bucket and make sure that both the IPs for the admin console and the engine node have been successfully written in.

1. Scale up more engines in the first kubernetes cluster:

   ```bash
      kubectl scale deployment pingfederate --replicas=2
   ```

   - Again, validate that any new engines have successfully joined the cluster and written their IP to the S3 bucket

1. Scale up engines in the 2nd kubernetes cluster:
   - Use kubectx to switch context to the 2nd kubernetes cluster
   - Modify the env_vars.pingfederate-engine file to include the second region for adaptive clustering
     (PF_NODE_GROUP_ID)

   ```bash
   kustomize build . | kubectl apply -f -
   kubectl scale deployment pingfederate --replicas=2
   ```

   - Again, validate that any new engines have successfully joined the cluster and written their IP to the S3 bucket

## Cleanup the second cluster containing only engines

```bash
kubectl scale deployment/pingfederate --replicas=0
cd engines
kustomize build . | kubectl delete -f -
```

## Cleanup the first cluster containing engines and admin console

```bash
kubectx <first cluster>
kubectl scale deployment/pingfederate --replicas=0
kubectl scale deployment/pingfederate-admin --replicas=0
kustomize build . | kubectl delete -f -
cd ../admin-console
kustomize build . | kubectl delete -f -
```
