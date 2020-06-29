# Using release tags

We use multiple tags for each released build image. On our Docker Hub site, you can view the available tags for each image:

* [PingAccess](https://hub.docker.com/r/pingidentity/pingaccess/tags)
* [PingDataGovernance](https://hub.docker.com/r/pingidentity/pingdatagovernance/tags)
* [PingDataSync](https://hub.docker.com/r/pingidentity/pingdatasync/tags)
* [PingDirectory](https://hub.docker.com/r/pingidentity/pingdirectory/tags)
* [PingFederate](https://hub.docker.com/r/pingidentity/pingfederate/tags)
* [Ping Data Console](https://hub.docker.com/r/pingidentity/pingdataconsole/tags)

> All product containers in a stack must use the same release tag.

## Tagging Format

The format used to specify a release tag for stacks is:
```yaml
image: pingidentity/<ping-product>:${PING_IDENTITY_DEVOPS_TAG}
```

Where `<ping-product>` is the name of the product container and `${PING_IDENTITY_DEVOPS_TAG}` is assigned the release tag value. The reference to the file containing the setting for `${PING_IDENTITY_DEVOPS_TAG}` is `~/.pingidentity/devops` by default. You can also specify the release tag explicitly in the YAML file. The release tag must be the same for each container in the stack. For example:
```yaml
image: pingidentity/<ping-product>:edge
```
## Base release tags

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

## Additional release tags

Each of the base release tags also has additional variations that you can use in combination, if you need other options:

* `{{productVersion}}`
* `{{operatingSystem}}`

### `{{productVersion}}`

The format is: `{{product}}:{{productVersion}}-{{baseTag}}`.

> The order of `{{productVersion}}-{{baseTag}}` is important and slightly different depending on the base tag.

Some examples:
```
pingaccess:5.3.0-edge
pingaccess:5.3.0-latest
pingaccess:1909-5.3.0
```

Each of these examples references a specific product version, and specific base release tag. When `{{operatingSystem}}` isn't specified, Alpine is used by default.

### `{{operatingSystem}}`

The format is: `{{product}}:{{operatingSystem}}-{{baseTag}}`.

> The order of `{{operatingSystem}}-{{baseTag}}` is important and slightly different depending on the base tag.

The available operating systems for a container are:

* Alpine: [openjdk:8-jre-alpine](https://hub.docker.com/_/openjdk)
* Ubuntu: [ubuntu:disco](https://hub.docker.com/_/ubuntu)
* Centos: [centos](https://hub.docker.com/_/centos)

Some examples:
```
pingaccess:alpine-edge
pingaccess:ubuntu-latest
pingfederate:1909-centos
```

Each of these tags references a specific operating system, and specific base release tag. When `{{productVersion}}` isn't specified, the latest available version is used.

### `{{productVersion}}`-`{{operatingSystem}}`

The format is: `{{product}}:{{productVersion}-{{operatingSystem}}-{{baseTag}}`.

> The order of `{{operatingSystem}}-{{baseTag}}` is important and slightly different depending on the base release tag.

Some examples:
```
pingaccess:5.3.0-alpine-edge
pingaccess:5.3.0-ubuntu-latest
pingfederate:1909-centos-5.3.0
```
Each of these tags reference a specific operating system, product version and base tag.

Another example:

`pingaccess:1908-alpine-5.3.0`

* `1908`: Version of our build image (YYMM format).
* `alpine`: Container operating system.
* `5.3.0`: PingAccess product version.

## Product Versions for edge and latest

The current product versions for **edge** and **latest** are

| Product | edge | latest |
|------|------|-----|
| PingFederate | 10.1.0 | 10.0.2 |
| PingDirectory | 8.1.0.0 | 8.0.0.1 |
| PingAccess | 6.1.0 | 6.0.2 |
| PingDataGov | 8.1.0.0 | 8.0.0.1 |
| PingDataGov PAP | 8.1.0.0 | 8.0.0.1 |
| PingDataSync | 8.1.0.0 | 8.0.0.1 |
| PingDataConsole | 8.1.0.0 | 8.0.0.1 |
| PingDirectoryProxy | 8.1.0.0 | 8.0.0.1 |
| PingCentral | 1.3.0 | 1.3.0 |

## Determine Product Version in Image

If you are unsure of the product version for the container you are running, shell into the container, then echo the IMAGE_VERSION environment variable.

Example

```sh
docker container exec -it <container id> sh
echo $IMAGE_VERSION
```

The IMAGE_VERSION variable will return
[product]-[container OS]-[jdk]-[**product version**]-[build date]-[git revision].

Sample Output
IMAGE_VERSION=pingcentral-alpine-az11-1.3.0-200629-bc33

| Key | Value |
|-----|-----|
| Product | pingcentral |
| Container OS | apline |
| JDK | az11 |
| Product Version | 1.3.0 |
| Build Date | 200629* |
| Git Revision | bc33 |

> \* Date is in YYMMDD format

## Which release tag to use

You should test all images in development before deploying to production. It's also best practice to use a _full tag_ variation like `pingaccess:5.3.0-alpine-edge`, rather than `pingaccess:edge` to avoid dependency conflicts in server profiles.  In general, we recommend:

* Use the `edge` release tag for demonstrations and testing latest features. `edge` is not suited for production use cases, because the underlying image is subject to change and backwards-compatibility is not guaranteed.

* Use the `sprint` release tag for development and production. The `sprint` tag is the _only_ tag that is guaranteed to not change and as such provides the most stability for repeatable deployment in development and production environments.

* Use the `latest` in those rare scenarios that require stability between product sprints, but can accept a sliding tag.

But what if you want bleeding edge features *and* a stable build image? For this, the best option is to periodically pull the Docker images having the base tag and store them in a local or private repository.

> Docker images produced before September 1, 2019 having a tag format of `:product-edge` or `:productVersion:edge` will not receive further updates.

