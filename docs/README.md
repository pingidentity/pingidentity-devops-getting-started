# Ping Identity DevOps

The goal of Ping Identity DevOps is to enable DevOps, administrators and developers with tools, frameworks, blueprints and reference architectues to deploy Ping Identity software in the cloud.

## Why Containerization?

**Deployments with Confidence** - Maintain all configurations and dependencies ensuring consistent environments. Eliminate the "it works on my machine" problem.

**Cloud Flexibility** - Containers are portable. All major cloud providers have embraced containers and have added support.

**Right-Size** - Orchestration alows businesses to increase fault tolerance, availability and cost management by auto scaling to application demand.

## Before You Begin - Choose Your Path

There are different goals that you may have as you approach these docs. Here are some suggested paths, based on your goals:

* **Learn to use Ping Identity provided images** - if you are looking to learn how to use docker images that are _built and maintained_ by Ping to achieve the mentioned benefits of containerization: 
  1. Get an [evaluation license](https://pingidentity-devops.gitbook.io/devops/prod-license#obtaining-a-ping-identity-devops-user-and-key) or use an [existing one](https://pingidentity-devops.gitbook.io/devops/prod-license#using-an-existing-product-license-file)
  2. Go through the [examples](https://pingidentity-devops.gitbook.io/devops/getting-started-examples) as tutorials. Start with [quickstart](../examples/quickstart.md) as it contains important setup and background. Then skip ahead if you are comfortable.
  3. Make sure you stop by and understand how to use [server profiles](https://pingidentity-devops.gitbook.io/devops/server-profiles). Certain profiles are provided as samples. Once you begin customizing to your purpose, you'll want to create your own server profiles.
* **Quickly Evaluate a Ping Identity software product** - if you heard this is the fastest way test out product features \(especially for integrated cases\) and want minimum interaction with outside tooling. 
  1. Get an [evaluation license](https://pingidentity-devops.gitbook.io/devops/prod-license#obtaining-a-ping-identity-devops-user-and-key)
  2. Save your DevOps User and Key in a text file. Example file:

     ```text
     PING_IDENTITY_DEVOPS_USER=jsmith@example.com
     PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
     ```

     > Be sure to use the exact variable names.

  3. Achieve these pre-reqs on your machine: 
     * Install [Docker CE](https://docs.docker.com/v17.12/install/). [If using a mac](https://docs.docker.com/v17.12/docker-for-mac/install/) 
     * Install [Git](https://git-scm.com/downloads) and run `git clone https://github.com/pingidentity/pingidentity-devops-getting-started.git`
  4. Deploy the software [full-stack](https://pingidentity-devops.gitbook.io/devops/getting-started-examples/11-docker-compose/03-full-stack). 
  5. Make sure to persist your work by [mounting to a local volume.](https://pingidentity-devops.gitbook.io/devops/getting-started-examples/11-docker-compose#persisting-container-state-and-data)
* **Build your own images** - if your organization has certain requirements that are not met by the maintained images, you can use the Docker Builds for the maintained images as a baseline to create your own: 
  1. Look through the [Ping Identity Docker Builds](https://github.com/pingidentity/pingidentity-docker-builds) repo
  2. Understand [Hooks](https://pingidentity-devops.gitbook.io/devops/docker-builds/docker_builds_hooks)

## Documentation Sets

| Document | Audience |
| :--- | :--- |
| [Getting Started](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/586b6b3e00fd57716847a6575f07ddf5dd347b34/README.md) | Operations, Administrators |
| [Server Profiles](../server-profiles/) | Developers |
| [Docker Builds](../docker-builds/) | DevOps Experts |

## Commercial Support

THE SOFTWARE PROVIDED HEREUNDER IS PROVIDED ON AN "AS IS" BASIS, WITHOUT ANY WARRANTIES OR REPRESENTATIONS EXPRESS, IMPLIED OR STATUTORY.

Please contact devops\_program@pingidentity.com for details

## Copyright

Copyright © 2019 Ping Identity. All rights reserved.

