# Using Release Tags

Ping Identity uses multiple tags for each released build image. On our [Docker Hub](https://hub.docker.com/u/pingidentity) site, you can view the available tags for each image.

> All product containers in a stack should use the same release tag.

## Tagging Format

The format used to specify a release tag for stacks is:

```yaml
image: pingidentity/<ping-product>:${PING_IDENTITY_DEVOPS_TAG}
```

Where `<ping-product>` is the name of the product container and `${PING_IDENTITY_DEVOPS_TAG}` is assigned the release tag value. The reference to the file containing the setting for `${PING_IDENTITY_DEVOPS_TAG}` is `~/.pingidentity/devops` by default. You can also specify the release tag explicitly in the YAML file. The release tag must be the same for each container in the stack. For example:

```yaml
image: pingidentity/<ping-product>:edge
```

## Base Release Tags

The base release tags for a build are:

* edge
* latest
* sprint

### edge

The `edge` release tag refers to "bleeding edge", indicating a build similar to an alpha release. This _sliding_ tag includes the absolute latest hooks and scripts, but is considered highly unstable. The `edge` release is characterized by:

* Latest product version.
* Latest build image enhancements and fixes from our current sprint.
* Runs on the Linux Alpine OS.

For example, `pingaccess:edge`.

### latest

The `latest` release tag indicates the latest stable release. This is a _sliding_ tag that marks the stable release for the latest sprint. The `latest` release is characterized by:

* Latest product version
* All completed and qualified enhacements and fixes from the prior monthly sprint.
* Runs on the Linux Alpine OS.

For example, `pingfederate:latest`.

### sprint

The `sprint` release tag is a build number and indicates a stable build that is guaranteed to not change. The `sprint` number uses the YYMM format. For example, 1909 = September 2020.

* Latest product version at the time the sprint ended.
* All completed and qualified enhacements and fixes from the specified monthly sprint. The Docker images are generated at the end of the specified monthly sprint.
* Runs on the Linux Alpine OS.

For example, `pingfederate:1909`.

## Which Release Tag To Use

You should test all images in development before deploying to production. It's also best practice to use a _full tag_ variation like `pingaccess:5.3.0-alpine-edge`, rather than `pingaccess:edge` to avoid dependency conflicts in server profiles.  In general, we recommend:

* Use the `edge` release tag for demonstrations and testing latest features. `edge` is not suited for production use cases, because the underlying image is subject to change and backwards-compatibility is not guaranteed.

* Use the `sprint` release tag for development and production. The `sprint` tag is the _only_ tag that is guaranteed to not change and as such provides the most stability for repeatable deployment in development and production environments.

* Use the `latest` in those rare scenarios that require stability between product sprints, but can accept a sliding tag.

But what if you want bleeding edge features *and* a stable build image? For this, the best option is to periodically pull the Docker images having the base tag and store them in a local or private repository.

> Docker images produced before September 1, 2019 having a tag format of `:product-edge` or `:productVersion:edge` will not receive further updates.

## Determine Image Product Version

If you're unsure of the product version for the container you are running, shell into the container, then echo the $IMAGE_VERSION environment variable. For example:

```sh
docker container exec -it <container id> sh
echo $IMAGE_VERSION
```

The IMAGE_VERSION variable will return the version in this format: `[product]-[container OS]-[jdk]-[product version]-[build date]-[git revision]`. For example:

```shell
IMAGE_VERSION=pingcentral-alpine-az11-1.3.0-200629-bc33
```

Where:

| Key | Value |
|-----|-----|
| Product | pingcentral |
| Container OS | alpine |
| JDK | az11 |
| Product Version | 1.3.0 |
| Build Date | 200629* |
| Git Revision | bc33 |

> \* Date is in YYMMDD format
