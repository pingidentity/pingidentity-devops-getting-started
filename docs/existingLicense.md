# Using an existing product license

If you have an existing, valid product license for the product or products you'll be running, you can use this instead of the DevOps evaluation license. 

Use either of these two methods to make an existing product license file available to your deployment:

* Copy each license file to the server profile location associated with the product. The default server profile locations are:
  - PingFederate: `instance/server/default/conf/pingfederate.lic`
  - PingAccess: `instance/conf/pingaccess.lic`
  - PingDirectory: `instance/pingdirectory.lic`
  - PingDataGovernance: `instance/pingdatagovernance.lic`
  - PingDataSync: `instance/pingdatasync.lic`
  - PingCentral: `instance/conf/pingcentral.lic`

* Use the instructions in [License declarations for stacks](#stacksLic) below to persist the license information in the local Docker volume that can be used for runtime startup information. See [Save your configuration changes](saveConfigs.md) for instructions in using local Docker volumes.

* Use the instructions in [License declarations for standalone containers](#standaloneLic) below when bringing up standalone containers.

<a name="stacksLic"></a>
## License declarations for stacks

For our Docker stacks, copy each license file to the `/opt/in` volume that you've mounted. The `/opt/in` directory overlays files onto the products runtime file system, the license needs to be named correctly and mounted in the exact location the product checks for valid licenses.

 1. Add a `volumes` section to the container entry for each product for which you have a license file in the `docker-compose.yaml` file you're using for the stack.
 2. Under the `volumes` section, add a location to mount `opt/in`. For example:

    ```yaml
    pingfederate:
    .
    .
    .
    volumes:
      - <path>/pingfederate.lic:/opt/in/instance/server/default/conf/pingfederate.lic
    ```

    Where \<path> is the location of your existing PingFederate license file.

    When the container starts, this will bind mount `<path>/pingfederate.lic` to this location in the container`/opt/in/instance/server/default/conf/pingfederate.lic`. The mount paths must match the expected license path for the product. These are:

    * PingFederate
      - Expected license file name: `pingfederate.lic`
      - Mount Path: `/opt/in/instance/server/default/conf/pingfederate.lic`

    * PingAccess
      - Expected license file name: `pingaccess.lic`
      - Mount Path: `opt/in/instnce/conf/pingaccess.lic`

    * PingDirectory
      - Expected License file name: `PingDirectory.lic`
      - Mount Path: `/opt/in/instance/PingDirectory.lic`

    * PingDataSync
      - Expected license file name: `PingDirectory.lic`
      - Mount Path: `/opt/in/instance/PingDirectory.lic`

    * PingDataGovernance
      - Expected license file name: `PingDataGovernance.lic`
      - Mount Path: `/opt/in/instance/PingDataGovernance.lic`

    * PingCentral
      - Expected license file name: `pingcentral.lic`
      - Mount Path: `/opt/in/instance/conf/pingcentral.lic`

 3. Repeat this process for the remaining container entries for which you have an existing license.

<a name="standaloneLic"></a>
## License declarations for standalone containers

For a standalone container, use this syntax to make the license file available to the deployment:

   ```bash
   docker run \
       --name pingfederate \
       --volume <path>/pingfederate.lic>:/opt/in/instance/server/default/conf/pingfederate.lic
       pingidentity/pingfederate:edge
   ```

   Where `<path>` and the `/opt/in` mount path are as specified for our Docker stacks above.

