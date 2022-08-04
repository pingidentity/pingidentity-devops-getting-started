---
title: Including Extensions in PingData Server Profiles
---
# Including Extensions in PingData Server Profiles
Server SDK extension zip files can be included in your server profile for PingData products (PingAuthorize, PingDataSync, PingDirectory, and PingDirectoryProxy). The zip files can be included directly, or can be pulled from a remote URL when the container starts up.

# The pd.profile/server-sdk-extensions/ directory
Any desired extension zip files should be included in the pd.profile/server-sdk-extensions/ directory of your server profile. Extension zip files in this directory will be installed during the setup process.

# Pulling extension zip files from an external URL
The hook scripts support pulling down extension zip files from a defined URL, to avoid having to commit zip archives to a Git repository. To do this, a `remote.list` file should be included in the extensions/ directory of your server profile. Any file with a name ending in `remote.list` in the extensions/ directory will be treated as a list of extensions.

!!! note "Ensure extensions are in the right folder"
When listing extensions to pull down via curl, the list must be placed in the extensions/ directory of the server profile. When directly including extension zip files, the zip files must be placed in the pd.profile/server-sdk-extensions/ directory of the server profile.

For an example, see the extension list included in our [baseline PingDirectory server profile](https://github.com/pingidentity/pingidentity-server-profiles/blob/master/baseline/pingdirectory/extensions/baseline.remote.list).

Separate multiple extensions with line breaks.

A URL can also be specified in the downloaded zip file. To do this, add a space between the extension zip URL and the URL that will provide the SHA1 hash. For example:
```
https://example.com/extension.zip https://example.com/extension/sha1
```

Set the `ENABLE_INSECURE_REMOTE_EXTENSIONS` environment variable to `true` to allow installing extensions without the SHA1 hash check. By default the SHA1 check will be required. If a SHA1 URL is provided and the SHA does not match or the URL cannot be reached, the extension will not be installed.
