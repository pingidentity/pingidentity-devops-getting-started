---
title:  Using Release Tags
---

# Using Release Tags

Ping Identity uses multiple tags for each released image. On our [Docker Hub](https://hub.docker.com/u/pingidentity) site, you can view the available tags for each image.

!!! info "Multi-product deployment"
    All product containers in a deployment should use the same release tag.

## Store images privately

Before discussing tags, it is important to know more about Ping Identity's use of Docker Hub for images.  While Docker Hub is very reliable and you can always find the latest images of Ping Identity products hosted there, **do not** rely on Ping to maintain Docker images in Docker Hub over time. See the [image support policy](./imageSupport.md) for details. 

To ensure continued access to any image you need, pull the image in question and maintain it in your own image registry. Common Docker registry providers include: JFrog, AWS ECR, Google GCR and Azure ACR.

## Tagging Format

To specify a release tag for deployments, use the following format:

```yaml
image: pingidentity/<ping-product>:${PING_IDENTITY_DEVOPS_TAG}
```

In the example above, `<ping-product>` is the name of the product and `${PING_IDENTITY_DEVOPS_TAG}` is the assigned release tag value. The file containing the setting for `${PING_IDENTITY_DEVOPS_TAG}` is `~/.pingidentity/config` by default. This file is created by running the `pinctl config` command, documented [here](../tools/pingctlUtil.md). You can also specify the release tag explicitly in your deployments. The release tag must be the same for each container in the deployment. For example:

```yaml
image: pingidentity/<ping-product>:edge
```

## Determine Which Tag To Use

The tag to use depends on the purpose of the deployment in question.  Along with using a tag, any image on Docker Hub can be referenced using the [SHA256 digest](https://docs.docker.com/engine/reference/commandline/images/#list-image-digests) to ensure immutability in your environments.  The digest for a given image never changes regardless of any tag or tags with which it is associated.

### Production Stability

For customers in production environments, stability is often the highest priority. To ensure a deployment with the fewest dependencies and highest product stability:

* Use the digest of a _full sprint tag_ that includes the [sprint](#sprint) version and product version.  For example, consider the image tag `pingidentity/pingfederate:2206-11.1.0`. To pull this image using the corresponding digest:

    ```sh
    docker pull pingidentity/pingfederate@sha256:8eb88fc3345d8d71dafd83bcdcc38827ddb09768c6571c930b4d217ea177debf
    ```


### Latest Image Features

For demonstrations and testing latest features, use an `edge` based image. In these situations, it is a good practice to use a **_full tag_** variation similar to `pingfederate:11.1.0-edge`, rather than simply `pingfederate:edge`. Doing so avoids dependency conflicts that might occur in server profiles between product versions.

### Evergreen Bleeding Edge

The `edge` is the absolute latest product version and image features, with zero guarantees for stability.
Typically, this tag is only of interest to Ping employees and partners.

## Base Release Tags

The base release tags for a product image build are:

* edge
* latest
* sprint

### edge

The `edge` release tag refers to "bleeding edge", indicating a build similar to an alpha release. This _sliding_ tag includes the latest hooks and scripts, **and is considered highly unstable**. The `edge` release is characterized by:

* Latest product version
* Latest build image enhancements and fixes from our current sprint in progress
* Linux Alpine as the container base OS

Example: `pingidentity/pingfederate:edge`, `pingidentity/pingfederate:11.1.0-edge`

### latest

`edge `is tagged as `latest` at the beginning of each month. The release tag indicates the latest stable release. This tag is also a _sliding_ tag that marks the stable release for the latest sprint. The `latest` release is characterized by:

* Latest product version
* All completed and qualified enhacements and fixes from the prior monthly sprint
* Linux Alpine as the container base OS

Example: `pingfederate:latest`, `pingfederate:11.1.0-latest`

### sprint

In addition to becoming `latest`, `edge` also is tagged as a stable `sprint` each month.  The `sprint` release tag is a build number indicating a stable build that will not change over time. The `sprint` number uses the YYMM format. For example, 2208 = August 2022.  The `sprint` release is characterized by:

* Latest product version at the time the sprint ended.
* All completed and qualified enhancements and fixes from the specified monthly sprint. The Docker images are generated at the end of the sprint.
* Linux Alpine as the container base OS

Example: `pingfederate:2206`, `pingidentity/pingfederate:2206-11.1.0`

### sprint (point release)

Occasionally, a bug might be found on a stable release, whether in the product itself or something from the team building the image. In these situations, to avoid changing a `sprint` tag which is promised to be immutable, a point release would be created to move `latest` forward.  

!!! note "Example only"
    These example tags do not exist, they are used here only for illustration purposes.

Example: `pingfederate:2206.1`, `pingidentity/pingfederate:2206.1-11.1.0`

## Determine Image Version

If you are unsure of the exact version of the image used for a given product container, shell into the container and examine the $IMAGE_VERSION environment variable. For example, if you are running a container locally under Docker, you would run the following commands:

```sh
docker container exec -it <container id> sh
echo $IMAGE_VERSION
```

The IMAGE_VERSION variable returns the version in this format:

```sh
[product]-[container OS]-[jdk]-[product version]-[build date]-[git revision]
```

For example:

```sh
IMAGE_VERSION=pingdirectory-alpine_3.16.0-al11-9.1.0.0-220725-c917
```

Where:

| Key | Value |
|-----|-----|
| Product | pingdirectory |
| Container OS | alpine_3.16.0 |
| JDK | al11 |
| Product Version | 9.1.0.0 |
| Build Date | 220725 |
| Git Revision | c917 |

If the container is running under Kubernetes, use the [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec) command to access the container in order to obtain this information.

!!! note "Date Format"
    In the $IMAGE_VERSION variable, Date is in YYMMDD format
