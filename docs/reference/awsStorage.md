---
title: AWS Storage Considerations
---

# AWS Storage Considerations

AWS provides many storage options. When considering Ping products deployed in a containerized deployment, the choice typically comes down to two: elastic block storage (EBS) and elastic file system (EFS).  Though there are a number of differences between them, on the surface they act similar when attached to an Elastic Kubernetes Service (EKS) node or Elastic Compute Cloud (EC2) instance.

However, Ping products (whether containerized or not) require high I/O performance, and **Ping only recommends EBS volumes as the backing store**.  EFS performance is significantly lower and is not supported.

For additional product-specific requirements, visit the [appropriate product page](https://docs.pingidentity.com/).
