---
title:  Using Release Tags
---
# Using Release Tags

Ping Identity uses multiple tags for each released build image. On our [Docker Hub](https://hub.docker.com/u/pingidentity) site, you can view the available tags for each image.

!!! info "Multi-product deployment"
    All product containers in a deployment should use the same release tag.

## Tagging Format

To specify a release tag for stacks, use the follow format:

```yaml
image: pingidentity/<ping-product>:${PING_IDENTITY_DEVOPS_TAG}
```

Where `<ping-product>` is the name of the product container and `${PING_IDENTITY_DEVOPS_TAG}` is assigned the release tag value. The reference to the file containing the setting for `${PING_IDENTITY_DEVOPS_TAG}` is `~/.pingidentity/devops` by default. You can also specify the release tag explicitly in the YAML file. The release tag must be the same for each container in the stack. For example:

```yaml
image: pingidentity/<ping-product>:edge
```

## Which Release Tag To Use

Which tag you should use depends on what you want to accomplish.

### Production Stability

For customers in production environments, stability is often the most sought after quality. For the least dependencies and the most stability:

* Use the [digest](https://docs.docker.com/engine/reference/commandline/images/#list-image-digests) of a _full sprint tag_ that includes the [sprint](#sprint) version and product version.
    * For example: `pingidentity/pingfederate:2103-10.2.2`. To pull its corresponding digest:

        ```sh
        docker pull pingidentity/pingfederate@sha256:cef3a089e941c837aa598739f385722157eae64510108e81b2064953df2e9537
        ```

    * Additionally, **do not** rely on Ping to maintain Docker images on Docker Hub. Instead pull the image of choice and maintain it in your own image registry. Common providers include: JFrog, AWS ECR, Google GCR, Azure ACR.

### Latest Image Features

For demonstrations and testing latest features, use an `edge` based image. Even for demos and testing, it's a good practice to use a _full tag_ variation like `pingfederate:10.2.2-edge`, rather than `pingfederate:edge`, to avoid dependency conflicts in server profiles.

### Evergreen Bleeding Edge

`edge` is the absolute latest product version and image features, with zero guarantees for stability.
Typically, this is only attractive to Ping employees or partners.

## Base Release Tags

The base release tags for a build are:

* edge
* latest
* sprint

### edge

The `edge` release tag refers to "bleeding edge", indicating a build similar to an alpha release. This _sliding_ tag includes the absolute latest hooks and scripts, but is considered highly unstable. The `edge` release is characterized by:

* Latest product version
* Latest build image enhancements and fixes from our current sprint
* Runs on the Linux Alpine OS

Example: `pingidentity/pingfederate:edge`, `pingidentity/pingfederate:10.2.2-edge`.

### latest

`edge `is tagged as `latest` at the beginning of each month. The release tag indicates the latest stable release. This is a _sliding_ tag that marks the stable release for the latest sprint. The `latest` release is characterized by:

* Latest product version
* All completed and qualified enhacements and fixes from the prior monthly sprint
* Runs on the Linux Alpine OS

Example: `pingfederate:latest`, `pingfederate:10.2.2-latest`

### sprint

In addition to becoming `latest`, `edge` also is tagged as a stable `sprint` each month.  The `sprint` release tag is a build number indicating a stable build that won't change. The `sprint` number uses the YYMM format. For example, 2201 = January 2022.  The `latest` release is characterized by:

* Latest product version at the time the sprint ended.
* All completed and qualified enhacements and fixes from the specified monthly sprint. The Docker images are generated at the end of the specified monthly sprint.
* Runs on the Linux Alpine OS.

Example: `pingfederate:2103`, `pingidentity/pingfederate:2103-10.2.2`

### sprint (point release)

Occasionally, a bug might be found on a stable release. To avoid changing a `sprint` tag, a point release would be pushed to move `latest` forward.

Example: `pingfederate:2103.1`, `pingidentity/pingfederate:2103.1-10.2.2`

## Determine Image Product Version

If you're unsure of the product version for the container you are running, shell into the container, then echo the $IMAGE_VERSION environment variable. For example:

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
IMAGE_VERSION=pingcentral-alpine-az11-1.3.0-200629-bc33
```

Where:

| Key | Value |
|-----|-----|
| Product | pingcentral |
| Container OS | alpine |
| JDK | az11 |
| Product Version | 1.3.0 |
| Build Date | 200629 |
| Git Revision | bc33 |

!!! note "Date Format"
    Date is in YYMMDD format
