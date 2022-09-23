---
title: Build a Docker Product Image Locally
---
# Building a Docker product image locally

This page describes the process to build a Docker image of our products with the build tools found in our [Docker Builds](https://github.com/pingidentity/pingidentity-docker-builds) repository and a local copy of a product .zip archive.

<div class="iconbox" onclick="window.open('https://github.com/pingidentity/pingidentity-docker-builds','');">
    <img class="assets" src="../../images/logos/github.png"/>
    <span class="caption">
        <a class="assetlinks" href="https://github.com/pingidentity/pingidentity-docker-builds" target=”_blank”>Docker Builds</a>
    </span>
</div>

## Cloning a build repository

Open a terminal and clone the `pingidentity-docker-builds` repo:

```sh
git clone https://github.com/pingidentity/pingidentity-docker-builds.git
```

## Download a product .zip archive

1. Go to [Product Downloads](https://www.pingidentity.com/en/resources/downloads.html) and download the product to be used to build a Docker image.

    !!! note "Zip file versus installer"
        Ensure you download the product distribution .zip archive and not the Windows installer

1. When the download has finished, rename the file to `product.zip`:

      ```sh
      mv pingfederate-11.0.3.zip product.zip
      ```

1. Move `product.zip` to the Build Directory.

      In the `pingidentity-docker-builds` repository directory for each product, move the `product.zip` file to the `<product>/tmp` directory, where /&lt;product&gt; is the name of one of our available products. For example:

      ```sh
      mv ~/Downloads/product.zip \
         ~/pingidentity/devops/pingidentity-docker-builds/pingfederate/tmp
      ```

## Build the Docker image

Before building the image, display the `versions.json` file in the product directory. You must specify a valid version for the build script. Since the product .zip archive is being provided, it does not matter which version you select as long as it is valid. For example, you can see that `11.0.3` is a valid product version for PingFederate.

```json
{
    "latest": "11.0.3",
    "versions": [
        {
            "version": "11.0.3",
            "preferredShim": "alpine:3.15.4",
            "shims": [
                {
                    "shim": "alpine:3.15.4",
                    "preferredJVM": "al11",
                    "jvms": [
                        {
                            "jvm": "al11",
                            "build": true,
                            "deploy": true,
                            "registries": [
                                "DockerHub",
                                "Artifactory"
                            ]
                        }
                    ]
                },        
```

1. Go to the base of the `pingidentity-docker-builds` repo. For example:

     ```sh
     cd ~/pingidentity/devops/pingidentity-docker-builds
     ```

1. Run the `serial_build.sh` script with the appropriate options. For example:

     ```sh
     ./ci_scripts/serial_build.sh \
         -p pingfederate \
         -v 11.0.3 \
         -s alpine:3.15.4 \
         -j al11
     ```

     When the build is completed, the product and base images are displayed. For example:
     ```sh
     REPOSITORY                     TAG                                                       IMAGE ID       CREATED              SIZE
     pingidentity/pingfederate      11.0.3-fsoverride-alpine_3.15.4-al11-master-f1ba-x86_64   404a2b14df0c   7 seconds ago        759MB
     pingidentity/pingbase          master-f1ba-x86_64                                        eb7648692b55   About a minute ago   0B
     pingidentity/pingjvm           al11-alpine_3.15.4-master-f1ba-x86_64                     af0e87d8fafd   About a minute ago   108MB
     pingidentity/pingcommon        master-f1ba-x86_64                                        2e82b239e9bb   About a minute ago   997kB
     pingidentity/pingdatacommon    master-f1ba-x86_64                                        13f35b12a918   About a minute ago   1.11MB
     ```

     Our Docker images are built using common foundational layers required by the product layer such as the Java virtual machine (JVM), pingcommon, and pingdatacommon.

     As it is unlikely you will have the foundational layers on your local system, build the first time using the `serial_build.sh` script. This script will create the foundational images, and if you want to use the same foundational layers for other builds, you need only run the `build_product.sh` script to build the product layer.

     You must specify the appropriate options when you run `serial_build.sh`. For PingFederate, the options might look like this:

     * -p (Product): pingfederate
     * -v (Version): 11.0.3
         * Note: this is the version retrieved from the **versions.json** file
     * -s (Shim): alpine
     * -j (Java): al11

!!! warning "Run from the repository root"
    It is important to build from the base of the repository as shown in the example.

## Re-tagging the local image

To change the tag of the created image and push it to your own Docker registry, use the `docker tag` command:

```sh
docker tag [image id] \
   [Docker Registry]/[Organization]/[Image Name]:[tag]
```

For example:

```sh
docker tag 404a2b14df0c \
    gcp.io/pingidentity/pingfederate:localbuild

# Display new tag
docker image ls

# Output snippet
pingidentity/pingfederate            11.0.3-fsoverride-alpine_3.15.4-al11-master-f1ba-x86_64   404a2b14df0c   4 minutes ago   759MB
gcp.io/pingidentity/pingfederate     localbuild                                                404a2b14df0c   4 minutes ago   759MB
```

