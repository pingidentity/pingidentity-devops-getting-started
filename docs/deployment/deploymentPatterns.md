---
title: Operating Patterns Overview
---
# Operating Patterns

This page discusses how to have a successful first day and beyond.

After you are comfortable with the deployment examples in the getting-started repository, you can shift your focus to managing ongoing operations of the products that are relevant to you. Since it is not feasible to cover every operating scenario, this section will focus on guidance to identify an operating pattern suitable for your organization.

The PingFederate application is used as an example of performing this assessment with some example patterns.

## PingFederate Configuration Management

PingFederate has a variety of operating patterns. These patterns typically involve a trade-off between ease of implementation and mitigation of deployment risks.

To simplify the moving parts, PingFederate configuration can be categorized into three patterns:

### 1) Infrastructure Configuration

#### Examples of managed components:
  -  Resource allocation (CPU/Memory/Storage)
  -  Client Ingress (Access and Hostnames)
  -  Image Version
  -  Exposed Ports
  -  Environment Variable Definitions
  -  Secrets Definitions

#### Orchestration
 - These items are defined in the [release values.yaml file](https://helm.sh/docs/chart_template_guide/values_files/) and any changes here triggers an update.

### 2) Server Configuration

This pattern can be oversimplified to _everything outside of_ the `/instance/server/default/data` folder or `/instance/bulk-config/data.json`.
#### Examples of managed components:

  - `*.properties` files
  - Integration Kits
  - HTML templates
  - log formatting (log4j2.xml)

#### Orchestration
These items are stored in the [Server Profile](../how-to/containerAnatomy.md) and any change _should_ trigger an update. It is up to the implementer to ensure that happens. Triggering an update can be done by adding a non-functional variable in `values.yaml` to track the current profile "version". Example: `SERVER_PROFILE_VERSION: v1.1`

### 3) Application Configuration (App Config)

Application configuration can be managed via any combination of the following, according to customer internal configuration management requirements:

- The [PingFederate Terraform provider](https://terraform.pingidentity.com/getting-started/pingfederate/) - a way to declare the "end state" of configuration of a PingFederate server. Terraform can be used to identify and correct configuration drift in an environment ad-hoc or on a schedule. Configuration managed through Terraform uses the PingFederate administration API and requires the server to have successfully started. Configuration changes typically require replication to the engine nodes, but do not require a restart of the PingFederate service to take effect.
- The `/instance/server/default/data` folder in the server profile - a way to declare the initial start-up configuration of PingFederate admin and engine nodes by providing a foundational filesystem structure. The configuration is pulled from Git and applied during container start-up, while changes to this configuration typically requires servers to be restarted to take effect. This configuration method is typically used when deploying new adapter JAR files or deployments to the PingFederate server's built-in Jetty container.
- The `/instance/bulk-config/data.json` file in the server profile - a way to declare the initial start-up configuration of the PingFederate service by providing a foundational configuration package. The configuration is pulled from Git and applied during container start-up, while changes to this configuration typically requires a server restart to take effect.

#### Managed components

This category is the core PingFederate configuration. This pattern incorporates changes that are typically made through the UI or Admin APIs.

#### Orchestration
Depending on your operating pattern, changes here may be delivered through a rolling update or by configuration replication.

## Using the PingFederate Terraform provider

Terraform updates should trigger server replication to the engine nodes at the end of the PingFederate configuration pipeline.

The admin server should use a persistent volume so it can recover the same admin configuration as before if the pod is restarted. If the clustered engine pods are restarted, they'll refresh their configuration from the admin server during startup. See the below section for details on how to configure a persistent volume.

The Terraform configuration should be managed in a repository separate from infrastructure and server profile configuration. Changes made to the PingFederate server via Terraform require replication to PingFederate engine nodes as the final step of configuration and don't require rolling restarts to the PingFederate deployment for changes to take effect.

For more information on using the PingFederate Terraform provider, see the [getting started guide](https://terraform.pingidentity.com/getting-started/pingfederate/).

## PingFederate Data Mount

In the most common pattern, a user would attach a persistent volume (PV) to `/opt/out/instance/server/default/data` _only_ on the PingFederate Admin Console.

This model is intended to be used when PingFederate Administrators need to deliver configuration through the UI in _each environment, including production_. Another reason for this use case may be if SP connections are allowed to be created by app developers using the Admin API. In both of these scenarios, the defining factor is that there are mutations in the production Admin console that are not being tracked in any other way, such as through source control, and therefore must be persisted.

**Attributes of this pattern**:

- App Config is persisted in each SDLC environment (e.g. Dev, QA, Prod)
- App Config promotion is done manually or via the Admin API
- App Config is replicated from Admin Console to Engines
- Server Config is maintained and delivered via the server profile
- Server profile _does not_ include App Config
- Server profile **_must not_** have `instance/bulk-config/data.json` or `/instance/server/default/data`
- Backups are taken regularly to provide recovery in case of PV loss or corruption

### Data Mount Helm Example

Helm values relevant to this configuration may look like:

  ```yaml
  pingfederate-admin:
    enabled: true
    container:
      replicaCount: 1
    envs:
      SERVER_PROFILE_URL: <insert your server profile URL here>
      SERVER_PROFILE_PATH: <insert your server profile path here>
      SERVER_PROFILE_VERSION: <server profile version>
    workload:
      type: StatefulSet
      statefulSet:
        persistentvolume:
          enabled: true
          volumes:
            out-dir:
              ## NOTE THIS PVC DEFINITION ##
              mountPath: /opt/out/instance/server/default/data
              persistentVolumeClaim:
                accessModes:
                - ReadWriteOnce
                storageClassName:
                resources:
                  requests:
                    storage: 8Gi

  pingfederate-engine:
    enabled: true
    envs:
      SERVER_PROFILE_URL: <insert your server profile URL here>
      SERVER_PROFILE_PATH: <insert your server profile path here>
      SERVER_PROFILE_VERSION: <server profile version>
    container:
      replicaCount: 3
    workload:
      type: Deployment
      deployment:
        strategy:
          type: RollingUpdate
          rollingUpdate:
            maxSurge: 1
            maxUnavailable: 0
  ```

The key aspect here is `pingfederate-admin.workload.statefulset.persistentvolume.volumes.out-dir.mountPath=/opt/out/instance/server/default/data`. This location is where all UI configuration (App Config) is stored as files. As this location is the `mountPath`, PingFederate administrators have the freedom to deliver any files _not_ used in `/opt/out/instance/server/default/data` via a Server Profile.

For example, adding a new IDP adapter requires a restart of the service in order for the adapter to be identified and available to App Config. The steps in this case would be:

1. Add the adapter at `<server profile URL>/<server profile path>/pingfederate/instance/server/default/deploy/idp-adapter-name-1.jar`
1. Update `SERVER_PROFILE_VERSION: <current version>` -> `SERVER_PROFILE_VERSION: <new version>` on both the admin and engine deployments (for example, v1.1 -> v1.2)
1. Run `helm upgrade --install myping pingidentity/ping-devops -f /path/to/values.yaml`

If the release already exists, the variable change signifies that the definition has mutated, and therefore must be redeployed. The admin pod will be deleted and recreated while the engines will surge and roll one by one.

Reference links:

- [K8s - Performing a Rolling Update](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
- [K8s - Update a deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment)

### Data Mount Pros and Cons

#### Values with this approach

- Managing App Config is more familiar to PingFederate administrators with traditional experience
- Fewer parts to consider when building a CI/CD pipeline because there is no configuration export and templating needed
- Ability to have configurations different in each environment

#### Cautions with this approach

- There is more room for user configuration error and possible outages because configurations are not promoted with automated testing
