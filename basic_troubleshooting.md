# Troubleshooting

## Contents:

* [Quickstart Examples](basic_troubleshooting.md#quickstart-examples)
* Server Profiles \(coming soong\)
* Docker Builds \(coming soon\)

## Quickstart Examples

### Issue: Quickstart Examples Not Working

One of the most common errors that users find when getting started with the provided examples is due to having stale images. As the docker images are currently undergoing development, they are untagged and rapidly change. To avoid issues with stale images, be safe and allow Docker to pull the latest as necessary by removing all local Ping Identity images with:

```text
docker rmi $(docker images "pingidentity/*" -q)
```

> Note: Just because images are tagged "latest" locally, does not mean they are the latest in the docker hub registry.

