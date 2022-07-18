---
title: Deploy an Example Stack
---
# Deploy an Example Stack

!!! info "Orchestration note"
    In the past, Docker Compose was used for many of our product container examples.  We are no longer maintaining or supporting Docker Compose, and recommend the use of the Ping Helm charts for working with Ping products in a containerized model.

!!! note "Networking"
    This example was written using Docker Desktop with Kubernetes enabled.  As such, there is no ingress controller deployed, so for accessing the consoles, a kubectl port-forward is used.  See the [Kubernetes documentation](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) for more details on the port-forward command.

The Ping Identity Helm [Getting Started](https://helm.pingidentity.com/getting-started/) page has instructions on getting your environment configured for using the Ping Helm charts.

For more examples, see [Helm Chart Example Configurations](../deployment/deployHelm.md).

For more information on Helm with Ping products, see [Ping Identity DevOps Helm Charts](https://helm.pingidentity.com).

## What You Will Do

After using Git to clone the `pingidentity-devops-getting-started` repository, you will use Helm to deploy a sample stack to a Kubernetes cluster.

## Prerequisites

* Register for the Ping DevOps program and install/configure `pingctl` with your User and Key
* Install [Git](https://git-scm.com/downloads)
* Follow the instructions on the helm [Getting Started](https://helm.pingidentity.com/getting-started/) page up through updating to the latest charts to ensure you have the latest version of our charts
* Access to a Kubernetes cluster. You can enable Kubernetes in Docker Desktop for a simple cluster, which was the cluster used for this guide (on the Mac platform).

## Clone the `getting-started` repository

1. Clone the `pingidentity-devops-getting-started` repository to your local `${PING_IDENTITY_DEVOPS_HOME}` directory.

    !!! note "The `${PING_IDENTITY_DEVOPS_HOME}` environment variable was set by running `pingctl config`."

    ```sh
    cd "${PING_IDENTITY_DEVOPS_HOME}"
    git clone \
      https://github.com/pingidentity/pingidentity-devops-getting-started.git
    ```

## Deploy the example stack

1. Deploy the example stack of our product containers.

    !!! warning "Initial Deployment"
        For this guide, avoid making changes to the `everything.yaml` file to ensure a successful first-time deployment.

    1. Create a namespace for running the stack in your Kubernetes cluster.  

         ```sh
         # Create the namespace
         kubectl create ns pinghelm

         # Set the kubectl context to the namespace
         kubectl config set-context --current --namespace=pinghelm

         # Confirm
         kubectl config view --minify | grep namespace:
         ```

    2. Create a secret in the namespace you will be using to run the example using the `pingctl` utility. This secret will obtain an evaluation license based on your Ping DevOps username and key:

         ```sh
         pingctl k8s generate devops-secret | kubectl apply -f -
         ```

    3. To install the chart, go to your local `"${PING_IDENTITY_DEVOPS_HOME}"/pingidentity-devops-getting-started/30-helm` directory and run the command shown here.  In this example, the release (deployment into Kubernetes by Helm) is called `demo`, forming the prefix for all objects created:

        ```sh
        helm install demo pingidentity/ping-devops -f everything.yaml

        ```

        The product Docker images are automatically pulled if they have not previously been pulled from [Docker Hub](https://hub.docker.com/u/pingidentity/).

        Sample output:

         ```text
         NAME: demo
         LAST DEPLOYED: Wed Jun 29 14:10:53 2022
         NAMESPACE: helm
         STATUS: deployed
         REVISION: 1
         TEST SUITE: None
         NOTES:
         #-------------------------------------------------------------------------------------
         # Ping DevOps
         #
         # Description: Ping Identity helm charts - 06/02/22
         #-------------------------------------------------------------------------------------
         #
         #           Product          tag   typ  #  cpu R/L   mem R/L  Ing
         #    --------------------- ------- --- -- --------- --------- ---
         #    global                2205              0/0       0/0
         #
         #  √ pingaccess-admin      2205               /         /
         #  √ pingaccess-engine     2205               /         /
         #  √ pingauthorize         2205               /         /
         #    pingauthorizepap
         #    pingcentral
         #  √ pingdataconsole       2205               /         /
         #    pingdatagovernance
         #    pingdatagovernancepap
         #    pingdatasync
         #    pingdelegator
         #  √ pingdirectory         2205               /         /
         #    pingdirectoryproxy
         #  √ pingfederate-admin    2205               /         /
         #  √ pingfederate-engine   2205               /         /
         #
         #    ldap-sdk-tools
         #    pd-replication-timing
         #    pingtoolkit
         #
         #-------------------------------------------------------------------------------------
         # To see values info, simply set one of the following on your helm install/upgrade
         #
         #    --set help.values=all         # Provides all (i.e. .Values, .Release, .Chart, ...) yaml
         #    --set help.values=global      # Provides global values
         #    --set help.values={ image }   # Provides image values merged with global
         #-------------------------------------------------------------------------------------
         ```

        As you can see, PingAccess Admin and Engine, PingData Console, PingDirectory, and the PingFederate Admin and Engine are deployed from the provided `everything.yaml` values file.

        It will take several minutes for all components to become operational.

     4. To display the status of the deployed components, you can use [k9s](https://k9scli.io/) or issue the corresponding commands shown here:

           * Display the services (endpoints for connecting) by running `kubectl get service --selector=app.kubernetes.io/instance=demo`

           ```text
           NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
           demo-pingaccess-admin           ClusterIP   10.96.234.72     <none>        9090/TCP,9000/TCP         15m
           demo-pingaccess-admin-cluster   ClusterIP   None             <none>        <none>                    15m
           demo-pingaccess-engine          ClusterIP   10.106.190.217   <none>        3000/TCP                  15m
           demo-pingauthorize              ClusterIP   10.104.246.123   <none>        443/TCP                   15m
           demo-pingauthorize-cluster      ClusterIP   None             <none>        1636/TCP                  15m
           demo-pingdataconsole            ClusterIP   10.96.166.28     <none>        8443/TCP                  15m
           demo-pingdirectory              ClusterIP   10.107.42.8      <none>        443/TCP,389/TCP,636/TCP   15m
           demo-pingdirectory-cluster      ClusterIP   None             <none>        1636/TCP                  15m
           demo-pingfederate-admin         ClusterIP   10.105.26.94     <none>        9999/TCP                  15m
           demo-pingfederate-cluster       ClusterIP   None             <none>        7600/TCP,7700/TCP         15m
           demo-pingfederate-engine        ClusterIP   10.99.223.48     <none>        9031/TCP                  15m
           ```

           * To view the pods, run `kubectl get pods --selector=app.kubernetes.io/instance=demo` - you will need to run this at intervals until all pods have started (** Running ** status):

           ```text
           NAME                                        READY   STATUS    RESTARTS   AGE
           demo-pingaccess-admin-0                     1/1     Running   0          7m29s
           demo-pingaccess-engine-cf9987bb5-npspz      1/1     Running   0          7m52s
           demo-pingauthorize-8bdfd4fd8-j82zg          1/1     Running   0          7m43s
           demo-pingdataconsole-7c875985d4-mfjbq       1/1     Running   0          17m
           demo-pingdirectory-0                        1/1     Running   0          7m38s
           demo-pingfederate-admin-5786787dfd-5b5s5    1/1     Running   0          7m36s
           demo-pingfederate-engine-5ff6546f4f-7jfnt   1/1     Running   0          7m31s
           ```

           * To see everything tied to the helm release run `kubectl get all --selector=app.kubernetes.io/instance=demo`:

           ```text
           NAME                                            READY   STATUS    RESTARTS   AGE
           pod/demo-pingaccess-admin-0                     1/1     Running   0          107m
           pod/demo-pingaccess-engine-cf9987bb5-npspz      1/1     Running   0          107m
           pod/demo-pingauthorize-8bdfd4fd8-j82zg          1/1     Running   0          107m
           pod/demo-pingdataconsole-7c875985d4-mfjbq       1/1     Running   0          116m
           pod/demo-pingdirectory-0                        1/1     Running   0          107m
           pod/demo-pingfederate-admin-5786787dfd-5b5s5    1/1     Running   0          107m
           pod/demo-pingfederate-engine-5ff6546f4f-7jfnt   1/1     Running   0          107m
           
           NAME                                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
           service/demo-pingaccess-admin           ClusterIP   10.96.234.72     <none>        9090/TCP,9000/TCP         116m
           service/demo-pingaccess-admin-cluster   ClusterIP   None             <none>        <none>                    116m
           service/demo-pingaccess-engine          ClusterIP   10.106.190.217   <none>        3000/TCP                  116m
           service/demo-pingauthorize              ClusterIP   10.104.246.123   <none>        443/TCP                   116m
           service/demo-pingauthorize-cluster      ClusterIP   None             <none>        1636/TCP                  116m
           service/demo-pingdataconsole            ClusterIP   10.96.166.28     <none>        8443/TCP                  116m
           service/demo-pingdirectory              ClusterIP   10.107.42.8      <none>        443/TCP,389/TCP,636/TCP   116m
           service/demo-pingdirectory-cluster      ClusterIP   None             <none>        1636/TCP                  116m
           service/demo-pingfederate-admin         ClusterIP   10.105.26.94     <none>        9999/TCP                  116m
           service/demo-pingfederate-cluster       ClusterIP   None             <none>        7600/TCP,7700/TCP         116m
           service/demo-pingfederate-engine        ClusterIP   10.99.223.48     <none>        9031/TCP                  116m
           
           NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
           deployment.apps/demo-pingaccess-engine     1/1     1            1           116m
           deployment.apps/demo-pingauthorize         1/1     1            1           116m
           deployment.apps/demo-pingdataconsole       1/1     1            1           116m
           deployment.apps/demo-pingfederate-admin    1/1     1            1           116m
           deployment.apps/demo-pingfederate-engine   1/1     1            1           116m
           
           NAME                                                  DESIRED   CURRENT   READY   AGE
           replicaset.apps/demo-pingaccess-engine-cf9987bb5      1         1         1       116m
           replicaset.apps/demo-pingauthorize-8bdfd4fd8          1         1         1       116m
           replicaset.apps/demo-pingdataconsole-7c875985d4       1         1         1       116m
           replicaset.apps/demo-pingfederate-admin-5786787dfd    1         1         1       116m
           replicaset.apps/demo-pingfederate-engine-5ff6546f4f   1         1         1       116m
           
           NAME                                     READY   AGE
           statefulset.apps/demo-pingaccess-admin   1/1     116m
           statefulset.apps/demo-pingdirectory      1/1     116m
           ```

           * To view logs, look at the logs for the deployment of the product in question.  For example:

           ```text
            kubectl logs -f deployment/demo-pingfederate-admin
           ```

2. These are the URLs and credentials to sign on to the management consoles for the products.

    !!! note "Access to Kubernetes services"
        The default networking type for services in the chart is `ClusterIP`. This type is internal-only to the Kubernetes cluster. For production environments, or if your cluster has an ingress controller configured, refer to the ** ingress.yaml ** file in the 30-helm directory of this repository to enable outside access to services in the cluster.

    For this guide, there is no ingress in place on Docker Desktop, so a `kubectl port-forward` command is required.  This command provides a tunnel into the cluster from your local machine to the given service.

    The syntax is `kubectl port-forward <service name> <localport>:<service port>`

    For example, the services output in the previous step indicates that the PingFederate Admin console service (demo-pingfederate-admin) is listening on port 9999.  To access it from your local system, run the following command and then navigate to [https://localhost:9999](https://localhost:9999) in your browser:

    ```sh
    kubectl port-forward svc/demo-pingfederate-admin 9999:9999
    ```

    !!! note "Certificates"
        This example uses self-signed certificates that will have to be accepted in your browser or added to your keystore.

    While the local port does not have to match the service port, it is recommended for simplicity. If you use a different local port, adjust the URLS below accordingly. 

    With the appropriate port-forward in place, you can access the products at these defaults.

    | Product | Connection Details |
    | --- | --- |
    | [PingFederate](https://localhost:9999/pingfederate/app) | <ul> <li>URL: [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDirectory](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: ldaps://demo-pingdirectory-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAccess](https://localhost:9000) | <ul><li>URL: [https://localhost:9000](https://localhost:9000)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAuthorize](https://localhost:8443/console) | <ul><li>URL: [https://localhost:8443/console](https://localhost:8443/console)</li><li>Server: ldaps://demo-pingauthorize-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |

3. When you are finished, you can remove the demonstration components by running the uninstall command for helm:

    ```sh
    helm uninstall demo
    ```

## Next Steps

Now that you have deployed a set of our product images using the provided chart, you can move on to deployments using configurations that more closely reflect use cases to be explored.  Refer to the [helm examples](../deployment/deployHelm.md)) page for other typical deployments.

!!! warning "Container logging"
    Logging in containers is different from typical server-deployed application implementation.  See [this page](../reference/containerLogging.md) for additional details.
