# Ping Identity Image Tagging

Ping Identity provides multiple tags for each released product image. Within Docker Hub, you can view the available tags for each image.

View Docker Image Tags here:
 * [PingAccess](https://hub.docker.com/r/pingidentity/pingaccess/tags)
 * [PingDataConsole](https://hub.docker.com/r/pingidentity/pingdataconsole/tags)
 * [PingDataGovernance](https://hub.docker.com/r/pingidentity/pingdatagovernance/tags)
 * [PingDataSync](https://hub.docker.com/r/pingidentity/pingdatasync/tags)
 * [PingDirectory](https://hub.docker.com/r/pingidentity/pingdirectory/tags)
 * [PingFederate](https://hub.docker.com/r/pingidentity/pingfederate/tags)

## Tagging Format

Ping Identity uses a number of standardized naming conventions.

### product:edge

Eg. **pingaccess:edge**

The **edge** tag includes:

* Latest product version
* Docker Image enhancements/fixes from our current sprint
* Running on Alpine OS.

### product:latest

Eg. **pingfederate:latest**

The **latest** tag includes:

* The latest product version
* Docker Image: All completed and qualified enhacements/fixes from our previous monthly sprint
* Running on Alpine OS.

### product:ProductVersion-edge

Eg. **pingaccess:5.3.0-edge**

ProductVersion-edge tags use Alpine for the container OS.

* **5.3.0**: PingAccess product version
* **edge**: Docker Image enhancements/fixes from our current sprint

### product:ImageVersion-ContainerOS-ProductVersion

Eg. **pingaccess:1908-alpine-5.3.0**

* **1908**: Version of our underlaying Docker Image (YYMM)
* **alpine**: Container Operating System (Available OS: Alpine/CentOS/Ubuntu)
* **5.3.0**: PingAccess product version

## When Selecting an Image Tag

* **Edge** tags are typically not suited for production use cases as the unlying product/image version is not locked in and is subject to change. As enhancements are made to the base image, backwards-compatibility is not guaranteed.
* **Image Digest** When an image is built, an immutable digest is attached to the build. Using the image digest ensures that your deployed versions will _not_ change when the tag is updated.
  * EG. pingfederate:9.3.1-alpine-edge has am image digest of sha256:1d797fdd0d0dcd57e6873c8b8e1f58da661c677940cbe18de818003bd2d345b6
  * The image digest version can be found either on Docker Hub or by running the command: `docker image inspect <image-id>`

* Use the image digest in your deployment YAML Eg.
   `pingidentity/pingfederate@sha256:1d797fdd0d0dcd57e6873c8b8e1f58da661c677940cbe18de818003bd2d345b6`

## Docker Image Versioning

* Versions follow a YYMM format
  * Eg. 1909 is the build for September 2019
* Build is reflective of the sprint work completed for that month
* Build is generated at the end of the sprint/month
  * Eg. 1909 - is built at the end of September, made available first week of October

> **NOTE**: Docker Images produced before September 1, 2019 having a tag format of **:product-edge** or **:productVersion:edge** will not receive further updates.

## Container OS

Ping Identity makes available product images using the following container Operating Systems:

* Alpine: [openjdk:8-jre-alpine](https://hub.docker.com/_/openjdk)
* Ubuntu: [ubuntu:disco](https://hub.docker.com/_/ubuntu)
* Centos: [centos](https://hub.docker.com/_/centos)
