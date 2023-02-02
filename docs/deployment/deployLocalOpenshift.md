---
title: Deploy a Local Openshift Cluster
---
# Deploy a Local Openshift Cluster

!!! warning "Demo Use Only"
    The instructions in this document are for testing and learning, and not intended for use in production.

!!! note "Licensing"
    Openshift is a licensed product following the open source model where "upstream" versions are available under community licensing, but the official release supported by [Red Hat](https://www.redhat.com/en) requires a subscription in order to access the software for installation.  This guide assumes the user has access to such a license.  Red Hat provides a [free Developer account](https://developers.redhat.com/blog/2016/03/31/no-cost-rhel-developer-subscription-now-available) that allows a participant to obtain a 60-day license of the supported Openshift product at no charge.

!!! note "Video Demonstration"
    A video demonstration of the process outlined on this page is available [here](https://videos.pingidentity.com/detail/videos/devops/video/6319613511112/openshift-local-demonstration).

Some customers are using Openshift as their platform for running Ping containerized applications.  If this is the case, access to an Openshift cluster is assumed.  Even in those cases, there are times where a local implementation of Openshift for development and testing is convenient.  

!!! note "Platform"
    For this guide, the Apple MacBook Pro platform is used, and the release of the _Red Hat Openshift Local_ offering is version 2.13.1

The [Openshift Local](https://access.redhat.com/documentation/en-us/red_hat_openshift_local/2.13) offering is used in this guide. This page was derived from the [documentation](https://access.redhat.com/documentation/en-us/red_hat_openshift_local/2.13/html/getting_started_guide/index) provided by Red Hat along with a workaround to a bug that has not yet been addressed regarding the Openshift client on the Apple Mac platform.

## Prerequisites

* Entitlement for Openshift code.  If you have registered for the Red Hat developer program, you can obtain your entitlement for the free trial [from the portal](https://developers.redhat.com/products/openshift/download) after logging in.
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [Openshift client (oc)](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.11/html-single/cli_tools/index#cli-getting-started)
* ports 80, 443 and 6443 available on machine. If you have Docker Desktop installed, you must either disable Kubernetes or stop Docker in order for the installation to work.
* **sudo** privileges on your hosting environment

## Configuration and Setup

1. [Install the Red Hat Openshift Local binary](https://console.redhat.com/openshift/create/local) for your platform. When you download the installer, also download the pull secret.

1. With the `crc` utility installed, configure settings.  Provide as much RAM and CPU as you can, depending on your system.  In this example, 16 GB of RAM, 7 vCPUs, and a disk size of 80GB are set.  The consent-telemetry is optional, depending on whether you consent to usage data metrics being sent to Red Hat.

    ```txt
    crc config set memory 16384
    crc config set cpus 7
    crc config set consent-telemetry no
    crc config set disk-size 80

    # Confirm
    crc config view

    - consent-telemetry                     : no
    - cpus                                  : 7
    - disk-size                             : 80
    - memory                                : 16384
    ```

1. Set up your local machine for running Red Hat Openshift Local by running **crc setup**:

    ```txt
    crc setup

    # Output
    INFO Using bundle path /Users/davidross/.crc/cache/crc_vfkit_4.11.18_amd64.crcbundle
    INFO Checking if running as non-root
    INFO Checking if crc-admin-helper executable is cached
    INFO Checking for obsolete admin-helper executable
    INFO Checking if running on a supported CPU architecture
    INFO Checking minimum RAM requirements
    INFO Checking if crc executable symlink exists
    INFO Creating symlink for crc executable
    INFO Checking if running emulated on a M1 CPU
    INFO Checking if vfkit is installed
    INFO Checking if CRC bundle is extracted in '$HOME/.crc'
    INFO Checking if /Users/davidross/.crc/cache/crc_vfkit_4.11.18_amd64.crcbundle exists
    INFO Getting bundle for the CRC executable
    INFO Downloading bundle: /Users/davidross/.crc/cache/crc_vfkit_4.11.18_amd64.crcbundle...
    3.15 GiB / 3.15 GiB [------------------------------------------] 100.00% 46.12 MiB p/s
    INFO Uncompressing /Users/davidross/.crc/cache/crc_vfkit_4.11.18_amd64.crcbundle
    crc.img: 31.00 GiB / 31.00 GiB [-------------------------------] 100.00%
    INFO Checking if old launchd config for tray and/or daemon exists
    INFO Checking if crc daemon plist file is present and loaded
    Your system is correctly setup for using CRC. Use 'crc start' to start the instance
    ```

1. Start the Red Hat Openshift Local instance:

    ```txt
    crc start
 
    # Output
 
    INFO Checking if running as non-root
    INFO Checking if crc-admin-helper executable is cached
    INFO Checking for obsolete admin-helper executable
    INFO Checking if running on a supported CPU architecture
    INFO Checking minimum RAM requirements
    INFO Checking if crc executable symlink exists
    INFO Checking if running emulated on a M1 CPU
    INFO Checking if vfkit is installed
    INFO Checking if old launchd config for tray and/or daemon exists
    INFO Checking if crc daemon plist file is present and loaded
    INFO Loading bundle: crc_vfkit_4.11.18_amd64...
    INFO Creating CRC VM for openshift 4.11.18...
    INFO Generating new SSH key pair...
    INFO Generating new password for the kubeadmin user
    INFO Starting CRC VM for openshift 4.11.18...
    INFO CRC instance is running with IP 127.0.0.1
    INFO CRC VM is running
    INFO Updating authorized keys...
    INFO Resizing /dev/vda4 filesystem
    INFO Configuring shared directories
    INFO Check internal and public DNS query...
    INFO Check DNS query from host...
    INFO Verifying validity of the kubelet certificates...
    INFO Starting kubelet service
    INFO Waiting for kube-apiserver availability... [takes around 2min]
    INFO Adding user's pull secret to the cluster...
    INFO Updating SSH key to machine config resource...
    INFO Waiting for user's pull secret part of instance disk...
    INFO Changing the password for the kubeadmin user
    INFO Updating cluster ID...
    INFO Updating root CA cert to admin-kubeconfig-client-ca configmap...
    INFO Starting openshift instance... [waiting for the cluster to stabilize]
    INFO 4 operators are progressing: image-registry, network, openshift-controller-manager, service-ca
    INFO 4 operators are progressing: image-registry, network, openshift-controller-manager, service-ca
    INFO 4 operators are progressing: image-registry, network, openshift-controller-manager, service-ca
    INFO 4 operators are progressing: image-registry, network, openshift-controller-manager, service-ca
    INFO 4 operators are progressing: image-registry, network, openshift-controller-manager, service-ca
    INFO 3 operators are progressing: image-registry, network, openshift-controller-manager
    INFO Operator image-registry is progressing
    INFO All operators are available. Ensuring stability...
    INFO Operators are stable (2/3)...
    INFO Operator authentication is progressing
    INFO Operator authentication is progressing
    INFO Operator authentication is progressing
    INFO Operator authentication is progressing
    INFO Operator authentication is progressing
    INFO Operator authentication is progressing
    INFO Operator authentication is progressing
    INFO Operator authentication is progressing
    ERRO Cluster is not ready: cluster operators are still not stable after 10m0.746213711s
    INFO Adding crc-admin and crc-developer contexts to kubeconfig...
    Started the OpenShift cluster.
    
    The server is accessible via web console at:
      https://console-openshift-console.apps-crc.testing
    
    Log in as administrator:
      Username: kubeadmin
      Password: 3hT2A-JJv5U-VAJia-RNpSs
    
    Log in as user:
      Username: developer
      Password: developer
    
    Use the 'oc' command line interface:
      $ eval $(crc oc-env)
      $ oc login -u developer https://api.crc.testing:6443
    ```

    Depending on the speed of your system, this will take 8 to 15 minutes.  There is a 10 minute timeout on checking the stability of operators deployed by Openshift.  It might be the case that the tool reports these have not reached full stability in that window.  In the writing of this guide, no issues were found using Openshift deployed in this manner, even if the error occurs.  Each time these steps were tested, everything eventually reached a healthy status, but just not in the window expected.  You can see this error at the end of the output displayed above (Cluster is not ready).

### Mac bug workaround

1. On the Mac platform only, you might have to work around a certificate issue.  This situation is not a problem on other platforms.  You can follow [this ticket](https://bugzilla.redhat.com/show_bug.cgi?id=2097830) to see when it is addressed; it was still open at the time of this writing.

    The issue appears when you attempt to login at the command line, resulting in an x509 certificate error as shown here:

    ```txt
    oc login -u developer https://api.crc.testing:6443
    error: x509: “ingress-operator@1655391148” certificate is not trusted
    ```

    The workaround to this error is to trust two certificates in the Apple Keychain Access utility.

2.  Login to the web console as **kubeadmin**, using the credentials displayed when starting the instance.  If necessary, you can run `crc console --credentials` to display them again.  The console url is [https://console-openshift-console.apps-crc.testing](https://console-openshift-console.apps-crc.testing).

    * In the web console, select the **Administrator** role from the top of the left navigation bar.
    * Navigate to **Workloads** > **Secrets** and filter for **external-loadbalancer-serving-certkey**.  It will be in the **openshift-kube-api** server project (namespace).
    * Select the secret.
    * Copy the contents of **tls.crt** to a local file on your Mac
    * Open the file with the keychain application and add the certificate to the system keychain.
    <img src="/../images/openCertificate.png"/>
    * Mark the certificate (called **kube-apiserver-lb-signer** in the Keychain UI) as always trusted. Double click to open it, then expand the trust section and make the selection:
     <img src="/../images/alwaysTrust.png"/>
    * Repeat this process for **tls.crt**, found in the **router-ca** secret in the **openshift-ingress-operator** project.  This certificate will be named **ingress-operator@NNN** in the Keychain UI.

    At this point, the command line login will work:

    ```txt
    oc login -u developer -p developer https://api.crc.testing:6443
    
    # Output
    Login successful.

    You don't have any projects. You can try to create a new project, by running

        oc new-project <projectname>
    ```

Setup is complete.  This local environment should be ready to deploy our [Helm examples](./deployHelm.md)

## Stop the Red Hat Openshift Local instance

When not working with the environment, you can stop the instance by running the following command.  All settings, projects and objects created will be retained and available when it is started again.

```sh
crc stop
```

Run `crc start` again to launch the instance.

## Delete the Red Hat Openshift Local instance

You can also remove the instance by running the following command.  If you do this, the embedded VM instance, all objects and projects created will be lost.  A new instance will be deployed the next time you run `crc start`.

```sh
crc delete
```

!!! error "Remove all configuration"
    Deleting the instance does not delete the configuration settings for Red Hat Openshift Local (RAM, CPU, disk, and so on, created or modified when running the `crc config set` command).  If you want to completely remove all configuration, you can delete the $HOME/.crc folder and its contents.  Also, you will need to edit `/etc/hosts` and remove the following aliases to the 127.0.0.1 IP: `api.crc.testing canary-openshift-ingress-canary.apps-crc.testing console-openshift-console.apps-crc.testing default-route-openshift-image-registry.apps-crc.testing downloads-openshift-console.apps-crc.testing oauth-openshift.apps-crc.testing`