---
title: FAQs
---

# Frequently asked questions

### Docker Images

<details>
  <summary>When are new Ping product Docker images released?</summary>

Typically, Docker images are released on a monthly basis during the first full week of the month.  The images are tagged YYMM, with the month indicating the complete month prior.  So, tag "2303", representing the work from March 2023, would be released in early April.  As we mature our processes, the frequency and timing of these images will more closely align with product releases.
</details>

<details>
  <summary>How can I be informed when new images are available?</summary>

You can watch the <a href="https://github.com/pingidentity/pingidentity-docker-builds/">docker-builds GitHub repository</a> for the Ping Identity product line. Select the "custom" option to receive notification when a release occurs.  Releases in the docker-builds repository correspond to the publishing of images in Docker Hub.
</details>

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
  <summary>How can I be informed when a new release of the Helm charts are available?</summary>

You can watch the <a href="https://github.com/pingidentity/helm-charts/">Ping helm-charts GitHub repository</a>. Select the "custom" option to receive notification when a release occurs.  As with the product Docker images, the Helm charts are usually updated once a month.
</details>

<details>
  <summary>Kubernetes has dropped direct integration support for Docker. Does this change impact Ping product containers?</summary>

<p>No. The underlying container runtime has not caused problems with our images.  Please let us know if you encounter errors.  The <mark><b>CRI-O</b></mark> and <mark><b>containerd</b></mark> runtimes have been tested without any known issues.</p>

For more background:<br>

<br>&emsp;The Kubernetes blog post on Docker removal is <a href="https://kubernetes.io/blog/2022/02/17/dockershim-faq/">here</a>.</br>
<br>&emsp;An excellent write up of how it looks is on this  <a href="https://kodekloud.com/blog/kubernetes-removed-docker-what-happens-now/">page</a>.</br>
</details>

<details>
  <summary>My container environment is not allowed to make any external calls to services such as Github or Docker <br> Hub. Can I still use Ping Identity containers? </br> </summary>

<p>Yes. This practice is common in production scenarios. To use Ping Identity containers in this situation:</p>

<br>&emsp;1. Use an <a href="https://devops.pingidentity.com/how-to/existingLicense">Existing License</a>.</br>
<br>&emsp;2. Use an empty remote profile <mark><b>SERVER_PROFILE_URL=""</b></mark>.  Optionally, you can build your profile into the image, visit <a href="https://devops.pingidentity.com/how-to/profiles/">Server Profiles</a> for more information.</br>
<br>&emsp;3. Turn off license verification with <mark><b>MUTE_LICENSE_VERIFICATION="true"</b></mark>.</br>
<br>&emsp;4. Turn off calls to the Message of the Day (MOTD) with <mark><b>MOTD_URL=""</b></mark>.</br>
</details>

<details>
  <summary>How do we run the console and engines in a container environment?</summary>

The helm chart supports instantiating both consoles and engines.  Ingress to the consoles would have to be laid out for UI access.
<p>For more information about the Ping's Helm Charts, please visit <a href="https://helm.pingidentity.com/">Ping Helm</a></p>
</details>

<details>
  <summary>Can I use Podman instead of Docker?</summary>

Yes, just like Docker, you will be able to use Podman for container orchestration.
</details>

<details>
  <summary>Why does Ping recommand K8s vs docker?</summary>

<br>&emsp;1. Docker or a pure container solution like ECS by itself is generally not as robust or resilient as a K8s environment. While managed Docker services like ECS provide some of the functionality of Kubernetes, you are locked into that provider and you would have a different experience at Google, Azure, or another cloud provider. Kubernetes, even managed services like EKS, provides more flexibility and portability.</br>
<br>&emsp;2. It is the model we use for our SaaS offerings, so internal teams at Ping are more familiar with this model.</br>
<br>&emsp;3. Orchestration among multiple applications and services is native to Kubernetes, a bit of an add-on with Container-only services.</br>
<br>&emsp;4. Workload management using Kubernetes native objects, such as Horizontal Pod Autoscaling, Node scaling and so on.</br>
<br>&emsp;5. Management through Infrastructure-as-Code principles using Helm Charts and Values files.</br>
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

### Troubleshoot

<details>
  <summary>How do I run Collect-Support-Data in the devops environment?</summary>

You will need to modify the liveness probe to always exit 0 and the readiness probe to always exit 1. These changes will give you enough time to capture the CSD without it crashing or trying to serve live traffic.
<p>For more information about the Collect-Support-Data, please visit <a href="https://support.pingidentity.com/s/article/collect-support-data-tool">CSD</a>.</p>
</details>

<details>
  <summary>How much overhead memory and CPU is needed to run the Collect-Support-Data tool?</summary>

By default, this value is set to 1GB. You would need to add additional memory (1GB to 2GB) to the heap for the server. In terms of CPU, the CSD uses whatever is available.
<p>For more information about the Collect-Support-Data, please visit <a href="https://support.pingidentity.com/s/article/collect-support-data-tool">CSD</a>.</p>
</details>