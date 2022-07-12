---
title: pingctl pingone - Managing PingOne environments
---

# pingctl pingone

## Description

Provides ability to manage PingOne environments.  Capabilities of this command include:

* Listing, searching and retrieving PingOne resources (i.e. user, populations, groups)
* Adding PingOne resources
* Deleting PingOne resources

## Usage

    pingctl pingone get                  # Get PingOne resource(s)
    pingctl pingone add                  # Add PingOne resource
    pingctl pingone delete               # Delete PingOne resource

    pingctl pingone add-user-group       # Add group to user
    pingctl pingone delete-user-group    # Delete group from user

    pingctl pingone token                # Obtain access token

## Options

### All subcommands

    -r
        Provide REST Calls

### get

    -o [ table | csv | json ]
        Output format (default: table)
        also set with env variable: PINGCTL_DEFAULT_OUTPUT

    -i {id}
        Search based on object guid

    -n {name}
        Search based on exact filter

    -f {filter}
        PingOne filter (SCIM based)
            ex: '.name.given eq "john"'
                '.email sw "john"'

    -c {columns}
        Columns to output based on "heading:jsonAttr"
        An example of available jsonAttrs can be found by using a json output first.
            ex: 'LastName:name.family,FirstName:name.given'

    -s {sort column}
        Columns to sort output on based on "jsonAttr"
        The jsonAttr MUST be listed in the list of columns (-c option).
            ex: 'name.family'

    -p {population name}
        Population from which to retrieve a user/group
        If not provided, the 'Default' population is used

### add

    -p {population name}
        Population into which to add a user/group
        If not provided, the 'Default' population is used
