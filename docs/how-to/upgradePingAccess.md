---
title: Upgrading PingAccess
---

# Upgrading PingAccess

In a DevOps environment, upgrades can be simplified through automation, orchestration, and separation of concerns.

!!! warning "Notice"
    * Upgrading from PingAccess versions prior to 6.3.6 will not work using this method.

## Caveats

1.  **This Document Assumes Kubernetes and Helm**

    The terms in this document will focus on deployments in a Kubernetes Environment using the ping-devops Helm chart. However, the concepts should apply to any containerized PingAccess Deployment.

1.  **This Document will Become Outdated**

    The examples referenced in this document point to a specific tag. This tag may not exist anymore at the time of reading. To correct the issue, update the tag on your file to N -1 from the current PF version. 

1.  **Upgrades from Traditional Deployment**

    It may be desirable to upgrade PingAccess along with migrating from a traditional environment. This is not recommended. Instead you should upgrade your current environment to the desired version of PingAccess and then [create a profile](./buildPingAccessProfile.md) that can be used in a containerized deployment.

1.  **Irrelevant Ingress**

    The values.yaml files mentioned in this document expects and nginx ingress controller with class `nginx-public`. It is not an issue if your environment doesn't have this, the created ingresses will not be used.

## Configuration Forward

Steps:

1.  Deploy your old version of PingAccess with server profile
1.  Export the configuration as a data.json file
1.  Copy the <PA_Home>/conf/pa.jwk file
1.  Deploy new PingAccess version with server profile

Here we will walk through an example upgrade.


### Deploy your old version of PingAccess with server profile

!!! Info "Make sure you have a devops-secret"
If you are using this example as is, you will need a [devops-secret](../how-to/devopsUserKey.md#for-kubernetes)

!!! Info "Be sure to change the ingress domain name value to your domain in [01-original.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingaccess-upgrade/01-original.yaml)"

!!! Info "Be sure to change the image tag value in [01-original.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingaccess-upgrade/01-original.yaml)"

!!! Info "In order to use the baseline server profile for this you have to deploy PingFederate along with PingAccess"

Navigate to the getting started repository and deploy your old version of PingAccess.

```
$ helm upgrade --install pa-upgrade pingidentity/ping-devops -f 30-helm/pingaccess-upgrade/01-original.yaml
```

### Export the configuration as a data.json file

Once your cluster is healthy export the configuration as a json file and add it to your server profile so the start-up-deployer can use it to configure your upgraded PingAccess.

```
$ curl -k -u Administrator:2FederateM0re -H "X-Xsrf-Header: PingAccess" https://pa-upgrade-pingaccess-admin.ping-devops.com/pa-admin-api/v3/config/export >~/<insert path to server profile here>/pingaccess/instance/data/data.json
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22002  100 22002    0     0  42664      0 --:--:-- --:--:-- --:--:-- 43056
```

Copy the pa.jwk file to your server profile.

```
$ kubectl cp pa-upgrade-pingaccess-admin-0:/opt/out/instance/conf/pa.jwk ~/<insert path to server profile here>/pingaccess/instance/conf/pa.jwk
Defaulted container "pingaccess-admin" out of: pingaccess-admin, wait-for-pingfederate-engine (init), generate-private-cert-init (init)
tar: removing leading '/' from member names
```

Check to see that the data.json and pa.jwk files have been updated in your server-profile and push these changes to your repository

### Deploy new PingAccess version with server profile

Make sure to uninstall your old Ping Access cluster and remove any pvc's created.

```
$ helm uninstall pa-upgrade
release "pa-upgrade" uninstalled
$ kubectl get pvc
NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
out-dir-pa-upgrade-pingaccess-admin-0   Bound    pvc-c1e5cd9b-35f5-4260-8704-3075fcf9b36e   4Gi        RWO            gp2            7m5s
$ kubectl delete pvc out-dir-pa-upgrade-pingaccess-admin-0
persistentvolumeclaim "out-dir-pa-upgrade-pingaccess-admin-0" deleted
```

Finally, update PingAccess image version to new target PingAccess version and run as normal.

!!! Info "Be sure to change the ingress domain name value to your domain in [02-upgraded.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingaccess-upgrade/02-upgraded.yaml)"

!!! Info "Be sure to change the image tag value in [02-upgraded.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingaccess-upgrade/02-upgraded.yaml)"

!!! Info "Be sure to change the server profile url and path in [02-upgraded.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingaccess-upgrade/02-upgraded.yaml)"

```
helm upgrade --install pa-upgrade pingidentity/ping-devops -f 30-helm/pingaccess-upgrade/02-upgraded.yaml
```

Now you should have a an upgraded PingAccess instance