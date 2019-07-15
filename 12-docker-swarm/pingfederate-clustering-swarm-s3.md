# PingFederate Clustering using Docker Swarm & AWS S3

In this walkthrough example, we’ll cover how to stand up a PingFederate cluster containing an Administration Console and multiple engines nodes using Docker Swarm and an AWS S3 bucket for node discovery.

For this exercise, please reference the `pingfederate_clustering_with_S3_discovery.yaml` file located within the 12-docker-swarm directory.

## AWS S3 Bucket Creation and Permissions

1. Log into your AWS console and navigate to the S3 service
1. Click the `+ Create bucket` button
1. Give your bucket a name and select a region
1. Click `Next`
1. For this example, we’ll skip the `Configure options` screen and go straight to `Set Permissions`
1. Select the option to `Block all public access`. In a upcoming step, we’ll create an API key and secret to access the bucket.
1. Click `Next`
1. On the `Review` screen, click `Create Bucket`

## Create AWS User

1. Navigate to the `IAM service` within AWS
1. Click the `Create individual IAM users` dropdown, the `Manage Users`
1. Click the `Add User` button
1. Give your user a name, then select `Programmatic access` for the `Access type`
1. Click `Next: Permissions`
1. Click the `Attach existing policies directly` tab, the filter by `AmazonS3FullAccess`
1. Select the `AmazonS3FullAccess` policy from the list
1. Click `Next: Tags`
1. Click `Next: Review`
1. Review the user details, then click `Create User`
1. Once the user is created, you should see the `Access Key ID` and have access to view the secret. Note: as you cannot retrieve the secret later, it is a good idea to download the .csv provided*
1. Keep the key and secret as they will be needed in future steps

## Configuring the YAML deployment file

1. Open the `pingfederate_clustering_with_S3_discovery.yaml` file in the editor of your choice
1. Notice that the PingFederate services each use two server profiles. This layering approach allows you to build up their profile to avoid building from scratch for each use case.
1. For this example, the `baseline server profile` acts as the foundation and `pf-aws-s3-clustering/pingfederate` for the top layer.
1. This layer contains only the `tcp.xml.subst` file that is used to configure clustering
1. In your browser, navigate to the [server profile](https://github.com/pingidentity/pingidentity-server-profiles/blob/master/pf-aws-s3-clustering/pingfederate/instance/server/default/conf/tcp.xml.subst)
1. Scroll down to approx line 45
![Cluster Management Console](../docs/images/TCP_XML_S3_CLUSTER_VARS.png)
1. Notice the 3 variables for location (S3 bucket name), key and secret
1. Back in your text editor scroll down and update the values for `DISCOVERY_S3_LOCATION`, `DISCOVERY_S3_ACCESS_KEY`, and `DISCOVERY_S3_SECRET_KEY` with the values from the above section steps
1. Remember to enter your values in both PingFederate service (Admin and Engine) sections.
1. Save the yaml file

## Launch PingFederate Cluster

1. In your terminal, navigate to the `12-docker-swarm` folder
1. Start the swarm services `$ docker service init`
1. Deploy the yaml file `$ ./swarm-start.sh pingfederate_clustering_with_S3_discovery.yaml`
1. Once all services have launched, open your browser and navigate to `https://localhost:9999/pingfederate/app`
1. Click on `System->Cluster Management`
1. You should now see that your Engine node has attached to the Admin Console

 ![Cluster Management Console](../docs/images/PF_CLUSTER_CONSOLE.png)

## Scaling Out

1. Back in your terminal
1. View the running services `$ docker service list`
1. Run the following command to scale the number of Engine nodes to 2 `$ docker service scale pingfederate_clustering_with_S3_discovery_pingfederate=2`
1. After a minute or two, refresh your PingFederate browser window
1. The second Engine is now attached
