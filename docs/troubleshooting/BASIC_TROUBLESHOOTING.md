# Troubleshooting

## Contents: 
* [Quickstart Examples](#quickstart-examples)
* [Server Profiles](#server-profiles) (coming soong)
* [Docker Builds](#docker-builds) (coming soon)


## Quickstart Examples

#### Issue: Quickstart Examples Not Working
One of the most common errors that users find when getting started with the provided examples is due to having stale images. Because the images are currently under production, they are untagged and rapidly changing. To avoid issues with stale images, be safe and allow Docker to pull the latest as necessary by removing all Ping Identity images with:
```
docker rmi $(docker images "pingidentity/*" -q)
```

> Note: Just because images are tagged "latest" locally, does not mean they are the latest in the docker hub registry. 