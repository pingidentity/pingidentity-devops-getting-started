---
title: Mount Existing Product License
---
## Mount Existing Product License

You can pass the license file to a container via mounting to the container's `/opt/in` directory.

Note: You do not need to do this if you are using your DevOps User/Key. If you have provided license files via the volume mount and a DevOps User/Key, it will ignore the DevOps User/Key.

The `/opt/in` directory overlays files onto the products runtime filesystem, the license needs to be named correctly and mounted in the exact location the product checks for valid licenses.

### Example Mounts

|  Product | File Name  |  Mount Path |
|---|---|---|
| **PingFederate**  | pingfederate.lic  |  /opt/in/instance/server/default/conf/pingfederate.lic |
| **PingAccess** | pingaccess.lic  | /opt/in/instance/conf/pingaccess.lic  |
| **PingDirectory** | PingDirectory.lic  | /opt/staging/pd.profile/server-root/pre-setup/PingDirectory.lic  |
| **PingDataSync** | PingDirectory.lic  | /opt/staging/pd.profile/server-root/pre-setup/PingDirectory.lic  |
| **PingAuthorize** | PingAuthorize.lic  | /opt/staging/pd.profile/server-root/pre-setup/PingAuthorize.lic  |
| **PingAuthorize PAP** | PingAuthorize.lic  | /opt/staging/pd.profile/server-root/pre-setup/PingAuthorize.lic  |
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

#### Helm

Create a Kubernetes secret from the license file

```sh
kubectl create secret generic pingfederate-license \
  --from-file=./pingfederate.lic
```

Add the secretVolumes within your values.yaml deployment file

```sh
pingfederate-admin:
  ...
  secretVolumes:
    pingfederate-license:
      items:
        pingfederate.lic: /opt/in/instance/server/default/conf/pingfederate.lic
```

### Note on updating the product license when mounting it as a file
If you are updating the license file for a product, simply replacing the file on the filesystem may not update the license of the running server.

For PingData products (PingDirectory, PingDataSync, PingAuthorize, and PingDirectoryProxy) the license can be updated by copying the new license to the expected location in the server profile - `pd.profile/server-root/pre-setup`. After doing so, dsconfig can be used to update the license on the running server. Ensure that the updated license file is still present in the server profile on subsequent restarts of the container.

For example, for PingDirectory:
```
dsconfig set-license-prop \
  --set "directory-platform-license-key<input-file.lic"
```

The exact name of the license property in the above example will depend on which PingData product is being used.

For non-PingData products, the license can be updated on the product with the typical method. This process will depend on the product, but will generally be done either through the administrative console or using an API call. See the product documentation for details.
