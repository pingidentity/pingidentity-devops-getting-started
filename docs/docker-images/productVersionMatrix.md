---
title:  Product Version, Image Release Matrix
---
# Product Version, Image Release Matrix

It is recommended that you use the most recent Docker release tag available for the product version you want to run.

The tag used to pull the image is in the format `{RELEASE}-{PRODUCT VERSION}`

Examples:

* PingFederate 10.2.5
    * pingidentity/pingfederate:`2108-10.2.5`
* PingDirectory 8.2.0.1
    * pingidentity/pingdirectory:`2101-8.2.0.1`

This file shows the matrix of Ping Identity product software versions and the Ping Docker release tag in which they are available.  In accordance with our [image support policy](../docker-images/imageSupport.md), only images from the past 12 months are supported:

<object data="../../images/productVersionsAndImageTags.pdf" type="application/pdf" width="100%" height="1000px">
    <embed src="../../images/productVersionsAndImageTags.pdf">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="../../images/productVersionsAndImageTags.pdf">Download PDF</a>.</p>
    </embed>
</object>
