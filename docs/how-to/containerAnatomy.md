---
title: Server Profile Deployment
---
# Deployment

Any configuration that is deployed with one of our product containers can be considered a "server profile". A profile typically looks like a set of files.

You can use profiles in these ways:

* Pull at startup.
* Build into the image.
* Mount as a container volume.

## Pull at startup

Pass a Github-based URL and path as environment variables that point to a server profile.

Pros:

* Easily sharable, inherently source-controlled

Cons:

* Adds download time at container startup

For profiles pulled at startup, the image uses the following variables to clone the repo at startup and pull the profile into the container:

* `SERVER_PROFILE_URL` - The git URL with the server profile.
* `SERVER_PROFILE_PATH` - The location from the base of the URL with the specific server profile.
  This allows for several products server profile to be housed in the same git repo.
* `SERVER_PROFILE_BRANCH` (optional) - If other than the default branch (usually master or main), allows
  for specifying a different branch.  Example might be a user's development branch before merging into master.

Although there is additional customizable functionality, this is the most common way that profiles are provided to containers because it is easy to provide a known starting state as well as track changes over time.  For more information, see [Private Github Repos](privateRepos.md).

## Build into the image

Build your own image from one of our Docker images and copy the profile files in.

Pros:

* No download at startup, and no egress required

Cons:

* Tedious to build images when making iterative changes

Building a profile into the image is useful when you have no access to the Github repository or if you're often spinning containers up and down.

For example, if you made a Dockerfile at this location: https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline, the relevant entries might look similar to this:

```shell
FROM: pingidentity/pingfederate:edge
COPY pingfederate/. /opt/in/.
```

## Mount as a Docker volume

Using `docker-compose` you can bind-mount a host file system location to a location in the container.

Pros:

* Most iterative. There's no download time, and you can see the file system while you are working in the container.

Cons:

* There's no great way to do this in Kubernetes or other platform orchestration tools.

Mount the profile as a Docker volume when you're developing a server profile and you want to be able to quickly make changes to the profile and spin up a container against it.

For example, if you have a profile in same directory as your `docker-compose.yaml` file, you can add a bind-mount volume to /opt/in like this:

```sh
volumes:
   - ./pingfederate:/opt/in
```
