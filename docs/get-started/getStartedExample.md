---
title: Deploy an Example Stack
---
# Deploy an Example Stack

!!! note "Video Demonstration"
    A video demonstration of this example is available [here](https://videos.pingidentity.com/detail/videos/devops/video/6313575361112/getting-started-walkthrough).

!!! note "Version"
    This example was written using Docker Desktop with Kubernetes enabled on the Mac platform.  The version used for this guide was `4.17.0 (99724)`, which includes Docker Engine `v20.10.23` and Kubernetes `v1.25.4`.  The ingress-nginx controller version was `1.6.4`.

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

    1.  This example will use the Helm release name `demo` and DNS domain suffix `*ping-local.com` for accessing applications.  Add all expected hosts to `/etc/hosts`:

        ```sh
        echo '127.0.0.1 demo-pingaccess-admin.ping-local.com demo-pingaccess-engine.ping-local.com demo-pingauthorize.ping-local.com demo-pingauthorizepap.ping-local.com demo-pingdataconsole.ping-local.com demo-pingdelegator.ping-local.com demo-pingdirectory.ping-local.com demo-pingfederate-admin.ping-local.com demo-pingfederate-engine.ping-local.com demo-pingcentral.ping-local.com' | sudo tee -a /etc/hosts > /dev/null
        ```

    1. To install the chart, go to your local `"${PING_IDENTITY_DEVOPS_HOME}"/pingidentity-devops-getting-started/30-helm` directory and run the command shown here.  In this example, the release (deployment into Kubernetes by Helm) is called `demo`, forming the prefix for all objects created. The `ingress-demo.yaml` file configures the ingresses for the products to use the **_ping-local_** domain:

        ```sh
        helm upgrade --install demo pingidentity/ping-devops -f everything.yaml -f ingress-demo.yaml
        ```

        The product Docker images are automatically pulled if they have not previously been pulled from [Docker Hub](https://hub.docker.com/u/pingidentity/).

        Sample output:

         ```text
         Release "demo" does not exist. Installing it now.
         NAME: demo
         LAST DEPLOYED: Tue Mar 14 13:42:13 2023
         NAMESPACE: pinghelm
         STATUS: deployed
         REVISION: 1
         TEST SUITE: None
         NOTES:
         #-------------------------------------------------------------------------------------
         # Ping DevOps
         #
         # Description: Ping Identity helm charts - 3/03/2023
         #-------------------------------------------------------------------------------------
         #
         #           Product          tag   typ  #  cpu R/L   mem R/L  Ing
         #    --------------------- ------- --- -- --------- --------- ---
         #    global                2302              0/0       0/0     √
         #
         #  √ pingaccess-admin      2302    sts  1    0/2     1Gi/4Gi   √
         #  √ pingaccess-engine     2302    dep  1    0/2     1Gi/4Gi   √
         #  √ pingauthorize         2302    dep  1    0/2    1.5G/4Gi   √
         #    pingauthorizepap
         #    pingcentral
         #  √ pingdataconsole       2302    dep  1    0/2    .5Gi/2Gi   √
         #    pingdatasync
         #    pingdelegator
         #  √ pingdirectory         2302    sts  1  50m/2     2Gi/8Gi   √
         #    pingdirectoryproxy
         #  √ pingfederate-admin    2302    dep  1    0/2     1Gi/4Gi   √
         #  √ pingfederate-engine   2302    dep  1    0/2     1Gi/4Gi   √
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
           demo-pingaccess-admin           ClusterIP   10.106.227.103   <none>        9090/TCP,9000/TCP         15m
           demo-pingaccess-admin-cluster   ClusterIP   None             <none>        <none>                    15m
           demo-pingaccess-engine          ClusterIP   10.108.102.245   <none>        3000/TCP                  15m
           demo-pingauthorize              ClusterIP   10.110.95.132    <none>        443/TCP                   15m
           demo-pingauthorize-cluster      ClusterIP   None             <none>        1636/TCP                  15m
           demo-pingdataconsole            ClusterIP   10.97.81.22      <none>        8443/TCP                  15m
           demo-pingdirectory              ClusterIP   10.102.91.214    <none>        443/TCP,389/TCP,636/TCP   15m
           demo-pingdirectory-cluster      ClusterIP   None             <none>        1636/TCP                  15m
           demo-pingfederate-admin         ClusterIP   10.99.145.24     <none>        9999/TCP                  15m
           demo-pingfederate-cluster       ClusterIP   None             <none>        7600/TCP,7700/TCP         15m
           demo-pingfederate-engine        ClusterIP   10.108.240.203   <none>        9031/TCP                  15m
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

           * To see the ingresses you will use to access the product, run `kubectl get ingress`. If the ingress controller is configured properly, you should see `localhost` as the address as shown here:

           ```text
           NAME                       CLASS    HOSTS                                     ADDRESS     PORTS     AGE
           demo-pingaccess-admin      <none>   demo-pingaccess-admin.ping-local.com      localhost   80, 443   5m23s
           demo-pingaccess-engine     <none>   demo-pingaccess-engine.ping-local.com     localhost   80, 443   5m23s
           demo-pingauthorize         <none>   demo-pingauthorize.ping-local.com         localhost   80, 443   5m23s
           demo-pingdataconsole       <none>   demo-pingdataconsole.ping-local.com       localhost   80, 443   5m23s
           demo-pingdirectory         <none>   demo-pingdirectory.ping-local.com         localhost   80, 443   5m23s
           demo-pingfederate-admin    <none>   demo-pingfederate-admin.ping-local.com    localhost   80, 443   5m23s
           demo-pingfederate-engine   <none>   demo-pingfederate-engine.ping-local.com   localhost   80, 443   5m23s
           ```

        !!! error "Address must be localhost"
            If the ingress controller is working properly, the ingress definitions will all report the ADDRESS column as `localhost` as shown above.  If you do not see this entry, then you will not be able to access the services later.  This problem is due to a known error with Docker Desktop and the embedded virtual machine (VM) used on the Mac and Windows platform in combination with the ingress controller. To correct the problem, uninstall the chart as instructed at the bottom of this page and restart Docker Desktop.  Afterward, you can re-run the helm command to install the Ping products as instructed above.  The [issue appears to be related to a stale networking configuration](https://github.com/kubernetes/ingress-nginx/issues/7686) under the covers of Docker Desktop.


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

    !!! note "Certificates"
        This example uses self-signed certificates that will have to be accepted in your browser or added to your keystore.

    With the ingresses in place, you can access the products at these URLs:

    | Product | Connection Details |
    | --- | --- |
    | [PingFederate](https://demo-pingfederate-admin.ping-local.com/pingfederate/app) | <ul> <li>URL: [https://demo-pingfederate-admin.ping-local.com/pingfederate/app](https://demo-pingfederate-admin.ping-local.com/pingfederate/app)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingDirectory](https://demo-pingdataconsole.ping-local.com/console) | <ul><li>URL: [https://demo-pingdataconsole.ping-local.com/console](https://demo-pingdataconsole.ping-local.com/console)</li><li>Server: ldaps://demo-pingdirectory-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAccess](https://demo-pingaccess-admin.ping-local.com/) | <ul><li>URL: [https://demo-pingaccess-admin.ping-local.com/](https://demo-pingaccess-admin.ping-local.com/)</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |
    | [PingAuthorize](https://demo-pingdataconsole.ping-local.com/console) | <ul><li>URL: [https://demo-pingdataconsole.ping-local.com/console](https://demo-pingdataconsole.ping-local.com/console)</li><li>Server: ldaps://demo-pingauthorize-cluster:1636</li><li>Username: administrator</li><li>Password: 2FederateM0re</li></ul> |

3. When you are finished, you can remove the demonstration components by running the uninstall command for helm:

    ```sh
    helm uninstall demo
    ```

## Next Steps

Now that you have deployed a set of our product images using the provided chart, you can move on to deployments using configurations that more closely reflect use cases to be explored.  Refer to the [helm examples](../deployment/deployHelm.md)) page for other typical deployments.

!!! warning "Container logging"
    Maintaining logs in a containerized model is different from the typical server-deployed application.  See [this page](../reference/containerLogging.md) for additional details.
