---
title: Deploy an Example Stack
---
# Deploy an Example Stack

!!! note "Video Demonstration"
    A video demonstration of this example is available [here](https://videos.pingidentity.com/detail/videos/devops/video/6313575361112/getting-started-walkthrough).

!!! note "Versions Used"
    This example was written using Docker Desktop with Kubernetes enabled on the Mac platform using the Apple M4 chip.  The Docker Desktop version used for this guide was `4.39.0 (184744)`, which includes Docker Engine `v28.0.1` and Kubernetes `v1.32.2`.  The ingress-nginx controller version was `1.12.1`, deployed from Helm chart version `4.12.1`.

!!! note "Kubernetes Services Kubernetes versus Server-Deployed Applications"

    If you are new to Kubernetes-based deployments, there is a distinct difference when running under Kubernetes compared to running applications on servers.  In a server model, many applications typically run on the same server, and you can access any of them using the same host. For example, many on-premise deployments of PingFederate also include the PingDataConsole, hosted on the same server.

    Under Kubernetes, however, each application that requires external access is associated with a `service`.  A service is a fixed endpoint in the cluster that routes traffic to a given application.  So, in this example, there are distinct service endpoints for PingFederate, PingDataConsole, and the other products.  

    In this demo, these service endpoints are load balanced using the Nginx ingress controller. By adding entries to the `/etc/hosts` file, you can access them using typical URL entries.

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

    1. Deploy the ingress controller to Docker Desktop:

         ```sh
         helm upgrade --install ingress-nginx ingress-nginx \
         --repo https://kubernetes.github.io/ingress-nginx \
         --namespace ingress-nginx --create-namespace
         ```

    1. To wait for the Nginx ingress to reach a healthy state, run the following command.  You can also observe the pod status using k9s or by running `kubectl get pods --namespace ingress-nginx`. You should see one controller pod running when the ingress controller is ready.  This command should exit after no more than 90 seconds or so, depending on the speed of your computer:

        ```sh
        kubectl wait --namespace ingress-nginx \
          --for=condition=ready pod \
          --selector=app.kubernetes.io/component=controller \
          --timeout=90s
        ```

    1. Create a secret in the namespace you will be using to run the example (pinghelm) using the `pingctl` utility. This secret will obtain an evaluation license based on your Ping DevOps username and key:

         ```sh
         pingctl k8s generate devops-secret | kubectl apply -f -
         ```

    1.  This example will use the Helm release name `demo` and DNS domain suffix `*pingdemo.example` for accessing applications.  Add all expected hosts to `/etc/hosts`:

        ```sh
        echo '127.0.0.1 demo-pingaccess-admin.pingdemo.example demo-pingaccess-engine.pingdemo.example demo-pingauthorize.pingdemo.example demo-pingauthorizepap.pingdemo.example demo-pingdataconsole.pingdemo.example demo-pingdelegator.pingdemo.example demo-pingdirectory.pingdemo.example demo-pingfederate-admin.pingdemo.example demo-pingfederate-engine.pingdemo.example demo-pingcentral.pingdemo.example' | sudo tee -a /etc/hosts > /dev/null
        ```

    1. To install the chart, go to your local `"${PING_IDENTITY_DEVOPS_HOME}"/pingidentity-devops-getting-started/30-helm` directory and run the command shown here.  In this example, the release (deployment into Kubernetes by Helm) is called `demo`, forming the prefix for all objects created. The `ingress-demo.yaml` file configures the ingresses for the products to use the **_ping-local_** domain:

        ```sh
        helm upgrade --install demo pingidentity/ping-devops -f everything.yaml -f ingress-demo.yaml
        ```

        The latest product Docker images are automatically downloaded if they have not previously been pulled from [Docker Hub](https://hub.docker.com/u/pingidentity/).

        Sample output:

         ```text
         Release "demo" does not exist. Installing it now.
         NAME: demo
         LAST DEPLOYED: Tue Apr  1 09:14:20 2025
         NAMESPACE: pinghelm
         STATUS: deployed
         REVISION: 1
         TEST SUITE: None
         NOTES:
         #-------------------------------------------------------------------------------------
         # Ping DevOps
         #
         # Description: Ping Identity helm charts - 03/03/2025
         #-------------------------------------------------------------------------------------
         #
         #           Product          tag   typ  #  cpu R/L   mem R/L  Ing
         #    --------------------- ------- --- -- --------- --------- ---
         #    global                2502              0/0       0/0     √
         #
         #  √ pingaccess-admin      2502    sts  1    0/2     1Gi/4Gi   √
         #  √ pingaccess-engine     2502    dep  1    0/2     1Gi/4Gi   √
         #  √ pingauthorize         2502    dep  1    0/2    1.5G/4Gi   √
         #    pingauthorizepap
         #    pingcentral
         #  √ pingdataconsole       2502    dep  1    0/2    .5Gi/2Gi   √
         #    pingdatasync
         #    pingdelegator
         #  √ pingdirectory         2502    sts  1  50m/2     2Gi/8Gi   √
         #    pingdirectoryproxy
         #  √ pingfederate-admin    2502    dep  1    0/2     1Gi/4Gi   √
         #  √ pingfederate-engine   2502    dep  1    0/2     1Gi/4Gi   √
         #    pingintelligence
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

        As you can see, PingAccess Admin and Engine, PingData Console, PingDirectory, PingAuthorize, and the PingFederate Admin and Engine are deployed from the provided `everything.yaml` values file.

        It will take several minutes for all components to become operational.

     1. To display the status of the deployed components, you can use [k9s](https://k9scli.io/) or issue the corresponding commands shown here:

           * Display the services (endpoints for connecting) by running `kubectl get service --selector=app.kubernetes.io/instance=demo`

           ```text
           NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
           demo-pingaccess-admin           ClusterIP   10.105.30.25     <none>        9090/TCP,9000/TCP         6m33s
           demo-pingaccess-admin-cluster   ClusterIP   None             <none>        <none>                    6m33s
           demo-pingaccess-engine          ClusterIP   10.100.1.136     <none>        3000/TCP                  6m33s
           demo-pingauthorize              ClusterIP   10.101.98.228    <none>        443/TCP                   6m33s
           demo-pingauthorize-cluster      ClusterIP   None             <none>        1636/TCP                  6m33s
           demo-pingdataconsole            ClusterIP   10.103.181.27    <none>        8443/TCP                  6m33s
           demo-pingdirectory              ClusterIP   10.106.174.162   <none>        443/TCP,389/TCP,636/TCP   6m33s
           demo-pingdirectory-cluster      ClusterIP   None             <none>        1636/TCP                  6m33s
           demo-pingfederate-admin         ClusterIP   10.96.52.217     <none>        9999/TCP                  6m33s
           demo-pingfederate-cluster       ClusterIP   None             <none>        7600/TCP,7700/TCP         6m33s
           demo-pingfederate-engine        ClusterIP   10.103.84.196    <none>        9031/TCP                  6m33s
           ```

           * To view the pods, run `kubectl get pods --selector=app.kubernetes.io/instance=demo` - you will need to run this at intervals until all pods have started (** Running ** status):

           ```text
           NAME                                        READY   STATUS    RESTARTS   AGE
           demo-pingaccess-admin-0                    1/1     Running   0          7m7s
           demo-pingaccess-engine-59cfb85b9d-7l6tz    1/1     Running   0          7m7s
           demo-pingauthorize-5696dd6b67-hsxnw        1/1     Running   0          7m7s
           demo-pingdataconsole-56b75f9ffb-wld5k      1/1     Running   0          7m7s
           demo-pingdirectory-0                       1/1     Running   0          7m7s
           demo-pingfederate-admin-67cdb47bb4-h88zr   1/1     Running   0          7m7s
           demo-pingfederate-engine-d9889b494-pdhv8   1/1     Running   0          7m7s
           ```

           * To see the ingresses you will use to access the product, run `kubectl get ingress`. If the ingress controller is configured properly, you should see `localhost` as the address as shown here:

           ```text
           NAME                       CLASS    HOSTS                                     ADDRESS     PORTS     AGE
           demo-pingaccess-admin      nginx   demo-pingaccess-admin.pingdemo.example      localhost   80, 443   7m28s
           demo-pingaccess-engine     nginx   demo-pingaccess-engine.pingdemo.example     localhost   80, 443   7m28s
           demo-pingauthorize         nginx   demo-pingauthorize.pingdemo.example         localhost   80, 443   7m28s
           demo-pingdataconsole       nginx   demo-pingdataconsole.pingdemo.example       localhost   80, 443   7m28s
           demo-pingdirectory         nginx   demo-pingdirectory.pingdemo.example         localhost   80, 443   7m28s
           demo-pingfederate-admin    nginx   demo-pingfederate-admin.pingdemo.example    localhost   80, 443   7m28s
           demo-pingfederate-engine   nginx   demo-pingfederate-engine.pingdemo.example   localhost   80, 443   7m28s
           ```

        !!! error "Address must be localhost"
            If the ingress controller is working properly, the ingress definitions will all report the ADDRESS column as `localhost` as shown above.  If you do not see this entry, then you will not be able to access the services later.  This problem is due to a known error with Docker Desktop and the embedded virtual machine (VM) used on the Mac and Windows platform in combination with the ingress controller. To correct the problem, uninstall the chart as instructed at the bottom of this page and restart Docker Desktop.  Afterward, you can re-run the helm command to install the Ping products as instructed above.  The [issue appears to be related to a stale networking configuration](https://github.com/kubernetes/ingress-nginx/issues/7686) under the covers of Docker Desktop.


           * To see everything tied to the helm release run `kubectl get all --selector=app.kubernetes.io/instance=demo`:

           ```text
           NAME                                            READY   STATUS    RESTARTS   AGE
           pod/demo-pingaccess-admin-0                    1/1     Running   0          8m23s
           pod/demo-pingaccess-engine-59cfb85b9d-7l6tz    1/1     Running   0          8m23s
           pod/demo-pingauthorize-5696dd6b67-hsxnw        1/1     Running   0          8m23s
           pod/demo-pingdataconsole-56b75f9ffb-wld5k      1/1     Running   0          8m23s
           pod/demo-pingdirectory-0                       1/1     Running   0          8m23s
           pod/demo-pingfederate-admin-67cdb47bb4-h88zr   1/1     Running   0          8m23s
           pod/demo-pingfederate-engine-d9889b494-pdhv8   1/1     Running   0          8m23s
           
           NAME                                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
           service/demo-pingaccess-admin           ClusterIP   10.105.30.25     <none>        9090/TCP,9000/TCP         8m23s
           service/demo-pingaccess-admin-cluster   ClusterIP   None             <none>        <none>                    8m23s
           service/demo-pingaccess-engine          ClusterIP   10.100.1.136     <none>        3000/TCP                  8m23s
           service/demo-pingauthorize              ClusterIP   10.101.98.228    <none>        443/TCP                   8m23s
           service/demo-pingauthorize-cluster      ClusterIP   None             <none>        1636/TCP                  8m23s
           service/demo-pingdataconsole            ClusterIP   10.103.181.27    <none>        8443/TCP                  8m23s
           service/demo-pingdirectory              ClusterIP   10.106.174.162   <none>        443/TCP,389/TCP,636/TCP   8m23s
           service/demo-pingdirectory-cluster      ClusterIP   None             <none>        1636/TCP                  8m23s
           service/demo-pingfederate-admin         ClusterIP   10.96.52.217     <none>        9999/TCP                  8m23s
           service/demo-pingfederate-cluster       ClusterIP   None             <none>        7600/TCP,7700/TCP         8m23s
           service/demo-pingfederate-engine        ClusterIP   10.103.84.196    <none>        9031/TCP                  8m23s
           
           NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
           deployment.apps/demo-pingaccess-engine     1/1     1            1           8m23s
           deployment.apps/demo-pingauthorize         1/1     1            1           8m23s
           deployment.apps/demo-pingdataconsole       1/1     1            1           8m23s
           deployment.apps/demo-pingfederate-admin    1/1     1            1           8m23s
           deployment.apps/demo-pingfederate-engine   1/1     1            1           8m23s
           
           NAME                                                 DESIRED   CURRENT   READY   AGE
           replicaset.apps/demo-pingaccess-engine-59cfb85b9d    1         1         1       8m23s
           replicaset.apps/demo-pingauthorize-5696dd6b67        1         1         1       8m23s
           replicaset.apps/demo-pingdataconsole-56b75f9ffb      1         1         1       8m23s
           replicaset.apps/demo-pingfederate-admin-67cdb47bb4   1         1         1       8m23s
           replicaset.apps/demo-pingfederate-engine-d9889b494   1         1         1       8m23s
           
           NAME                                     READY   AGE
           statefulset.apps/demo-pingaccess-admin   1/1     8m23s
           statefulset.apps/demo-pingdirectory      1/1     8m23s
           ```

           * To view logs, look at the logs for the deployment of the product in question.  For example:

           ```text
            kubectl logs -f deployment/demo-pingfederate-admin
           ```

2. These are the URLs and credentials to sign on to the management consoles for the products.

    !!! note "Certificates"
        This example uses self-signed certificates that will have to be accepted in your browser or added to your keystore.

    With the ingresses in place, you can access the products at these URLs:

    | Product                                                                           | Connection Details                                                                                                                                                                                                                                            |
    | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | [PingFederate](https://demo-pingfederate-admin.pingdemo.example/pingfederate/app) | <ul> <li>URL: [https://demo-pingfederate-admin.pingdemo.example/pingfederate/app](https://demo-pingfederate-admin.pingdemo.example/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul>                                |
    | [PingDirectory](https://demo-pingdataconsole.pingdemo.example/console)            | <ul><li>URL: [https://demo-pingdataconsole.pingdemo.example/console](https://demo-pingdataconsole.pingdemo.example/console)</li><li>Server: ldaps://demo-pingdirectory-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAccess](https://demo-pingaccess-admin.pingdemo.example/)                     | <ul><li>URL: [https://demo-pingaccess-admin.pingdemo.example/](https://demo-pingaccess-admin.pingdemo.example/)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul>                                                                     |
    | [PingAuthorize](https://demo-pingdataconsole.pingdemo.example/console)            | <ul><li>URL: [https://demo-pingdataconsole.pingdemo.example/console](https://demo-pingdataconsole.pingdemo.example/console)</li><li>Server: ldaps://demo-pingauthorize-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |

3. When you are finished, you can remove the demonstration components by running the uninstall command for helm:

    ```sh
    helm uninstall demo
    ```

## Next Steps

Now that you have deployed a set of our product images using the provided chart, you can move on to deployments using configurations that more closely reflect use cases to be explored.  Refer to the [helm examples](../deployment/deployHelm.md)) page for other typical deployments.

!!! warning "Container logging"
    Maintaining logs in a containerized model is different from the typical server-deployed application.  See [this page](../reference/containerLogging.md) for additional details.
