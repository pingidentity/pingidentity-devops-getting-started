
# Ping Identity DevOps `pingcommon` Hook - `05-expand-templates.sh`
Using the envsubst command, this will look through any files that end in 
`subst` and substitute any variables the files with the the value of those
variables.

Variables may come from (in order of precedence):
 - The 'env_vars' file from the profiles
 - The environment variables or env-file passed to continaer on startup
 - The container's os

>Note: If a string of $name is sould be ignored during a substitution, then 
A special vabiable ${_DOLLAR_} should be used.

>Example: ${_DOLLAR_}{username} ==> ${username}

If a .zip file ends with `.zip.subst` then:
- file will be unzipped 
- any files ending in `.subst` will be processed to substiture variables
- zipped back up in to the same file without the `.subst` suffix
This is especially useful for pingfederate for example with data.zip


---
This document auto-generated from _[pingcommon/hooks/05-expand-templates.sh](https://github.com/pingidentity/pingidentity-docker-builds/blob/master/pingcommon/hooks/05-expand-templates.sh)_

Copyright (c)  2019 Ping Identity Corporation. All rights reserved.
