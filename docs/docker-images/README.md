# Ping Identity Docker Images
Find documentation regarding basic image usage, environment variables, and profile variables for all products here. 

- [Ping Identity Image Tags](#ping-identity-image-tags)
- [Tagging Format](#tagging-format)
- [Which Tag Should I Use](#which-tag-should-i-use)

## Ping Identity Image Tags

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
### Base Tags:

#### edge

Eg. `pingaccess:edge`
</br> "Bleeding edge" - similar to an alpha release. This _sliding_ tag includes the absolute latest hooks and scripts, but is considered highly unstable. 
</br>The `edge` tag includes:

* Latest product version
* Latest Docker Image enhancements/fixes from our current sprint
* Running on Alpine OS.

#### latest

Eg. `pingfederate:latest`
</br>The "latest" stable release - This is a _sliding_ tag that marks the latest sprint. 

The `latest` tag includes:

* The latest product version
* Docker Image: All completed and qualified enhacements/fixes from our previous monthly sprint
* Running on Alpine OS.

#### sprint

Eg. `pingfederate:1909`
"Golden Tag" - This tag marks a stable build that is guaranteed to not change. `sprint` name comes from YYMM. 1909 = September 2019.

The `sprint` tag includes:

* The latest product version at the time of sprint 
* Docker Image: All completed and qualified enhacements/fixes from the monthly sprint
* Running on Alpine OS.

### Additional Tags: 
Each of the tags above has additional variations to provide flexibility for your use case. 

These variations include adding `{{productVersion}}`, `{{operatingSystem}}`, or a combination. 

#### {{product}}:{{productVersion}}-{{baseTag}}
> NOTE: order of {{productVersion}}-{{baseTag}} is important and slightly different depending on the base tag. 

Examples: 
```
pingaccess:5.3.0-edge
pingaccess:5.3.0-latest
pingaccess:1909-5.3.0
```
Each of these tags reference a specific product version, and specific [base tag](#base-tags). Without specifying the OS, alpine is used. 

ProductVersion-edge tags use Alpine for the container OS.

#### {{product}}:{{os}}-{{baseTag}}
> NOTE: order of {{os}}-{{baseTag}} is important and slightly different depending on the base tag. 
Examples:
```
pingaccess:alpine-edge
pingaccess:ubuntu-latest
pingfederate:1909-centos
```
Each of these tags reference a specific operating system, and specific [base tag](#base-tags). Without specifying the product version, the latest available is used. 

#### {{product}}:{{productVersion}-{{os}}-{{baseTag}}
> NOTE: order of {{os}}-{{baseTag}} is important and slightly different depending on the base tag. 
Examples:
```
pingaccess:5.3.0-alpine-edge
pingaccess:5.3.0-ubuntu-latest
pingfederate:1909-centos-5.3.0
```
Each of these tags reference a specific operating system, product version and [base tag](#base-tags). 

Eg. `pingaccess:1908-alpine-5.3.0`

* `1908`: Version of our underlaying Docker Image (YYMM)
* `alpine`: Container Operating System (Available OS: Alpine/CentOS/Ubuntu)
* `5.3.0`: PingAccess product version

## Which Tag to Use

All images should be tested in development before deploying to production. It is also best practice to use a _full tag_ variation like `pingaccess:5.3.0-alpine-edge` over `pingaccess:edge` to avoid dependency conflicts in profiles.  Beyond this consideration, the general recommendation is:

-  Use the `edge` [base tag](#base-tags) for demos and testing latest features. `edge` is not suited for production use cases as the underlying image is subject to change and backwards-compatibility is not guaranteed. 

- Use the `sprint` [base tag](#base-tags) for development and production. The `sprint` tag is the _ONLY_ tag that is guaranteed to not change and as such provides the most stability for repeatable deployment in development and  production environments.

- The `latest` [base tag](#base-tags) may be used in rare scenarios that require stability between sprints, but can accept a sliding tag.

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
