---
title: Ingress on local Kind cluster
---
# Local Kind ingress

If you have deployed the local kind cluster as outlined on the [create a local cluster](./deployLocalK8sCluster.md) page, follow these instructions to use an ingress for accessing your products.

## Prerequisites

* A kind cluster deployed with ingress enabled.  For this guide, the cluster name `ping`  is assumed
* The hostname aliases have been appended to the `/etc/hosts` file
* You have created the secret for your DevOps user and key for retrieving licenses

## Assumptions

With the `/etc/hosts` file entries created from the page linked above, the release in helm **must** be `myping` for the hostnames to work with the configuration here.  Consider the first entry as an example:

```sh
127.0.0.1 myping-pingaccess-admin.ping-local.com ...
```

When using our charts, the release name provided to helm is prepended - that is what provides the `myping-` portion of the hostname in the file.  The `ping-local.com` domain suffix is provided through the ingress definitions as shown later on this page.  So, the structure is:

```sh
<helm-release-name>-<ping-product-service>.<domain-name-from-ingress>
```

If you use a release name other than `myping` or a domain other than `ping-local.com` you will need to update the aliases in `/etc/hosts`/ accordingly.

## Instructions

There is a file under the `30-helm` directory of this repository named `ingress.yaml`.  Modify this file for use with a local cluster:

* Replace `insert domain name here` with your domain name (ping-local.com in this guide)
* Edit line 11, removing the `-public` suffix for the class

The file should look as shown here:

```yaml
global:
  envs:
    PING_IDENTITY_ACCEPT_EULA: "YES"
  ingress:
    enabled: true
    addReleaseNameToHost: prepend
    defaultDomain: "ping-local.com"
    defaultTlsSecret:
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      kubernetes.io/ingress.class: "nginx"
```

## Create ingresses

When deploying using helm and one of the example YAML files in the 30-helm directory, also pass in the ingress.yaml file to include the ingress definitions as part of the overall deployment.

For example, to use the `everything.yaml` and include ingresses, you would run the following command from the 30-helm directory (after updating the ingress.yaml file):

```sh
helm upgrade --install myping pingidentity/ping-devops -f everything.yaml -f ingress.yaml
```

After everything has started, you will see the same pods and services as in the getting started example.  In addition, you will see ingress definitions in the same namespace as the products:

```sh
# List ingress definitions
kubectl get ingress

# Output
NAME                         CLASS    HOSTS                                       ADDRESS     PORTS     AGE
myping-pingaccess-admin      <none>   myping-pingaccess-admin.ping-local.com      localhost   80, 443   47m
myping-pingaccess-engine     <none>   myping-pingaccess-engine.ping-local.com     localhost   80, 443   47m
myping-pingauthorize         <none>   myping-pingauthorize.ping-local.com         localhost   80, 443   47m
myping-pingdataconsole       <none>   myping-pingdataconsole.ping-local.com       localhost   80, 443   47m
myping-pingdirectory         <none>   myping-pingdirectory.ping-local.com         localhost   80, 443   47m
myping-pingfederate-admin    <none>   myping-pingfederate-admin.ping-local.com    localhost   80, 443   47m
myping-pingfederate-engine   <none>   myping-pingfederate-engine.ping-local.com   localhost   80, 443   47m
```

The HOSTS column reflects the entries added to the `/etc/hosts` file.

To access a given service, enter the HOSTS entry in your browser (you will have to accept the self-signed certificate).  For example, to view the Ping Federate console, you would access **https://myping-pingfederate-admin.ping-local.com/**.  For the Ping Data console, **https://myping-pingdataconsole.ping-local.com** and so on.

Here are the credentials and URLs.  This table is similar to the getting started example but reflects the release name used on this page:

| Product | Connection Details |
| --- | --- |
| [PingFederate](https://myping-pingfederate-admin.ping-local.com/pingfederate/app) | <ul> <li>URL: [https://myping-pingfederate-admin.ping-local.com/pingfederate/app](https://myping-pingfederate-admin.ping-local.com/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
| [PingDirectory](https:///myping-pingdataconsole.ping-local.com) | <ul><li>URL: [https://myping-pingdataconsole.ping-local.com/console](https://myping-pingdataconsole.ping-local.com/console)</li><li>Server: ldaps://myping-pingdirectory-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
| [PingAccess](https://myping-pingaccess-admin.ping-local.com) | <ul><li>URL: [https://myping-pingaccess-admin.ping-local.com](https://myping-pingaccess-admin.ping-local.com)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
| [PingAuthorize](https:///myping-pingdataconsole.ping-local.com) | <ul><li>URL: [https://myping-pingdataconsole/console](https://myping-pingdataconsole/console)</li><li>Server: ldaps://myping-pingauthorize-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |

## Cleaning up

Since the ingresses are deployed as part of the overall release, deleting the release will also remove the ingress definitions (leaving the ingress controller intact).  

The ingress controller will be removed when the cluster is deleted.  If you only want to remove the ingress controller, you can either:

* Run `kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/1.23/deploy.yaml` if you installed the controller from Github

**OR**

* Run `kubectl delete -f ./20-kubernetes/kind-nginx.yaml` if you used the local copy to install the controller.
