# Obtain and Use Product Licenses

In order to run the Ping Identity DevOps images, a valid product license is required. There are several ways to obtain a product license to run the images:

#### Evaluation License

By registering for Ping Identity's DevOps program, you will be issued credentials that will automate the process of retreiving evalution product licensea. Please note that evalution licenses are short lived and should **not** be used in production deployments.

* [Obtaining a Ping Identity DevOps User and Key](#obtaining-a-ping-identity-devops-user-and-key)
* [Saving your DevOps User/Key](#saving-your-devops-user-and-key)
* [Using your DevOps User/Key](#using-your-devops-user-and-key)

#### Existing license

* [Use an existing license file \(Current customers\)](#using-an-existing-product-license-file)

## Obtaining a Ping Identity DevOps User and Key

>**Notice**: Currently, if no PINGIDENTITY_DEVOPS_USER or PINGIDENTITY_DEVOPS_KEY is provided, a default evaluation user/key is used. After **August 19th, 2019**, the evaluation user/key will no longer be available, and a personal DEVOPS_USER/DEVOPS_KEY will be required if you do not provide a valid product license.

Ping Identity will provide a DevOps Key to any user registered with Ping Identity. You must follow the steps listed below to obtain a Ping Identity DevOps User and Key

* Ensure you have a registered account with Ping Identity.  Not sure, click the link to [Sign On](https://www.pingidentity.com/en/account/sign-on.html) and follow instructions.
  * If you don't have an account, please create one.
  * Otherwise, sign-in.
  * Your DEVOPS-USER is your email.
  * Request your DEVOPS-KEY from the [FORM](https://docs.google.com/forms/d/e/1FAIpQLSdgEFvqQQNwlsxlT6SaraeDMBoKFjkJVCyMvGPVPKcrzT3yHA/viewform).

Typically, within a few business hours, your personal DEVOPS-USER and DEVOPS-KEY will be 
sent to your email.

>Important: Upon receiving your key, ensure that you follow the instructions below for 
saving these via the `setup` script.

Example:

* `PING_IDENTITY_DEVOPS_USER=jsmith@example.com`
* `PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2`

## Saving your DevOps User and Key

The best way to save your DevOps User/Key is to use the Ping Identity DevOps utility `setup`.

>More details on `setup` can be found in the [Get Started](https://pingidentity-devops.gitbook.io/devops/getstarted#initial-setup) document.

Simply run:

```text
./pingidentity-devops-getting-started/setup
```

and answer the prompts with your DEVOPS User/Key. 

This will place your DEVOPS USER/KEY into a Ping Identity property file found at
`~/.pingidentity/devops`.  with the following variable names set (see example below).

```text
      PING_IDENTITY_DEVOPS_USER=jsmith@example.com
      PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
```
You can always view these settings with the `denv` command after you've configured them.

## Using your DevOps User and Key

When starting an image, you can provide your devops property file `~/.pingidentity/devops` or using the individual environment variables.

>The examples provided for standalone and docker-compose 
are set up to use this property file by default.

For more detail, run the `denv` to get your DevOps environment information.

### Example with docker run command

An example of running a docker image using the `docker run` command would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

```text
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

### Example with .yaml file

An example of running a docker image using any docker .yaml file would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

>Note: Docker Compose is able to make use of this format.  See next section for example if using
Docker Swarm.

```text
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

### Example with .yaml file and inline environment variables

An example of running a docker image using any docker .yaml file would look like the following example \(See the 2 environment variables starting with **PING\_IDENTITY\_DEVOPS**\):

>Note: Docker Swarm requires this format.  See previous section for example if using
Docker Swarm.

```text
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

## Using an existing Product License file (Server-Profile)

You can also use an existing valid product license file the product/version combo you are running, by placing them into the proper directory of your server profile. The default server profile location and file name for each product are as follows:

Note: You do not need to do this if you are using your DevOps User/Key. If you have provided license files as part of your server profile and a DevOps User/Key, it will ignore the DevOps User/Key.

* PingFederate - `instance/server/default/conf/pingfederate.lic`
* PingAccess - `instance/conf/pingaccess.lic`
* PingDirectory - `instance/PingDirectory.lic`
* PingDataSync - `instance/PingDirectory.lic`

## Using an existing Product License file (Mounted /opt/in volume)

You can pass the license file to a container via mounting to the container's `/opt/in` directory.

Note: You do not need to do this if you are using your DevOps User/Key. If you have provided license files via the volume mount and a DevOps User/Key, it will ignore the DevOps User/Key.

The `/opt/in` directory overlays files onto the products runtime filesystem, the license needs to be named correctly and mounted in the exact location the product checks for valid licenses.

### Example Mounts

**PingFederate**
* Expected license file name: `pingfederate.lic`
* Mount Path: `/opt/in/instance/server/default/conf/pingfederate.lic`

**PingAccess**
* Expected license file name: `pingaccess.lic`
* Mount Path: `opt/in/instnce/conf/pingaccess.lic`

**PingDirectory**
* Expected License file name: `PingDirectory.lic`
* Mount Path: `/opt/in/instance/PingDirectory.lic`

**PingDataSync**
* Expected license file name: `PingDirectory.lic`
* Mount Path: `/opt/in/instance/PingDirectory.lic`

**PingDataGovernance**
* Expected license file name: `PingDataGovernance.lic`
* Mount Path: `/opt/in/instance/PingDataGovernance.lic`

**PingCentral**
* Expected license file name: `pingcentral.lic`
* Mount Path: `/opt/in/instance/conf/pingcentral.lic`


### Volume Mount Syntax

#### Docker
Sample docker run command with mounted license:

```
docker run \
    --name pingfederate \
    --volume <local/path/to/pingfederate.lic>:/opt/in/instance/server/default/conf/pingfederate.lic
    pingidentity/pingfederate:edge
```

Sample docker-compose.yaml with mounted license:
```
version: "3.1"
services:
  pingfederate:
    image: pingidentity/pingfederate:edge
    volumes:
      - path/to/pingfederate.lic:/opt/in/instance/server/default/conf/pingfederate.lic
```

#### Kubernetes
Create a Kubernetes secret from the license file
```
kubectl create secret generic pingfederate-license --from-file=./pingfederate.lic
```

Then mount it to the pod 
```
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

## Support

If you have any quesitons or issues, please contact [devops\_program@pingidentity.com](mailto:devops_program@pingidentity.com).

