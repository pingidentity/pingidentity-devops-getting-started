# Using Existing Product License

If you have an existing, valid product license for the product or products you'll be running, you can use this instead of the DevOps evaluation license.

## Prerequisites

* You've already been through [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* You've deployed an example stack. See [Deploy an Example Stack](../get-started/getStartedWithGitRepo.md).

## What You'll Do

Use the instructions in any of these subtopics:

* [License Declarations For Stacks](#license-declarations-for-stacks) to persist the license information in the local Docker volume that can be used for runtime startup information. See [Save Your Configuration Changes](../how-to/saveConfigs.md) for instructions in using local Docker volumes.
* [License Declarations For Standalone Containers](#license-declarations-for-standalone-containers) when bringing up standalone containers.
* [Passing a License as a Kubernetes Secret](#passing-a-license-as-a-kubernetes-secret) to use an existing license with Kubernetes.

## License Declarations For Standalone Containers

For a standalone container, use this syntax to make the license file available to the deployment:

  ```sh
  docker run \
    --name pingfederate \
    --volume <path>/pingfederate.lic>:/opt/in/instance/server/default/conf/pingfederate.lic \
  pingidentity/pingfederate:edge
  ```

   Where `<path>` and the `/opt/in` mount path are as specified for our Docker stacks above.

## License Declarations For Stacks

For our Docker stacks, copy each license file to the `/opt/in` volume that you've mounted. The `/opt/in` directory overlays files onto the products runtime file system. The license needs to be named correctly and mounted in the exact location where the product checks for valid licenses.

 1. Add a `volumes` section to the container entry for each product for which you have a license file in the `docker-compose.yaml` file you're using for the stack.

 1. Under the `volumes` section, add a location to mount `opt/in`. An example using PingFederate:

    ```yaml
    pingfederate:
    ...
    volumes:
      - <path>/pingfederate.lic:/opt/in/instance/server/default/conf/pingfederate.lic
    ```

    Where &lt;path&gt; is the location of your existing PingFederate license file.

    When the container starts, this will mount `<path>/pingfederate.lic` to this location in the container`/opt/in/instance/server/default/conf/pingfederate.lic`.

    The mount paths must match the expected license path for the product.

    |  Product | File Name  |  Mount Path |
    |---|---|---|
    | **PingFederate**  | pingfederate.lic  |  /opt/in/instance/server/default/conf/pingfederate.lic |
    | **PingAccess** | pingaccess.lic  | /opt/in/instance/conf/pingaccess.lic  |
    | **PingDirectory** | PingDirectory.lic  | /opt/in/instance/PingDirectory.lic  |
    | **PingDataSync** | PingDirectory.lic  | /opt/in/instance/PingDirectory.lic  |
    | **PingDataGovernance** | PingDataGovernance.lic  | /opt/in/instance/PingDataGovernance.lic  |
    | **PingCentral** | pingcentral.lic  | /opt/in/instance/conf/pingcentral.lic  |

 1. Repeat this process for the remaining container entries for which you have an existing license.

## Passing a License as a Kubernetes Secret

We'll use PingFederate as an example. You'll need to supply your PingFederate license file.

The kustomize tool provides built-in generators for creating secrets. In this example, the secret will be generated using the `pingfederate.lic` file.

You'll find the YAML files for this example in your local `pingidentity-devops-getting-started/20-kubernetes/07-license-as-secret` directory.

### Prerequisites

* [kustomize](https://kustomize.io/)

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Procedure

1. Copy your PingFederate license file to your working directory.

1. Rename the file to `pingfederate.lic`.

1. Copy the YAML files from your local your local `pingidentity-devops-getting-started/20-kubernetes/07-license-as-secret` directory to your working directory.

1. In the `pingfederate.yaml` file, declare the volume to use for the license:

      ```yaml
      volumes:
        - name: <product-license-volume>
          secret:
            secretName: <pingfederate-license>
      ```

      Where &lt;product-license-volume&gt; is the volume where it will be referenced from the container, and &lt;pingfederate-license&gt; is your license information.

1. Add the following values in the `volumeMounts` section:

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

1. In the `kustomization.yaml` file, add your license information to the `secretGenerator` section:

      ```yaml
      secretGenerator:
      - files:
        - pingfederate.lic
          name: <pingfederate-license>
          type: Opaque
      ```

      The `<pingfederate-license>` value must match the `<pingfederate-license>` `secretName` value you specified in `pingfederate.yaml`.

1. Deploy your license. In your working directory, enter:

      ```sh
      kustomize build . | kubectl apply -f -
      ```

1. To clean up when you're finished, enter:

      ```sh
      kustomize build . | kubectl delete -f -
      ```
