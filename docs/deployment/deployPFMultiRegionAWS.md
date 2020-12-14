# Kubernetes Multi Region Clustering using Native S3 Ping

This document is specific to dynamic discovery with  NATIVE_S3_PING and is an extension of [PingFederate Cluster Across Multiple Kubernetes Clusters](./deployK8sPFclusters.md). This is the validated approach for PingFederate < 10.2

![PingFederate AWS MultiRegion Deployment Diagram](../images/pf_aws_overview_diagram.png)

## AWS S3 Prerequisites

* Create an S3 bucket with all appropriate security permissions
      * Non-public
      * Well scoped security policy, giving permissions to the service accounts running the EKS PingFederate clusters
      * Encrypted

### Create an S3 bucket

1. In the AWS console, select the **S3** service.

1. Select **Buckets**, and click **Create Bucket**.

1. Enter a name for the bucket, select a region, and click **Next**.

1. Enable the `encrypt objects` option, and any other options you need. Click **Next**.

1. Select **Block All Public Access**, and click **Next**.

1. Click **Create Bucket**.

1. Select the bucket you just created from the displayed list. A window will open. Click **Copy Bucker ARN**, and retain this information for your security policy.

1. Click on your bucket to open it, and click **Permissions** --> **Bucket Policy**.

1. Use either the policy generator, or manually assign a security policy for the bucket that assigns the cluster user accounts these permissions:

    * GetBucketLocation

    * ListBucket

    * DeleteObject /*

    * GetObject /*

    * PutObject /*

    !!! note ""
        The resource for GetBucketLocation and ListBucket is slightly different than the object permissions.  The resource for GetBucketLocation and ListBucket is just the bucket ARN, but for the 3 object permissions, you must add “/*” on the end.

## What You'll Do

You will deploy a multi-region adaptive Pingfederate cluster across multiple AWS EKS regional clusters.
The `kustomization.yaml` in the 'engines' and 'admin-console' directories build on top of the standard DevOps PingFederate deployments.

From each of these directories, running `kustomize build .`
will generate Kubernetes yaml files that include:

1. Two deployments:
    * `pingfederate-admin` represents the admin console.
    * `pingfederate` represents the engine(s)

1. Two Configmaps. One for each deployment.
    * These configmaps are nearly identical, but define the operational mode separately.

1. The configmaps include a [profile layer](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pf-k8s-multi-clustering-native-s3-ping) that turns on PingFederate Clustering. This layer simply includes:
    * tcp.xml.subst
    * run.properties.subst
    * cluster-adaptive.conf.subst

1. Two Services:
    * One for each of the two deployments (9999 and 9031).

## PingFederate Engine Lifecycle

Some features are added to the PingFederate Engine Deployment to support zero-downtime configuration deployments. explanations for these features are stored as comments in `pingfederate-engine.yaml`.

## Running

Clone this repository to get the Kubernetes yaml and configuration files for the exercise, then:

1. Bring up the admin console in the first Kubernetes cluster:

      ```sh
      cd admin-console
      ```

      * Modify the 'env_vars.pingfederate-admin' file to include the name of the AWS S3 bucket, and the region of the S3 bucket to be used for the cluster list, as well as the appropriate region for adaptive clustering (PF_NODE_GROUP_ID)

      ```sh
      kustomize build . | kubectl apply -f -
      ```

1. Wait for the pingfederate-admin pod to be running, then validate you can log into the console. You can port-forward the admin service and look at clustering via the admin console.

      ```sh
      kubectl port-forward svc/pingfederate 9999:9999
      ```

1. Bring up one engine in the first Kubernetes cluster:

      ```sh
      cd ../engines
      ```

      * Modify the 'env_vars.pingfederate-engine' file to include the name of the AWS S3 bucket, and the region of the S3 bucket to be used for the cluster list, as well as the appropriate region for   adaptive clustering (PF_NODE_GROUP_ID)

      ```sh
      kustomize build . | kubectl apply -f -
      ```

      * You can watch the admin console to make sure the engine appears in the cluster list.   It would also be wise at this point to check the contents of the S3 bucket and make sure that both the IPs for the admin console and the engine node have been successfully written in.

1. Scale up more engines in the first Kubernetes cluster:

      ```sh
      kubectl scale deployment pingfederate --replicas=2
      ```

      * Again, validate that any new engines have successfully joined the cluster and written their IP to the S3 bucket

1. Scale up engines in the 2nd Kubernetes cluster:
      * Use kubectx to switch context to the 2nd Kubernetes cluster
      * Modify the env_vars.pingfederate-engine file to include the second region for adaptive clustering
     (PF_NODE_GROUP_ID)

      ```sh
      kustomize build . | kubectl apply -f -
      kubectl scale deployment pingfederate --replicas=2
      ```

      * Again, validate that any new engines have successfully joined the cluster and written their IP to the S3 bucket

## Cleanup Second Cluster (Engines Only)

```sh
kubectl scale deployment/pingfederate --replicas=0
cd engines
kustomize build . | kubectl delete -f -
```

## Cleanup First Cluster (Engines & Admin)

```sh
kubectx <first cluster>
kubectl scale deployment/pingfederate --replicas=0
kubectl scale deployment/pingfederate-admin --replicas=0
kustomize build . | kubectl delete -f -
cd ../admin-console
kustomize build . | kubectl delete -f -
```
