---
title: Environment considerations
---

# Environment considerations

## Network File System (NFS) constraints

All PingData products use the `manage-extension` tool for installing extensions. This can lead to issues when the deployment involves NFS.

If your deployment uses NFS, rather than using the `manage-extensions` tool, unzip the extension yourself and add it to the appropriate directory.

The following example script, called `181-install-extensions.sh.post`, loops through the extensions to unzip and then removes them from the server profile.

```sh
#!/usr/bin/env sh
# Loop through extensions to unzip, then remove them from the server profile
PROFILE_EXTENSIONS_DIR="${PD_PROFILE}/server-sdk-extensions"
if test -d "${PROFILE_EXTENSIONS_DIR}"; then
  find "${PROFILE_EXTENSIONS_DIR}" -type f -name '*.zip' -print > /tmp/_extensionList
  while IFS= read -r _extensionFile; do
      echo "Installing extension: ${_extensionFile}"
      unzip -q "${_extensionFile}" -d /opt/out/instance/extensions/
      rm "${_extensionFile}"
  done < /tmp/_extensionList
  rm -f /tmp/_extensionList
fi
```

## PingDirectory inotify watch limit requirement

When using inotify with PingDirectory, you must set a watch limit on the host system. It cannot be set from a docker container, and the value read within a docker container is always the host value.

For more information, see [Set file system event monitoring (inotify)](https://docs.pingidentity.com/bundle/pingdirectory-90/page/mze1564011493893.html) in the PingDirectory documentation.
