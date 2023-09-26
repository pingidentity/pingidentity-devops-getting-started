---
title: DevOps Support Policy
---
# Ping Identity DevOps Support Policy

This DevOps Support Policy is an extension of the [Ping Identity Support Policy](https://www.pingidentity.com/en/legal/support-policy.html).

This Ping Identity Corporation ("Ping Identity") DevOps Support Policy (this "Policy") encompasses all support obligations that Ping Identity has toward you as Ping Identity’s Customer ("Customer").

!!! note "Docker Image Support Policy"
    The support policy for Ping Identity product Docker images is found at [Docker Image Support Policy](../docker-images/imageSupport.md).

## Included in Support

* Providing base images for Ping Identity products to Customers
* Providing documentation and basic examples for [Helm deployments](https://helm.pingidentity.com/) using Ping Identity's [Helm charts](https://github.com/pingidentity/helm-charts)
* Providing the Customer with DevOps tooling, such as `config_export` and `pingctl`
* Providing the Customer direction in using [Server Profile](https://devops.pingidentity.com/how-to/containerAnatomy/) to achieve the following:
    * Deployment
    * Customization
    * Saving Configuration
    * Layering
    * Environment Substitution
    * Private Github repos

## Supported orchestration tools

| Tool                                                         | Description                                                                                                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| [Kubernetes](https://kubernetes.io/)                         | Also known as K8s, Kubernetes is an open-source system for automating deployment, scaling, and management of containerized software. |
| [Helm charts](https://helm.pingidentity.com/)                | Helm is the easiest way to deploy Ping Identity software images in a Kubernetes environment.                                         |
| [Docker images](https://hub.docker.com/u/pingidentity)       | Docker images are maintained by Ping Identity and are a collection of preconfigured environments for Ping Identity products.         |
| [GitHub repositories](https://github.com/topics/ping-devops) | These repositories provide all of the components to build Docker images for your own development, testing and deployments.           |

## Resources

Ping Identity customers can create a case in the [Ping Identity Support Portal](https://support.pingidentity.com/s/).

Non-Ping Identity customers can use the [PingDevOps Community](https://support.pingidentity.com/s/topic/0TO1W000000IF30WAG/pingdevops).