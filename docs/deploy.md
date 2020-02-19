# Working with DevOps images

After you've deployed a set of our DevOps images using the full-stack server profile in [Get started](getStarted.md), you're set up to move on to deployments using server profiles that may more closely reflect use cases you want to test out. Your choices at this point are:

* Continue working with the full-stack server profile in your local `pingidentity-devops-getting-started/11-docker-compose/03-full-stack` directory. 
* Try our other server profiles in your local `pingidentity-devops-getting-started` directory to quickly deploy typical use cases:
  * [Deploy standalone product containers](deployStandalone.md).
  * [Deploy a PingFederate and PingDirectory stack](deployCompose.md).
  * [Deploy a replicated PingDirectory pair](deployReplication.md).
  * [Deploy PingDirectory with data synchronization using PingDataSync](deploySync.md).
  * [Deploy a PingFederate cluster](docs/deployPfCluster.md)
  * [Deploy a PingAccess cluster](docs/deployPaCluster.md)
  * [Orchestrate deployments using Docker Swarm](deploySwarm.md).
  * [Orchestrate deployments using Kubernetes](deployKubernetes.md).
  * [Deploy PingCentral](deployPingCentral.md)
* Clone the [`pingidentity-server-profiles`](../../pingidentity-server-profiles) repository to your local `${HOME}/projects/devops` directory and deploy our DevOps images using any of our standard server profiles (not targeted to specific use cases) located in the subdirectories. 

