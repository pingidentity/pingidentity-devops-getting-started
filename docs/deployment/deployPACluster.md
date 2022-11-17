---
title: Deploy a PingAccess Cluster Locally Without a Server Profile
---
# Deploy a PingAccess Cluster Locally Without a Server Profile

!!! warning "Demo Use Only"
    The instructions in this document are for testing and learning and are not intended for use in production.

## Purpose
Create and deploy a default PingAccess Cluster, without having to create a custom server profile. This process will allow you to quickly bring up the PingAccess UI and conduct any tests you need.

## Prerequisites

* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
## Steps
1. Confirm that your kuberenetes context and namespace are set correctly

    ```sh
    # Display kuberenetes context
    kubectx

    # Display namespace
    kubens -c
    ```

    1. If these values are not set or are incorrect, you can set them with the following commands. If you do not yet have a namespace, or do not have access to a kubernetes cluster, refer to [Deploy Example Stack](https://devops.pingidentity.com/get-started/getStartedExample/).

        ```sh
        # Display kuberenetes context
        kubectx ${context}

        # Display namespace
        kubens ${namespace}
        ```
1. Confirm that there are no persistent volumes

    ```sh
    #List any persistent volumes
    kubectl get pvc

    #Delete name_of_pvc persistent volume
    kubectl delete pvc <name_of_pvc>
    ```

1. Create a YAML file like below. Make sure to replace "image-repository" and "tag_name" with the repository and tag which you wish to pull and build.

    ```sh
    global:
    envs:
        PING_IDENTITY_ACCEPT_EULA: "YES"
    ingress:
        enabled: true
        addReleaseNameToHost: prepend
        defaultDomain: ping-devops.com
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
    image:
        repositoryFqn: ${image-repository}/pingaccess
        tag: ${tag_name}
    envs: 
        PING_IDENTITY_PASSWORD: "2FederateM0re!"

    #############################################################
    # pingaccess-engine values
    #############################################################
    pingaccess-engine:
    enabled: true
    container:
        replicaCount: 1
    image:
        repositoryFqn: ${image-repository}/pingaccess
        tag: ${tag_name}
    envs: 
        PING_IDENTITY_PASSWORD: "2FederateM0re!"
    ```

1. Create the default PingAccess cluster. Make sure that you fill in the "PATH" to your new values.yaml file. This deployment may take a few minutes to become healthy.

    ```sh
    helm upgrade --install demo pingidentity/ping-devops -f ${PATH}/values.yaml
    ```

1. To display the status of the deployed components, you can use [k9s](https://k9scli.io/) or issue the corresponding commands shown here:

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

    * To see the ingresses you will use to access the product, run `kubectl get ingress`. If the ingress controller is configured properly, the URL you will see under demo-pingaccess-admin HOST (`demo-pingaccess-admin.ping-devops.com`) will be the URL you use to access the PingAccess management console.

        ```text
        NAME                     CLASS    HOSTS                                    ADDRESS                                                                         PORTS     AGE
        demo-pingaccess-admin    <none>   demo-pingaccess-admin.ping-devops.com    adab69408130011eab1cd028479a4fe3-532fea1b3272797d.elb.us-east-2.amazonaws.com   80, 443   2m1s
        demo-pingaccess-engine   <none>   demo-pingaccess-engine.ping-devops.com   adab69408130011eab1cd028479a4fe3-532fea1b3272797d.elb.us-east-2.amazonaws.com   80, 443   2m1s
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

1. Below are the credentials and URL to sign on to the PingAccess management console after the cluster is up and healthy.

    !!! note "Certificates"
        This example uses self-signed certificates that will have to be accepted in your browser or added to your keystore.

    With the ingress in place, you can access the product at this URL:

    | Product | Connection Details |
    | --- | --- |
    | [PingAccess](https://demo-pingaccess-admin.ping-devops.com/) | <ul><li>URL: [https://demo-pingaccess-admin.ping-devops.com/](https://demo-pingaccess-admin.ping-devops.com/)</li><li>Username: Administrator</li><li>Password: 2FederateM0re!</li></ul> |

3. When you are finished, you can remove the demonstration components by running the uninstall command for helm:

    ```sh
    helm uninstall demo
    ```