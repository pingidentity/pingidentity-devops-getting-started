---
title: FAQs
---

# Frequently asked questions

### Docker Images

<details>
  <summary>What are the latest Ping product versions available as Docker images?</summary>

The latest Ping product images are tagged with <mark><b>{RELEASE}-{PRODUCT VERSION}</b></mark>. You can find more information about our latest product images by consulting the <a href="https://devops.pingidentity.com/docker-images/productVersionMatrix/">Product Version matrix</a>.
</details>

<details>
  <summary>Do the images come as product only or combined with an OS layer?</summary>

The DevOps program uses <mark><b>Alpine</b></mark> as its base OS shim for all images. For more information please visit <a href="https://devops.pingidentity.com/docker-images/imageSupport/#supported-os-shim">Supported OS Shim</a>.
</details>

<details>
  <summary>I have created a custom product installation. If we require a specific image, can that be supplied by Ping?
</summary>

We do not provide custom images, but you are welcome to build the image locally with your customized bits. For more information, see <a href="https://devops.pingidentity.com/how-to/buildLocal/">Build Local Images</a>.<br>

It is important to note using a custom image might affect support options and timing.
</details>

### Container Operations

<details>
  <summary>How do files move around when the container starts up?</summary>

To find out how our files are moved at start up, please visit <a href="https://devops.pingidentity.com/reference/config/#file-flowchart-example">File Flowchart</a>.
</details>

<details>
  <summary>How do I turn off the calls to the Message of the Day (MOTD)?</summary>

Set the environment variable in PingBase to: <mark><b>MOTD_URL=""</b></mark>
<p>For more information about the PingBase environment variables, please visit <a href="https://devops.pingidentity.com/docker-images/pingbase/">PingBase</a>.</p>
</details>

<details>
  <summary>How do I get more verbosity in log outputs?</summary>

Set the environment variables in PingBase to: <mark><b>VERBOSE=“true”</b></mark>
<p>For more information about the PingBase environment variables, please visit <a href="https://devops.pingidentity.com/docker-images/pingbase/">PingBase</a></p>
</details>

### Orchestration / Helm / Kubernetes

<details>
  <summary>My container environment is not allowed to make any external calls to services such as Github or Docker <br> Hub. Can I still use Ping Identity containers? </br> </summary>

<p>Yes. This practice is common in production scenarios. To use Ping Identity containers in this situation:</p>

<br>&emsp;1. Use an <a href="https://devops.pingidentity.com/how-to/existingLicense">Existing License</a>.</br>
<br>&emsp;2. Use an empty remote profile <mark><b>SERVER_PROFILE_URL=""</b></mark>.  Optionally, you can build your profile into the image, visit <a href="https://devops.pingidentity.com/how-to/profiles/">Server Profiles</a> for more information.</br>
<br>&emsp;3. Turn off license verification with <mark><b>MUTE_LICENSE_VERIFICATION="true"</b></mark>.</br>
<br>&emsp;4. Turn off calls to the Message of the Day (MOTD) with <mark><b>MOTD_URL=""</b></mark>.</br>
</details>

### Configuration and Server Profile

<details>
  <summary>How do I customize a container?</summary>

There are many ways to customize the container for a Ping product. For example, you can create a customized server profile to save a configuration.
<p>To find more ways on how to customize a container, see <a href="https://devops.pingidentity.com/reference/config/#customizing-the-containers">Customizing Containers</a>.</p>
</details>

<details>
  <summary>How do I save product configurations?</summary>

In order to save configurations, create a server profile and store in a server profile repository.  This repository can be used to pass the configuration into the runtime environment. For help with creating a custom server profile, visit <a href="https://devops.pingidentity.com/how-to/profiles/">Server Profiles</a>.
<p></p>

<p><b>Examples of how to get the profile data from the different products:</b></p>


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
-- manage-profile generate-profile \
--profileRoot /tmp/pd.profile
```
</details>

<details>
  <summary>What should be in my server profile?</summary>

For more information about what information should be in the server profile consist, please visit <a href="https://devops.pingidentity.com/how-to/containerAnatomy/">Container Anatomy</a> and <a href="https://devops.pingidentity.com/reference/profileStructures/">Profile Structures</a>.
</details>

<details>
  <summary>Does my server profile have to be hosted on Github?</summary>

No, it can be any <a href="https://devops.pingidentity.com/how-to/profiles/#using-your-github-repository">Public</a> or <a href="https://devops.pingidentity.com/how-to/privateRepos/">Private</a> git repository.
<p>You are also able to use a <a href="https://devops.pingidentity.com/how-to/profiles/#using-local-directories">Local Directory</a> as your repository, which is convenient for testing and development.</p>
</details>

### Product related

<details>
  <summary>How do I access various product consoles?</summary>

For a Helm-deployed stack, there are two basic ways you can access the consoles.
<p></p>

<p>1. PortForward to the pod to access with localhost.</p>
<p>&emsp; <mark><b>kubectl port-forward &#60;podName&#62; &#60;containerPort&#62;:&#60;localPort&#62;</b></mark></p>
2. Using Helm, add the ingress definition in the yaml file in order to access the container with a URL. See <a href="https://devops.pingidentity.com/deployment/deployHelmLocalIngress/#create-ingresses">Creating Ingresses</a>. You must have an ingress controller in your cluster for the ingress to work.
</details>

<details>
  <summary>How do I use an existing license?</summary>

You can mount the license in the container's <mark><b>opt/in</b></mark> directory. Please see <a href="https://devops.pingidentity.com/how-to/existingLicense/">using existing licenses</a> for more information.
</details>

<details>
  <summary>How do I turn off the license verification?</summary>

Set the environment variable in PingBase to: <mark><b>MUTE_LICENSE_VERIFICATION="true"</b></mark>
<p>For more information about the PingBase environment variables, please visit <a href="https://devops.pingidentity.com/docker-images/pingbase/">PingBase</a>.</p>
</details>

