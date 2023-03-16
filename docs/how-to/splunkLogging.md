---
title: Forwarding Logs
---
# Forwarding PingFederate logs to Splunk

This page provides an example of how PingFederate logs can be shipped to Splunk.

!!! note "Demonstration Only"
    This guide is only for demonstration purposes, but the principles will apply to a production implementation.

## Components Used

1. PingIdentity DevOps Helm Chart.
1. Splunk deployment
1. splunk Universal Forwarder

Pre-Req:

- Kubernetes cluster
- helm pingidentity/ping-devops chart >= 0.6.4 

> Note: the ingress and some names may not work in all environments, be ready to adjust as needed. 


## Brief Description

This is meant to be used as an demo example, with parts that can be adjusted as needed. 
This demo is intended to follow good microservice principle in which a container should be used for a single purpose, as such logs collection and forwarding is done via a sidecar in the Ping Product k8s deployments. 


This doc is built off of: 

  * PF Logs formatting for Splunk: https://docs.pingidentity.com/bundle/pingfederate-103/page/qst1564002981075.html
  * PF Dashboard reference: https://docs.pingidentity.com/bundle/pingfederate-100/page/cmn1580335292058.html
  * splunk universal forwarder in k8s: https://computingforgeeks.com/send-logs-to-splunk-using-splunk-forwarder/
  * splunk config for inputs via http: https://faun.pub/logging-in-kubernetes-using-splunk-c2785948fdc0


Steps consist of: 

1. Deploy splunk enterprise in k8s for demo (you should be able to use your own or splunk cloud as well. )

1. Create configs in Splunk, pull a HEC token. 

1. Create a configmap that contains Splunk Universal Forwarder (UF) config. 

1. Deploy pingfederate via helm with Splunk UF as a sidecar. 


Start by getting splunk running: 

```
kubectl apply -f splunk/splunk.yaml
```

Splunk is not exposed via ingress by default, if you would like to use an ingress, update and apply the example at `splunk/ingress.yaml`

Then in the splunk UI: 

* Create index - named pinglogs
* Create Data Input -> HTTP Event Collector (named pinglogs). 
  * save the token that is genereated at the end of this. 
* add the PingFederate, PingAccess, and PingDirectory Apps for Splunk. 

Now that you have an HEC token, update it on the line with #CHANGEME in `splunk/splunk-config-init.yaml`. Then:

```
kubectl apply -f splunk/splunk-config-init.yaml
```

Finally deploy the ping stack with Splunk UF as a sidecar: 

```
helm upgrade --install myping pingidentity/ping-devops -f values.yaml
```

This deploys PingDirectory, PingFederate, and PingAccess with:
  - Baseline Server Profile
  - Splunk Logs Profile layer. 
  - Splunk UF sidecar for PingAccess and PingFederate. 

Eventually you should see products logs making it in via Search & Reporting: 

For PingAccess and Pingfederate search: `index="main"`

For PingDirectory:

```
| mstats count(*) WHERE index="metrics" AND source="udp:9990"
```

![](img/pf-logs.png)


Then generate some traffic in the products to populate the dashboards: 
  - PingFederate use OAuthPlayground
  - PingAccess use https://<pingaccess-ingress>/anything
  - PingDirectory exec into the container and use searchrate/modrate:
    ```
    kubectl exec -it myping-pingdirectory-0 -- sh
    searchrate --hostname localhost --port 1636 \
      --bindDN cn=administrator --bindPassword 2FederateM0re \
      --baseDN dc=example,dc=com --scope sub \
      --filter '(uid=user.[0-4])' --numThreads 2
    ```

Then in the Apps for Splunk you will see data (may need to click submit or update variable boxes at the top): 

![](img/pf-dashboard.png)

