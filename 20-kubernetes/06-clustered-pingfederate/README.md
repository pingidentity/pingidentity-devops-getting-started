# 06-clustered-pingfederate

## What you will do
The `kustomization.yaml` in this directory builds on top of `/01-standalone` to have pingfederate in cluster. 
From this directory, running `kustomize build . | envsubst '${PING_IDENTITY_K8S_NAMESPACE}'`
will generate a kubernetes yaml that includes: 

1. Two deployments:
  - `pingfederate` represents the admin console. 
  - `pingfederate-engine` represents the engine(s)
2. Two Configmaps. One for each deployment. 
  - These configmaps are nearly identical, but define the operational mode separately.
3. The configmaps include a [profile layer](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/pf-dns-ping-clustering) that turns on PingFederate Clustering. This layer simply includes: 
  - tcp.xml.subst
  - run.properties.subst
4. Three Services: 
  - One for each of the two deployments.
  - Plus, one service, `pf-cluster`, that is pointed two by both deployments. This service is dns-queried to find and add nodes to the cluster. 

## PingFederate Engine Lifecycle
Some features are added to the PingFederate Engine Deployment to support zero-downtime configuration deployments. explanations for these features are stored as comments in `pingfederate-engine.yaml`.  

## pre-reqs

- envsubst

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