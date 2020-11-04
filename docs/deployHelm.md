# Deploy Ping DevOps Charts using Helm

Helm is a package deployment tool for Kubernetes. It can be used with PingDevops to deploy all the components of the Solution with a simple command.

To get started, complete the following steps:

1. Inject your Ping DevOps secrets.  There are a couple of options for injecting a license.

   * Eval License - Use your `PING_IDENTITY_DEVOPS_USER/PING_IDENTITY_DEVOPS_KEY` credentials
   along with your `PING_IDENTITY_ACCEPT_EULA` setting.
     * For more information on obtaining credentials click [here](https://pingidentity-devops.gitbook.io/devops/getstarted/prod-license#obtaining-a-ping-identity-devops-user-and-key).
     * For more infomration on using `ping-devops` utility click [here](https://pingidentity-devops.gitbook.io/devops/devopsutils/pingdevopsutil).

        ```shell
        ping-devops generate devops-secret | kubectl -apply -f -
        ```

2. Install Helm

   * Installing on MacOS (or linux with brew)

       ```shell
       brew install helm
       ```

   * Installing on other OS - https://helm.sh/docs/intro/install/

3. Add Helm Ping DevOps Repo

    ```shell
    helm repo add pingidentity https://helm.pingidentity.com/devops/
    ```

4. List Ping DevOps Charts

    ```shell
    helm search repo pingidentity
    ```

5. Update local machine with latest charts

    ```shell
    helm repo update
    ```

6. Install a Ping DevOps Chart

Install a chart using the `helm install {release} {chart} ...` using the example
below.  In this case, it is installing a `pingfederate-admin` chart with the release name of
`pf`.

```shell
helm install pf pingidentity/pingfederate-admin
```

or, if you have a `devops-values.yaml` file to include:

```shell
helm install pf ping-devops/pingfederate-admin -f devops-values.yaml
```

## Accessing Deployments

Components of the release will be prefixed with `pf`.  Use `kubectl` to access the workloads:

View kubernetes resources installed

```shell
kubectl get all

# or get even more (ing, pvc)

kubectl get pods,svc,deploy,rs,sts,job,ing,pvc
```

View Logs:

```shell
# kubectl logs -f pod/{release}-{product}-...

kubectl logs -f pod/pf-pingfederate-admin-...
```

## Uninstalling Deployment

To uninstall a release from helm, use the following `helm uninstall` command:

```shell
helm uninstall pf
```
