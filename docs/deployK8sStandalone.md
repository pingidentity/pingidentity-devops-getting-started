# Orchestrate standalone deployments

You'll use the standalone configurations in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory as the base product configurations with the server profiles in our [pingidentity-server-profiles/getting-started](../../pingidentity-server-profiles/getting-started) repository.  

The commands in this topic are meant to be used with or without kustomize. When used without kustomize (as the steps in this topic do), the commands will return some benign errors regarding `kustomization.yaml`. An example of a benign kustomize error is: 
```bash
unable to recognize "01-standalone/kustomization.yaml": no matches for kind "Kustomization" in version "kustomize.config.k8s.io/v1beta1"
```

You can deploy a single (standalone) product container, or a set of standalone containers using Kubernetes.

## Deploy the containers

1. Go to any one of the product subdirectories in your local `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory.
2. Orchestrate the deployment using the Kubernetes commands. For example:

   ```bash
   kubectl apply -f pingfederate/
   ```

3. To orchestrate a deployment of all of the products in your `pingidentity-devops-getting-started/20-kubernetes/01-standalone` directory. From your local `pingidentity-devops-getting-started/20-kubernetes` directory, enter: 

   ```bash
   kubectl apply -R -f 01-standalone/
   ```

4. To clean up when you're finished, for a single product container, enter: 

   ```bash
   kubectl delete -f <container>/
   ```

   Where \<container> is the name of a product container (such as, `pingfederate`).

   For all products in the `01-standalone` directory, enter:

   ```bash
   kubectl delete -R -f 01-standalone/
   ```
