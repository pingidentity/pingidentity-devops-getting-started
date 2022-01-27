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

* product

    Name of the product.  This is generally a one word name based on the product name.
    For example: Ping Federate is `pingfederate`

* ver

    Version of the product.  This is a 2 level nuber of the version.  An actual version of
    `10.2.3` should always be `10.2`

    For example: Ping Federate version 10.2 should be `10.2`
