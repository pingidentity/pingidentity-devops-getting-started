---
title: DevOps Docker Builds, Version 2208 (September 01 2022)
---

# Version 2208 Release Notes

!!! note "Product release notes"
    For information about product changes, refer to the release notes that can be found on each product's [download page](https://www.pingidentity.com/en/resources/downloads.html).

## DevOps Docker Builds, Version 2208 (September 01 2022)

### New Product Releases
- PingAccess 7.1.1 and 7.0.5 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingaccess))
- PingFederate 11.0.4 ([Dockerhub](https://hub.docker.com/r/pingidentity/pingfederate))


### Resolved Defects
- (BRASS-346) Added documentation for setting the PingFederate provisioner node ID
- (BRASS-366) Added .default to any .subst files built into the image that did not have the extension. This prevents .subst files from overwriting the equivalent files when defined in a server profile.
- (BRASS-469) PingFederate Upgrade Documentation has been updated
- (BRASS-484) Fixed layered profile documentation page referring to a profile that no longer exists.
- (BRASS-516) Updated documentation with new recommended process for PingData certificate rotation

### Enhancements 
- Liberica JDK 11.0.16+8 -> 11.0.16.1+1
- Liberica JDK 17.0.4+8 -> 17.0.4.1+1
- Alpine 3.16.1 -> 3.16.2

### Supported Product Releases

This file shows the matrix of Ping Identity product software versions and the Ping Docker release tag in which they are available.  In accordance with our [image support policy](../docker-images/imageSupport.md), only images from the past 12 months are supported:

<object data="../../images/productVersionsAndImageTags.pdf" type="application/pdf" width="100%" height="1000px">
    <embed src="../../images/productVersionsAndImageTags.pdf">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="../../images/productVersionsAndImageTags.pdf">Download PDF</a>.</p>
    </embed>
</object>
