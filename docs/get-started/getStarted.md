---
title: Kubernetes Get Started
---
# Get Started

This section outlines ways to quickly deploy containerized images of Ping Identity products.

Ping Identity images should be compatible across a variety of container platforms including Docker and [Kubernetes](https://www.cncf.io/certification/software-conformance/) (via [Helm Charts](https://helm.pingidentity.com/)). The configurations provided here are designed to launch working instances of our products either as standalone containers or in orchestrated sets.

### Prerequisites

* Access to a Kubernetes cluster, such as the Rancher Desktop environment mentioned above. K8s access implies you have [kubectl](https://kubernetes.io/docs/tasks/tools/) installed.


### Recommended Additional Utilities
* [k9s](https://k9scli.io/)
    ```sh
    brew install derailed/k9s/k9s
    ```
* [kubectx](https://github.com/ahmetb/kubectx)
    ```sh
    brew install kubectx
    ```
* [docker-compose](https://docs.docker.com/compose/install/)
    ```sh
    brew install docker-compose
    ```

    !!! info docker-compose installation note
          Installing docker-compose is only necessary to deploy [Docker containers](getStartedWithGitRepo.md)when using docker with Rancher Desktop.  It is included with [Docker Desktop](https://www.docker.com/products/docker-desktop/)
          
          See [Rancher preferences](https://docs.rancherdesktop.io/preferences#container-runtime) to switch from containerd to dockerd (moby).

### Product license

You must have a product license to run our images. You may either:

* Generate an evaluation license obtained with a valid DevOps user key. For more information, see [DevOps Registration](../how-to/devopsRegistration.md).

* Use a valid product license available with a current Ping Identity customer subscription after DevOps Registration completion.

