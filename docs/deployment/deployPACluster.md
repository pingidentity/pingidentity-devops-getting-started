---
title: Deploy a PingAccess Cluster with PingIdentity Helm Charts Without a Server Profile
---
# Deploy a PingAccess Cluster with PingIdentity Helm Charts Without a Server Profile

!!! warning "Demo Use Only"
    The instructions in this document are for testing and learning and are not intended for use in production.

## Purpose
Create and deploy a PingAccess Cluster using PingIdentity Helm Charts, without having to create a custom server profile. This process will allow you to quickly bring up the PingAccess UI and conduct any tests you need.

## Prerequisites

* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* Access to a Kubernetes cluster

## Steps
1. Confirm that your kuberenetes context and namespace are set correctly

    ```sh
    # Display kuberenetes context
    kubectx

    # Display namespace
    kubens -c
    ```

    If these values are not set or are incorrect, you can set them with the following commands. If you do not yet have a namespace, or do not have access to a kubernetes cluster, refer to [Deploy Example Stack](https://devops.pingidentity.com/get-started/getStartedExample/).

    ```sh
    # Display kuberenetes context
    kubectx <context>

    # Display namespace
    kubens <namespace>
    ```

2. Confirm that there are no conflicting persistent volumes. 

    ```sh
    #List any persistent volumes
    kubectl get pvc
    ```
    If you see a persistent volume with a name that resembles `out-dir-demo-pingaccess-admin-0`, then delete it before deploying you cluster.
    ```sh
    #Delete name_of_pvc persistent volume
    kubectl delete pvc out-dir-demo-pingaccess-admin-0
    ```

!!! warning "Implemetned for Sprint 2211 and onwards"
    This functionality has only been implemented for Sprint tags of 2211 or later. Therefore, it will not work for all earlier tags.

3. Create a YAML file similar to the one shown here. Make sure to replace `insert domain name here` with your domain name.

    ```sh
    global:
    envs:
        PING_IDENTITY_ACCEPT_EULA: "YES"
    ingress:
        enabled: true
        addReleaseNameToHost: prepend
        defaultDomain: "insert domain name here"
        defaultTlsSecret:
        annotations:
            nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
            kubernetes.io/ingress.class: "nginx-public"

    #############################################################
    # pingaccess-admin values
    #############################################################
    pingaccess-admin:
    enabled: true
    privateCert:
        generate: true
    envs: 
        PING_IDENTITY_PASSWORD: "2FederateM0re!"

    #############################################################
    # pingaccess-engine values
    #############################################################
    pingaccess-engine:
    enabled: true
    container:
        replicaCount: 1
    envs: 
        PING_IDENTITY_PASSWORD: "2FederateM0re!"
    ```

4. Create the default PingAccess cluster. Make sure that you fill in the "PATH" to your new values.yaml file. This deployment may take a few minutes to become healthy.

    ```sh
    helm upgrade --install demo pingidentity/ping-devops -f <path-to-yaml>/values.yaml
    ```

5. To display the status of the deployed components, you can use [k9s](https://k9scli.io/) or issue the corresponding commands shown here:

    * Display the services (endpoints for connecting) by running `kubectl get service --selector=app.kubernetes.io/instance=demo`

        ```text
        NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
        demo-pingaccess-admin           ClusterIP   172.20.221.233   <none>        9090/TCP,9000/TCP   37s
        demo-pingaccess-admin-cluster   ClusterIP   None             <none>        <none>              37s
        demo-pingaccess-engine          ClusterIP   172.20.126.86    <none>        3000/TCP            37s
        ```

    * To view the pods, run `kubectl get pods --selector=app.kubernetes.io/instance=demo` - you will need to run this at intervals until all pods have started (** Running ** status):

        ```text
        NAME                                      READY   STATUS            RESTARTS   AGE
        demo-pingaccess-admin-0                   1/1     Running   0          28m
        demo-pingaccess-engine-6b977b9498-298jw   1/1     Running   0          28m
        ```

    * To see the ingresses you will use to access the product, run `kubectl get ingress`. If the ingress controller is configured properly, the URL you will see under demo-pingaccess-admin HOST (`demo-pingaccess-admin.<domain-name>`) will be the URL you use to access the PingAccess management console.

        ```text
        NAME                     CLASS    HOSTS                                    ADDRESS                                                                         PORTS     AGE
        demo-pingaccess-admin    <none>   demo-pingaccess-admin.<domain-name>      adab69408130011eab1cd028479a4fe3-532fea1b3272797d.elb.us-east-2.amazonaws.com   80, 443   2m1s
        demo-pingaccess-engine   <none>   demo-pingaccess-engine.<domain-name>     adab69408130011eab1cd028479a4fe3-532fea1b3272797d.elb.us-east-2.amazonaws.com   80, 443   2m1s
        ```

    * To see everything tied to the helm release run `kubectl get all --selector=app.kubernetes.io/instance=demo`:

        ```text
        NAME                                          READY   STATUS    RESTARTS   AGE
        pod/demo-pingaccess-admin-0                   1/1     Running   0          29m
        pod/demo-pingaccess-engine-6b977b9498-298jw   1/1     Running   0          29m

        NAME                                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
        service/demo-pingaccess-admin           ClusterIP   172.20.221.233   <none>        9090/TCP,9000/TCP   29m
        service/demo-pingaccess-admin-cluster   ClusterIP   None             <none>        <none>              29m
        service/demo-pingaccess-engine          ClusterIP   172.20.126.86    <none>        3000/TCP            29m

        NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
        deployment.apps/demo-pingaccess-engine   1/1     1            1           29m

        NAME                                                DESIRED   CURRENT   READY   AGE
        replicaset.apps/demo-pingaccess-engine-6b977b9498   1         1         1       29m

        NAME                                     READY   AGE
        statefulset.apps/demo-pingaccess-admin   1/1     29m
        ```

    * To view logs, look at the logs for the deployment of the product in question.  For example:

        ```sh
        #Admin pod logs
        kubectl logs demo-pingaccess-admin-0

        #Engine pod logs
        kubectl logs demo-pingaccess-engine-6b977b9498
        ```

6. Below are the credentials and URL to sign on to the PingAccess management console after the cluster is up and healthy.

    !!! note "Certificates"
        This example uses self-signed certificates that will have to be accepted in your browser or added to your keystore.

    With the ingress in place, you can access the product at the URL seen below, using the domain-name you set in you values.yaml file.

    | Product | Connection Details |
    | --- | --- |
    | PingAccess | <ul><li>URL: https://demo-pingaccess-admin.(domain-name)</li><li>Username: Administrator</li><li>Password: 2FederateM0re!</li></ul> |

7. When you are finished, you can remove the demonstration components by running the uninstall command for helm:

    ```sh
    helm uninstall demo
    ```

8. Finally make sure to prune the persistent volume created in the deployment of your PingAccess cluster, by running the delete pvc command for kubectl:

    ```sh
    #Delete name_of_pvc persistent volume
    kubectl delete pvc out-dir-demo-pingaccess-admin-0
    ```