# PingDirectory upgrade partition example
This directory contains example Helm values files used to test a PingDirectory version upgrade on a single pod before rolling out to the remaining pods.

Start by installing the `1-initial.yaml` file.
```
helm upgrade --install pd-upgrade-example pingidentity/ping-devops -f 1-initial.yaml
```

Then update the Helm release with the `2-partition-upgrade.yaml` file. This will update one of the two PingDirectory pods, but leave the other unchanged.
```
helm upgrade --install pd-upgrade-example pingidentity/ping-devops -f 2-partition-upgrade.yaml
```

Finally, update the Helm release with the `3-rollout-full-upgrade.yaml` file once the upgraded pod becomes ready. This will update the remaining pod.
```
helm upgrade --install pd-upgrade-example pingidentity/ping-devops -f 3-rollout-full-upgrade.yaml
```