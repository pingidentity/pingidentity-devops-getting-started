# Using an existing product license

If you have an existing, valid product license for the product or products you'll be running, you can use this instead of the DevOps evaluation license.

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.

* You've deployed an example stack. See [Deploy an example stack](getStartedWithGitRepo.md).

## What you'll do

Use either of these two methods to make an existing product license file available to your deployment:

* Copy each license file to the server profile location associated with the product. The default server profile locations are:
  - PingFederate: `instance/server/default/conf/pingfederate.lic`
  - PingAccess: `instance/conf/pingaccess.lic`
  - PingDirectory: `instance/pingdirectory.lic`
  - PingDataGovernance: `instance/pingdatagovernance.lic`
  - PingDataSync: `instance/pingdatasync.lic`
  - PingCentral: `instance/conf/pingcentral.lic`

* Use the instructions in any of these subtopics:

  - [License declarations for stacks](#license-declarations-for-stacks) to persist the license information in the local Docker volume that can be used for runtime startup information. See [Save your configuration changes](saveConfigs.md) for instructions in using local Docker volumes.

  - [License declarations for standalone containers](#license-declarations-for-standalone-containers) when bringing up standalone containers.

  - [Passing a license as a Kubernetes secret](#passing-a-license-as-a-kubernetes-secret) to use an existing license with Kubernetes.

## License declarations for stacks

For our Docker stacks, copy each license file to the `/opt/in` volume that you've mounted. The `/opt/in` directory overlays files onto the products runtime file system. The license needs to be named correctly and mounted in the exact location where the product checks for valid licenses.

 1. Add a `volumes` section to the container entry for each product for which you have a license file in the `docker-compose.yaml` file you're using for the stack.

 2. Under the `volumes` section, add a location to mount `opt/in`. An example using PingFederate:

    ```yaml
    pingfederate:
    .
    .
    .
    volumes:
      - <path>/pingfederate.lic:/opt/in/instance/server/default/conf/pingfederate.lic
    ```

    Where \<path> is the location of your existing PingFederate license file.

    When the container starts, this will mount `<path>/pingfederate.lic` to this location in the container`/opt/in/instance/server/default/conf/pingfederate.lic`.

    The mount paths must match the expected license path for the product. These mount paths are:

    * PingFederate
      - Expected license file name: `pingfederate.lic`
      - Mount path: `/opt/in/instance/server/default/conf/pingfederate.lic`

    * PingAccess
      - Expected license file name: `pingaccess.lic`
      - Mount path: `/opt/in/instance/conf/pingaccess.lic`

    * PingDirectory
      - Expected License file name: `PingDirectory.lic`
      - Mount path: `/opt/in/instance/PingDirectory.lic`

    * PingDataSync
      - Expected license file name: `PingDirectory.lic`
      - Mount path: `/opt/in/instance/PingDirectory.lic`

    * PingDataGovernance
      - Expected license file name: `PingDataGovernance.lic`
      - Mount path: `/opt/in/instance/PingDataGovernance.lic`

    * PingCentral
      - Expected license file name: `pingcentral.lic`
      - Mount path: `/opt/in/instance/conf/pingcentral.lic`

 3. Repeat this process for the remaining container entries for which you have an existing license.

## License declarations for standalone containers

For a standalone container, use this syntax to make the license file available to the deployment:

   ```bash
   docker run \
       --name pingfederate \
       --volume <path>/pingfederate.lic>:/opt/in/instance/server/default/conf/pingfederate.lic
       pingidentity/pingfederate:edge
   ```

   Where `<path>` and the `/opt/in` mount path are as specified for our Docker stacks above.

## Passing a license as a Kubernetes secret

We'll use PingFederate as an example. You'll need to supply your PingFederate license file.

The kustomize tool provides built-in generators for creating secrets. In this example, the secret will be generated using the `pingfederate.lic` file.

You'll find the YAML files for this example in your local `pingidentity-devops-getting-started/20-kubernetes/07-license-as-secret` directory.

### Prerequisites

* [kustomize](https://kustomize.io/)

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Procedure

1. Copy your PingFederate license file to your working directory.

2. Rename the file to `pingfederate.lic`.

3. Copy the YAML files from your local your local `pingidentity-devops-getting-started/20-kubernetes/07-license-as-secret` directory to your working directory.

4. In the `pingfederate.yaml` file, declare the volume to use for the license:

   ```yaml
   volumes:
     - name: <product-license-volume>
       secret:
         secretName: <pingfederate-license>
   ```

   Where \<product-license-volume> is the volume where it will be referenced from the container, and \<pingfederate-license> is your license information.

5. Add the following values in the `volumeMounts` section:

   ```yaml
   volumeMounts:
     - name: <product-license-volume>
       mountPath: "/opt/in/instance/server/default/conf/pingfederate.lic"
       subPath: pingfederate.lic
       readOnly: true
   ```

   Where:

     * `name` matches the `name` value you specified in the `volumes` section.

     * `mountPath` is the Docker bind-mount path used for the PingFederate license.

     * `subPath` is the name of the license file to be created.

     * `readOnly` is an optional attribute.

6. In the `kustomization.yaml` file, add your license information to the `secretGenerator` section:

   ```yaml
   secretGenerator:
   - files:
     - pingfederate.lic
       name: <pingfederate-license>
       type: Opaque
   ```

   The \<pingfederate-license> value must match the \<pingfederate-license> `secretName` value you specified in `pingfederate.yaml`.

7. Deploy your license. In your working directory, enter:

   ```bash
   kustomize build . | kubectl apply -f -
   ```

8. To clean up when you're finished, enter:

   ```bash
   kustomize build . | kubectl delete -f -
   ```
