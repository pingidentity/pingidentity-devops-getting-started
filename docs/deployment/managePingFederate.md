---
title: PingFederate Configuration Management
---
# PingFederate Configuration Management

PingFederate has many moving parts which lead to a variety of operating patterns. 

These patterns typically involve a trade-off between ease of implementation and mitigation of deployment risks

To simplify the moving parts we will categorize PingFederate Configuration into three categories:

**Infrastructure Config**
  - Examples: Resource allocation (CPU/Memory/Storage), Client Ingress Access and Hostnames, Image Version, Exposed Ports, Environment Variable Definition, Secrets Definition
  - Orchestration - These items are defined in the [release's values.yaml](https://helm.sh/docs/chart_template_guide/values_files/) and any change triggers an update.

**Server Config**
  - Examples: `*.properties` files, Integration Kits, HTML Templates, logs formatting. This can be oversimplified to _everything except_ the `/instance/server/default/data` folder
  - Orchestration - These items are stored in the [Server Profile](../how-to/containerAnatomy.md) and any change _should_ trigger an update. It is up to the implementor to ensure that happens. This can be done by adding a non-functional variable in values.yaml to track the current profile "version". Example: `SERVER_PROFILE_VERSION: v1.1"

**App Config**
  - Examples - Core PingFederate configuration. Changes that are typicaly made through the UI or Admin APIs. This can be oversimplified to the `/instance/server/default/data` folder or `/instance/bulk-config/data.json`.
  - Orchestration - Dependent of your operating pattern this changes may be delivered via a rolling update, or by configuration replication. 



## PingFederate Data Mount

In the most common pattern, we attach a persistent volume to `/opt/out/instance/server/default/data` on the Pingfederate Admin Console _only_. 
This pattern is intended to be used when PingFederate Administrators need to deliver configuration through the UI in _each environment including production_. Another reason for this may be if SP connections are allowed to be created by app developers via Admin API. In both of these scenarios, the defining factor is that there are mutations in the production Admin console that are not being tracked in any other way, like source control, and therefore must be persisted. 

**Attributes of this pattern**:
  - App Config is persisted in each environment.
  - App Config promotion is done manually of via Admin API.
  - App Config is replicated from Admin Console to Engines.
  - Server Config is tracked and delivered via server profile. 
  - Server profile _does not_ include App Config.
  - Backups are taken regularly in case of Persistent Volume loss or corruption.


### Data Mount Example

Helm values relevant to this configuration may look like: 

  ```yaml
  pingfederate-admin:
    enabled: true
    container:
      replicaCount: 1
    envs:
      SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
      SERVER_PROFILE_PATH: pf-data-mount/pingfederate
      PROFILE_VERSION: v1.1
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
      SERVER_PROFILE_URL: https://github.com/samir-gandhi/server-profiles.git
      SERVER_PROFILE_PATH: pf-data-mount/pingfederate
      PROFILE_VERSION: v1.1
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

The key aspect here is `pingfederate-admin.workload.statefulset.persistentvoume.volumes.out-dir.mountPath=/opt/out/instance/server/default/data`. This is where all UI configuration (App Config) is stored as files. Because this is the `mountPath`, PingFederate admins have the freedom to deliver any files _not_ used in `/opt/out/instance/server/default/data` via Server Profile. 

For example, adding a new IDP adapter requires a restart of the service in order for the adapter to be identified and available to App Config. The steps in this case would be:
  1. Add the adapter at `https://github.com/samir-gandhi/server-profiles/pf-data-mount/pingfederate/instance/server/defaule/deploy/idp-adapter-name-1.jar`
  2. update `PROFILE_VERSION: v1.1` -> `PROFILE_VERSION: v1.2` on both the admin and engine
  3. run `helm upgrade --install myping pingidentity/ping-devops -f /path/to/values.yaml`

Now, if the release already existed, the variable change signifies that the definition has mutated, and thus must be re-deployed. The admin pod will be deleted and recreated, while the engines will surge and roll one by one. 
Reference links: 
  - [K8s - Performing a Rolling Update](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
  - [K8s - Update a deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment)

**Values with this approach**
  - Managing App Config is more familiar to PingFederate admins with traditional experience. 
  - Less to account for when building a CI/CD pipeline because there is no config export + templating.
  - Ability to have configurations different in each environment

**Cautions with this approach**
  - More room for user configuration error and outage because configurations are not promoted with automated testing. 