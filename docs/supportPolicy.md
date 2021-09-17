# Ping Identity DevOps Support Policy
This Ping Identity Corporation ("Ping Identity") DevOps Support Policy (this "Policy") encompasses all support obligations that Ping Identity has toward you as Ping Identity’s Customer ("Customer").
## Included in Support
Ping Identity supports the following:

* Actively building and maintaining images to be used by the Customer
* Providing the Customer with [Helm deployments](https://helm.pingidentity.com/) and [Helm charts](https://github.com/pingidentity/helm-charts)
* Providing the Customer with DevOps tooling, such as `config export` and `pingctl`
* Providing the Customer with all owned DevOps reference materials and best practice guides
* Assisting the Customer in understanding the Ping Identity DevOps approach. This includes the approach to server profiles and configuring Kubernetes:
    * Providing recommendations on node sizing and pod distribution for Kubernetes clusters
    * Identifying resources such as CPU and memory required for implementation by Ping products, based on factors such as deployment model and performance requirements
    * Specifying the ports to be exposed by the products and which would be public or internal to the Kubernetes cluster only
* Assisting the Customer in customizing and using server profiles which includes the following:
    * Customizing server profiles to create the desired server configuration:
        * Pre-start configuration
        * Managing secrets, including Ping Identity product licenses, encryption keys, deployment passwords, and certificates
        * Deployment of customizations to server configuration
        * Deployment of customizations to product files on the file system, including templates, properties files, localizations, and integration kits
        * Schema customizations
        * DIT customizations
        * User loads
        * `dsconfig` configuration, such as indexes and password policies
    * Customizing server profiles to create the desired environmental configuration, including modifying `kustomization.yaml` files such as:
        * Ingress endpoints
        * Ingress ports
        * Naming and virtual hosts
## Excluded from Support
Ping Identity does not support the following:

* Configuring Kubernetes in any form, including standalone, EKS, AKS, and GKE
* Configuring any container runtime environment such as Docker
* Non-Kubernetes orchestration tools or any tools that are not part of the Ping Identity DevOps solution set
* Any DevOps deployment outside of Ping Identity supported platforms
* The conversion of profiles from git to other solutions
* Direct integration with any continuous integration and continuous deployment (CI/CD) tools
* Managing Cloud Ingress
* Custom Kubernetes manifest files.
  >_Note:_ To generate manifests, rely on the provided Helm charts
* Customer-built Docker Images
* Third-party tooling used in reference examples
* Modifying existing out-of-the-box hook scripts
  >_Note:_ Escalate issues with hook scripts to the Ping Identity product team. Creating new hook scripts to support deployment is supported.

*Ping Identity reserves the right to deviate from the non-supported list on a case-by-case basis.*