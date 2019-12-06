# Ping Identity DevOps

We enable DevOps professionals, administrators and developers with tools, frameworks, blueprints and reference architectures to deploy Ping Identity software in the cloud.

## Why containerization of Ping Identity solutions?

* **Streamlined deployments** 

  Deploy and run workloads on our solutions without the need for additional hardware or VMs.

* **Consistent and flexible** 

  Maintain all configurations and dependencies, ensuring consistent environments. Containers are portable and can be used on nearly any machine.

* **Optimized sizing** 

  Orchestration of containers allows organizations to increase fault tolerance, availability, and better manage costs by auto-scaling to application demand.
  
We use Docker images of Ping Identity software solutions to provide you with stable, network-enabled containers. For lightweight orchestration purposes, we use Docker Compose. For enterprise-level orchestration of containers, we use Kubernetes.  

## Prerequisites

* Docker for macOS, Linux, or Windows. [For macOS and Windows](https://www.docker.com/products/docker-desktop). Most of our testing has been done on macOS.
* [Git](https://git-scm.com/downloads).

### Requirements for VMs

* External ports to expose: 443, 9000, 8080, 7443, 9031, 9999, 1636-1646, 1443-1453, 8443.
  > There are other ports used for communication between our solutions, but this will occur on the local Docker network. 
* Recommended resources: 30 Gb of storage, 2-4 CPU cores, 10+ Gb memory.
  > On a VM, Docker is allowed full access to machine resources by default. On macOS, because the OS runs docker-engine, you'll need to raise the default allocated resources (in Docker > Preferences > Advanced).

## Choose Your Path

Our documentation will guide you through these pathways:

* Evaluate our solutions. See [Evaluate our solutions](https://github.com/pingidentity/pingidentity-devops-getting-started/docs/evaluate.md)
* Use containers and orchestration built and maintained by us. See [Use DevOps-built containers](https://github.com/pingidentity/pingidentity-devops-getting-started/docs/devopsBuilt.md)
* Build, orchestrate, and maintain your own containers. See [Build your own containers](https://github.com/pingidentity/pingidentity-devops-getting-started/docs/buildYourOwn.md)

None of these pathways are exclusive. Each may fulfill a different purpose as you develop your containerization strategy. If you're uncertain where to start, evaluate our solutions to see how it all works.

## Copyright

Copyright © 2019 Ping Identity. All rights reserved.
