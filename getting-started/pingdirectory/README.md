# Purpose
This repository serves as an example of how configuration can be stored and passed into a PingDirectory container for runtime customization based on a common image

## Top level
env_vars: environment variable

## dsconfig
configuration batches organized in the order in which they should be applied, bearing the .dsconfig extension
For example:
  - 01-first-batch.dsconfig
  - 02-second-batch.dsconfig

## data
LDIF files organized by back-end, bearing the .ldif extension.  The format that should be used for 
naming these files is:

   `NN-{back-end name}-{description}.ldif`

The default back-end for PingDirectory is named userRoot, so a good place to start would be for example:
 - **00-userRoot-dit.ldif** - Contains the entries used to create the skeleton Directory Information Tree (dit)
 - **10-userRoot-users.ldif** - Contains the user entries
 - **20-userRoot-groups.ldif** - Contains the group entries

## extensions
Server SDK extension files, bearing the .zip extension.
Extensions will be installed the first time the container start in no guaranteed order.

## hooks
In this diectory, you can place custom scripts that will be executed at specific times during the container startup sequence.

## instance
In this directory, you can place any file you would like, following the normal layout of the Ping Identity product that the server-profile is intended for.

For example, for PingDirectory:
  - to apply custom schema
    - instance/config/schema/77-microsoft.ldif
    - instance/config/schema/99-custom.ldif
  - to deploy your certificates
    - instance/config/keystore
    - instance/config/keystore.pin
    - instance/config/truststore
  - to deploy custom velocity templates and supporting files
    - instance/velocity/templates/single-page-app.vm
    - instance/velocitystatics/single-page-app.js
    - instance/velocity/statics/single-page-app.png

