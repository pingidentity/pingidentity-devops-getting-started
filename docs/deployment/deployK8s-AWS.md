---
title: Prepare AWS EKS for Multi-Region Deployments
---
# Preparing AWS EKS for Multi-Region Deployments

## Overview

In this guide you will deploy two Kubernetes clusters, each in a different Amazon Web Services (AWS) region. An AWS virtual private cloud (VPC) is assigned and dedicated to each cluster. You will also add communication between these clusters, using a transit gateway. Throughout this document, "VPC" is synonymous with "cluster".

## Prerequisites

Before you begin, you must have

* AWS account permissions to create clusters

## Create the multi-region clusters

1. Create VPCs.

    * Sign on to the AWS console and navigate to the **VPC** service.

    * Toggle to the `eu-west-1` region.

    * Select **Your VPCs** (under Virtual Private Cloud) and click **Create VPC**

    * Add a name tag, such as `demo-vpc-eu-west-1`

    * Add a IPv4 CIDR, such as `10.0.0.0/16`

    * Click **Create VPC**.

    > Make note of the `VpcId` and `IPv4 CIDR` values for the `eu-west-1` and `us-east-1` VPCs for use in subsequent steps.

    * Repeat this step in `us-east-1` region.

2.  Create the transit gateway for each region your deployment is being hosted on. Toggle to the `eu-west-1` region.

    * Navigate to the **Transit gateways** section and click **Create transit gateway**.

    * Add a name tag such as `demo-tgw-eu-west-1`.

    * Add a unique Amazon side Autonomous System Number for each region (ex. 64512 or 64513).

    * Disable both the `Default route table association` and `Default route table propagation`.
    
    > Make Note if you Enable the options above the default association route table and propagation route table will be created. This may not suit your more complex routing needs, so below you can see how to manually set the associations/propagation route tables.

    * Click **Create transit gateway**.

    * Repeat this step in `us-east-1` region.

3.  Create the transit gateway peering connection attachment. Toggle to the `eu-west-1` region.

    * Navigate to the **Transit gateway attachments** section and click **Create transit gateway attachments**.

    * Add a name tag such as `demo-peering-attachment-us-east-1`.

        > Make note that this name is refering to the region it is peering to, not the region it is being create in.

    * Select the Transit gateway id that you just made in the `eu-west-1` region.

    * Change **Attachment type** to `Peering Connection`.

    * For **Region** select `us-east-1`.

    * For **Transit gateway (accepter)** add the Transit gateway id that you just made in the `us-east-1` region.

    * Click **Create transit gateway attachment** .

4.  Accept transit gateway peering attachment.

    * Once the transit gateway peering connection shows `pending acceptance` as its **State**, toggle to the `us-east-1` region and select **Transit gateway attachments**.

    * You should see the attachment you just made. Select **Actions** and click accept.

    * Add a name to this attachment such as `demo-peering-attachment-eu-west-1`.

        > Make note that this name is refering to the region it is peering to, not the region it is being create in.

5. Attach VPCs to the transit gateways in each region. Toggle to the `eu-west-1` region.

    * Navigate to the **Transit gateway attachments** section and click **Create transit gateway attachments**.

    * Add a name tag such as `demo-vpc-eu-west-1`.

    * Select the Transit gateway id that you just made in the `eu-west-1` region.

    * Select the Vpc Id that you made note of in step 3 for the `eu-west-1` region.

    * Click **Create transit gateway attachment**.

    * Repeat this step in `us-east-1` region.

6.  Accept transit gateway VPC attachments. Toggle to the `eu-west-1` region.

    * Navigate to the **Transit gateway attachments** section and click **Create transit gateway attachments**.

    * You should see the vpc attachment you just made. Select **Actions** and click accept.

        > Note if you are using different accounts to create transit gateways and their attachments, then the name tag will  not be visable here. If thats the case you should add an attachment name now, such as `demo-vpc-eu-west-1`.

    * Repeat this step in `us-east-1` region.

7. Add routes to vpc route table. Toggle to the `eu-west-1` region.

    * Navigate to the **Route tables** section and select the route table for the Vpc Id you created.

    * Select **Routes** in the bottom third of the page.

    * Select **Edit routes** then click **Add route**.

    * Add a destination that is more broad than the local one that is present. For example if the local destination is `10.0.0.0/16` add `10.0.0.0/8`. 

    * For the **Target** select `Transit Gateway` and add then add the Transit gateway id that you created in this region.

    * Click **Save changes**.

    * Repeat this step in `us-east-1` region.

8. Configure the transit gateway route tables. Toggle to the `eu-west-1` region.
    
    * Navigate to the **Transit gateway route tables** section and click **Create transit gateway route table**.

    * Add a name tag such as `demo-eu-west-1-route-table`.

    * Select the Transit gateway id that you created in this region.

    * Click **Create transit gateway route table**.

    * Repeat this step in `us-east-1` region.

9. Associate the transit gateway. Toggle to the `eu-west-1` region.

    * Once the transit gateway route table has been successfully created, select that route table and click **Associations** then **Create association**.

    * Choose the VPC attachment for this region and click **Create association**.

10. Add static routes to the transit gateway. Toggle to the `eu-west-1` region.

    * Select that route table that you just created an association for and click **Routes** then **Create static route**.

    * Add the`IPv4 CIDR` for the remote VPC that you made note of in step 3 for the `us-east-1` region.

    * Select the transit gateway peering connection attachment.

    * Click **Create static route**.

    * Repeat this step in `us-east-1` region.

11. Create blackout static route to ensure the transit gateway drops any other network traffic. Toggle to the `eu-west-1` region.

    * Select **Create static route** 
    
    * Add 10.0.0.0/8 as thre CIDR

    * Select Blackhole

    * Click **Create static route**.

    * Repeat this step in `us-east-1` region.

At this point you should have a system of connected VPCs on the `us-east-1` `eu-west-1` regions. You can now deploy EC2 instances to these VPCs and communicate between them.