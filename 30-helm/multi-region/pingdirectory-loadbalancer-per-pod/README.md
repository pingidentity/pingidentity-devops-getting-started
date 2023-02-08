# PingDirectory multi-region example with one LoadBalancer service per pod
The files in this directory can be used to deploy PingDirectory across multiple Kubernetes clusters, by deploying a separate LoadBalancer service for each individual pod.

Note: our primary recommendation when deploying across multiple clusters is to use [Peered Clusters](https://devops.pingidentity.com/deployment/deployK8s-AWS/), which does not require deploying a separate LoadBalancer for each pod. The key difference in the Helm values for this is example is that `pingdirectory.services.loadBalancerServicePerPod` is set to true, and a hostname suffix for the LoadBalancers is provided via `pingdirectory.services.loadBalancerExternalDNSHostnameSuffix`.

See [Deploy PingDirectory Across Multiple Kubernetes Clusters](https://devops.pingidentity.com/deployment/deployPDMultiRegion/) for details on how to deploy this example.
