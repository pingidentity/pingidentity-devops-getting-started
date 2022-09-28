---
title: Using DevOps Hooks
---

# Frequently asked questions

### Containers

<details>
  <summary>What are the latest Ping’s version available as docker images?</summary>

The latest Ping's products are tagged with <mark><b>{RELEASE}-{PRODUCT VERSION}</b></mark>. You can find more information about our latest product images at <a href="https://devops.pingidentity.com/docker-images/productVersionMatrix/">Product Version</a>
</details>

<details>
  <summary>Do they come as a product or combined with an OS version?</summary>

The DevOps program uses <mark><b>Alpine</b></mark> as its base OS shim. For more information please visit <a href="https://devops.pingidentity.com/docker-images/imageSupport/#supported-os-shim">Support OS Shim</a>
</details>

<details>
  <summary>I have created custom product installation, if we require a specific image can that be supplied?
</summary>

We currently do not support custom images, but you are able to build the image locally with the customizted bits. For more information please visit <a href="https://devops.pingidentity.com/how-to/buildLocal/">Build Local Image</a>
</details>

### Helm / K8s
<details>
  <summary>How do I access various consoles?</summary>

There are a few ways you can access the consoles.
<p></p>

<p>1. PortFoward the pod to access with localhost.</p>
<p>&emsp; <mark><b>kubectl port-forward &#60;podName&#62; &#60;containerPort&#62;:&#60;localPort&#62;</b></mark></p>
2. With Helm, add the ingress control in the yaml file to access the container with a url. <a href="https://devops.pingidentity.com/deployment/deployHelmLocalIngress/#create-ingresses">Ingress</a>
</details>

### Products
<details>
  <summary>How do I use an existing license?</summary>

You can mount the license in the container's <mark><b>opt/in</b></mark> directory. Please check out <a href="https://devops.pingidentity.com/how-to/existingLicense/">using existing licenses</a> for more information.
</details>

<details>
  <summary>How do I save configurations?</summary>

In order to save configurations we would create a server profile and pass the configuration into the Server profile repo. 
To create a custom server profile please visit <a href="https://devops.pingidentity.com/how-to/profiles/">Server Profile</a>.
<p></p>

<p><b>Examples on how to get the profile data from the different products</b></p>


&emsp; <a href="https://devops.pingidentity.com/how-to/buildPingFederateProfile/">PingFederate</a> Profile
    ```
    curl -k https://localhost:9999/pf-admin-api/v1/bulk/export?includeExternalResources=false \
    -u administrator:2FederateM0re \
    -H 'X-XSRF-Header: PingFederate' \
    -o data.json
    ```
&emsp; PingAccess Profile
    ```
    curl -k https://localhost:9000/pa-admin-api/v3/config/export \ 
    -u administrator:2FederateM0re \
    -H "X-XSRF-Header: PingAccess" \
    -o data.json
    ```
&emsp; <a href="https://devops.pingidentity.com/how-to/buildPingDirectoryProfile/">PingDirectory</a> Profile
    ```
    kubectl exec -it pingdirectory-0 \
    --manage-profile generate-profile \
    --profileRoot /tmp/pd.profile
    ```
</details>

<details>
  <summary>How do I turn off the license verification?</summary>

<mark><b>MUTE_LICENSE_VERIFICATION="true"</b></mark>
</details>

<details>
  <summary>How do I turn off the calls to the Message of the Day (MOTD)?</summary>

<mark><b>MOTD_URL=""</b></mark>
</details>

<details>
  <summary>My container environment is not allowed to make any external calls to services such <br> as Github or Docker Hub. Can I still use Ping Identity containers? </br> </summary>

<p>Yes. This practice is common in production scenarios. To use Ping Identity containers in this situation:</p>

&emsp; <br>1. Use an Existing License</br>
&emsp; <br>2. Use an empty remote profile SERVER_PROFILE_URL="" Optionally, you can build your profile into the image</br>
&emsp; <br>3. Turn off license verification with MUTE_LICENSE_VERIFICATION="true"</br>
&emsp; <br>4. Turn off calls to the Message of the Day (MOTD) with MOTD_URL=""</br>
</details>