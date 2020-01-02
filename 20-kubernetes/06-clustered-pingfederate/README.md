# 06-clustered-pingfederate

The `kustomization.yaml` in this directory builds on top of `/01-standalone` to have pingfederate in cluster: 
1. Removes the engine port (9031) from the "pingfederate" deployment and service
2. Adds a cluster port (7600) to the "pingfederate" deployment and service
3. Create a separate deployment for "pingfederate-engine" (this would be the ployment in which we would scale # replicas)
4. add a base profile (pf-dns-ping-clustering) that has:
  - tcp.xml.subst
  - run.properties.subst
5. add environment variables to pass clustering information
NOTE: in some situations, the engine may create a cluster before the admin, thus creating cluster silos. 
TODO:  This can be overcome by using an init container.


## pre-reqs

- envsubst
- pingfederate version 10+

## Running

A variable for which namespace this should be deployed to is necessary. 
If you've followed the quickstart, or have the below variable set, then the command is fine. If not, run `export PING_IDENTITY_K8S_NAMESPACE=<some_k8s_namespace>`

1. Kick off the cluster: 
```
kustomize build . | envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | kubectl apply -f -
```

2. Wait for the pingfederate-engine pod to be running, then validate clustering has worked. you can port-forward the admin service and look at clustering via the admin console. 
```
kubectl port-forward svc/pingfederate 9999:9999
```

3. Scale up the engines: 
```
kubectl scale deployment pingfederate-engine --replicas=2
```

## Cleanup: 

```
kustomize build . | envsubst '${PING_IDENTITY_K8S_NAMESPACE}' | kubectl delete -f -
```