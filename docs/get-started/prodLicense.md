# DevOps Product Licenses

In order to run the Ping Identity DevOps images, a valid product license is required. There are several ways to obtain a product license to run the images:

#### Evaluation License

By registering for Ping Identity's DevOps program, you'll be issued credentials that will automate the process of retrieving evaluation product license.

!!! warning "Evaluation License"
    Please note that evaluation licenses are short lived (30 days) and **must not** be used in production deployments.

Evaluation licenses can only be used with images published in the last 90 days.
If you wish to continue to use an image that was published more than 90 days ago, you must obtain a product license.
Once you have product license for the product and version of the more-than-90-days-old image, follow the instructions to [mount the product license](#mount-existing-product-license).

* [Using your DevOps User/Key](#using-your-devops-user-and-key)

#### Existing License

* [Mount Existing Product License](#mount-existing-product-license)

## Using Your DevOps User and Key

When starting an image, you can provide your devops property file `~/.pingidentity/devops` or using the individual environment variables.

>The examples provided for docker-compose are set up to use this property file by default.

For more detail, run the `ping-devops info` to get your DevOps environment information.

### Example Docker Run Command

An example of running a docker image using the `docker run` command would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

```sh
docker run \
  --name pingdirectory \
  --publish 1389:389 \
  --publish 8443:443 \
  --detach \
  --env SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
  --env SERVER_PROFILE_PATH=getting-started/pingdirectory \
  --env-file ~/.pingidentity/devops \
  pingidentity/pingdirectory
```

### Example YAML file

An example of running a docker image using any docker .yaml file would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

```yaml
...
  pingdirectory:
    image: pingidentity/pingdirectory
    env_file:
      - ${HOME}/.pingidentity/devops
    environment:
      - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_PATH=getting-started/pingdirectory
...
```

### Example Inline Env Variables

An example of running a docker image using any docker .yaml file would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

```yaml
...
  pingdirectory:
    image: pingidentity/pingdirectory
    environment:
      - SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git
      - SERVER_PROFILE_PATH=getting-started/pingdirectory
      - PING_IDENTITY_DEVOPS_USER=jsmith@example.com
      - PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
...
```

## Mount Existing Product License

You can pass the license file to a container via mounting to the container's `/opt/in` directory.

Note: You do not need to do this if you are using your DevOps User/Key. If you have provided license files via the volume mount and a DevOps User/Key, it will ignore the DevOps User/Key.

The `/opt/in` directory overlays files onto the products runtime filesystem, the license needs to be named correctly and mounted in the exact location the product checks for valid licenses.

### Example Mounts

|  Product | File Name  |  Mount Path |
|---|---|---|
| **PingFederate**  | pingfederate.lic  |  /opt/in/instance/server/default/conf/pingfederate.lic |
| **PingAccess** | pingaccess.lic  | /opt/in/instance/conf/pingaccess.lic  |
| **PingDirectory** | PingDirectory.lic  | /opt/in/instance/PingDirectory.lic  |
| **PingDataSync** | PingDirectory.lic  | /opt/in/instance/PingDirectory.lic  |
| **PingDataGovernance** | PingDataGovernance.lic  | /opt/in/instance/PingDataGovernance.lic  |
| **PingCentral** | pingcentral.lic  | /opt/in/instance/conf/pingcentral.lic  |

### Volume Mount Syntax

#### Docker

Sample docker run command with mounted license:

```sh
docker run \
  --name pingfederate \
  --volume <local/path/to/pingfederate.lic>:/opt/in/instance/server/default/conf/pingfederate.lic
  pingidentity/pingfederate:edge
```

Sample docker-compose.yaml with mounted license:

```sh
version: "2.4"
services:
  pingfederate:
    image: pingidentity/pingfederate:edge
    volumes:
      - path/to/pingfederate.lic:/opt/in/instance/server/default/conf/pingfederate.lic
```

#### Kubernetes

Create a Kubernetes secret from the license file

```sh
kubectl create secret generic pingfederate-license \
  --from-file=./pingfederate.lic
```

Then mount it to the pod

```sh
spec:
  containers:
  - name: pingfederate
    image: pingidentity/pingfederate
    volumeMounts:
      - name: pingfederate-license-volume
        mountPath: "/opt/in/instance/server/default/conf/pingfederate.lic"
        subPath: pingfederate.lic
  volumes:
  - name: pingfederate-license-volume
    secret:
      secretName: pingfederate-license
```
