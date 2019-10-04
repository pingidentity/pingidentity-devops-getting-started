## Ping Identity Image Tagging

Ping Identity provides multiple tags for each released product image. Within Docker Hub, you can view the available tags for each image.

View Docker Image Tags here:
 * [PingAccess](https://hub.docker.com/r/pingidentity/pingaccess/tags)
 * [PingDataConsole](https://hub.docker.com/r/pingidentity/pingdataconsole/tags)
 * [PingDataGovernance](https://hub.docker.com/r/pingidentity/pingdatagovernance/tags)
 * [PingDataSync](https://hub.docker.com/r/pingidentity/pingdatasync/tags)
 * [PingDirectory](https://hub.docker.com/r/pingidentity/pingdirectory/tags)
 * [PingFederate](https://hub.docker.com/r/pingidentity/pingfederate/tags)

## Tagging Format

Ping Identity uses a number of standardized naming conventions

### product:ImageVersion-ContainerOS-ProductVersion

Eg. **pingaccess:1908-alpine-5.3.0**

* **1908**: Version of our underlaying Docker Image (YYMM)
* **alpine**: Container Operating System (Available OS: Alpine/CentOS/Ubuntu)
* **5.3.0**: PingAccess product version

### product:edge

Eg. **pingaccess:edge**

The **edge** tag includes the latest product version and the latest enhancements of our Docker Image running on the Alpine OS.

### product:ProductVersion-edge

Eg. **pingaccess:5.3.0-edge**

* **5.3.0**: PingAccess product version
* **edge**: Latest enhancements of our Docker Image

## When Selecting an Image Tag

* **Edge** tags are typically not suited for production use cases as the unlying product/image version is not locked in and is subject to change.
* **Image Digest** When an image is built, an immutable digest is attached to the build. Using the image digest ensures that your deployed versions will _not_ change when the tag is updated.
  * EG. pingfederate:9.3.1-alpine-edge has am image digest of sha256:1d797fdd0d0dcd57e6873c8b8e1f58da661c677940cbe18de818003bd2d345b6
  * The image digest version can be found either on Docker Hub or by running the command: `docker image inspect <image-id>`

* Use the image digest in your deployment YAML Eg.
   `from pingidentity/pingfederate@sha256:1d797fdd0d0dcd57e6873c8b8e1f58da661c677940cbe18de818003bd2d345b6`

> **NOTE**: Docker Images produced before Oct 1, 2019 that have a tag format of **:product-edge** or **:productVersion:edge** will not receive further updates.

## Container OS

Ping Identity makes available product images using the following container Operating Systems:

* Alpine: [openjdk:8-jre-alpine](https://hub.docker.com/_/openjdk)
* Ubuntu: [ubuntu:disco](https://hub.docker.com/_/ubuntu)
* Centos: [centos](https://hub.docker.com/_/centos)
