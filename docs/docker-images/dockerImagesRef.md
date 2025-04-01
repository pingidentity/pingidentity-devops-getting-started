---
title: Container Docker Images Information
---
# Image Information

These documents for Ping Identity Docker images include information on:

* Related Docker images
* Ports exposed for the containers
* Environment variables for the image
* Associated deployment information
* Tagging methodology and support policy

The image-specific documentation is generated from each new build ensuring these documents align with any changes over time.

!!! warning "Storage Considerations on AWS"
    When deploying Ping products in containers, please consider the information found [here on storage options](../reference/awsStorage.md).

Older images based on product versions that are no longer supported under our policy are removed from Docker Hub.  See the [support policy page](./imageSupport.md) for details.

As with many organizations, Ping Identity uses _floating_ Docker image tags. This practice means, for example, that the **`edge`** tag does not refer to the same image over time as product updates occur. The [release tags](./releaseTags.md) page has information on the `edge` and other tags, how often they are updated, and how to ensure the use of a particular version and release of a product image.

!!! note "Notification of new image tags"
    If you want to be notified when new versions of product Docker images are available, see the **Docker Images** section of the [FAQ page](../reference/faqs.md) for instructions on following the docker-builds GitHub repository.

!!! note "Iron Bank Images"
    For FedRAMP certification and other United States government compliance, Ping Identity has partnered with UberEther to build and host highly-secured images at Iron Bank that are compliant with the increased security requirements.  More information is provided in the [FAQ](../reference/faqs.md) section of this documentation.  The Iron Bank images are available on the [Iron Bank](https://docs-ironbank.dso.mil/) repository and are not provided on Docker Hub.
