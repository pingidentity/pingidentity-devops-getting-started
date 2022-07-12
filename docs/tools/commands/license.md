---
title: pingctl license - Ping Identity license tool
---

# pingctl license

## Description

Provides access to Ping Identity evaluation license keys.

* Retrieve license based on product name and version

## Usage

    pingctl license {product} {ver}

## Options

* product: name of the product

    This name is generally a collapsed one-word representation of the product name.
    For example: Ping Federate is `pingfederate`

* ver: version of the product

    This value is the `major.minor` representation of the version of the product in question.  For example, if a product had a point release of `10.2.3` you would provide `10.2`
