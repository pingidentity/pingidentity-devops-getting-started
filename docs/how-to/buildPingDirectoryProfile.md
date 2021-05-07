---
title: Build PingDirectory Profile
---
# Build Profile From Current Deployment

PingDirectory is built for [GitOps](https://www.gitops.tech/) through [native tools for building profiles](https://docs.pingidentity.com/bundle/pingdirectory-82/page/eae1564011467693.html). To find the latest, search for "DevOps" in PingDirectory Docs. You can find details of the server profile structure there.

A well-formed PingDirectory profile includes all the **configuration** needed for starting up a server in a **new** or **existing** replication topology. This means it should be a representation of what is actually running.

This document will show a simple example of building a PingDirectory profile from a running instance.

## Prerequisite

* [Get Started](../get-started/getStarted.md)

* A running PingDirectory instance of 8.0.0.0 or later, with shell access on the machine or in the container.

* Understanding of [Product Container Anatomy](containerAnatomy.md).

* Recommended: [Customizing Server Profiles](profiles.md)

## Start Building

### Generate Profile

The core command for generating a profile is: `manage-profile generate-profile`. This can be called on a running container in Kubernetes like so:

  ```shell
  ## kubectl exec -it <pod-name> -- manage-profile generate-profile --profileRoot /tmp/pd.profile
  kubectl exec -it pingdirectory-0 -- manage-profile generate-profile --profileRoot /tmp/pd.profile
  ```

!!! Info "The Name Matters"
    Naming your profile `pd.profile` isn't _required_, but the default location (i.e. the variable `PD_PROFILE`) that pingdirectory looks at is `PD_PROFILE="/opt/staging/pd.profile"`

  Sample Output:

  ```sh
  Defaulted container "pingdirectory" out of: pingdirectory, telegraf, vault-agent-init (init)
  Generating server profile

  ...

  Variables such as PING_INSTANCE_NAME in setup-arguments.txt and in any other
  files in the profile will need to be provided through environment variables or
  through a profile variables file when using the generated profile with the
  manage-profile tool. The PING_SERVER_ROOT and PING_PROFILE_ROOT variables are
  provided by manage-profile

  Some changes may need to be made to the generated profile. Any desired LDIF
  files will need to be added to the profile. Any additional server root files,
  server SDK extensions, and dsconfig commands can be manually added, and
  variables-ignore.txt can be updated to ignore certain files during variable
  substitution. See the README file at /tmp/pd.profile/misc-files/README for
  more information on the manual steps that must be taken for the generated
  profile to be used with the manage-profile tool

  The following files and directories in the server root were excluded from the
  generated profile, and can be manually added if necessary. These files can
  also be included by generate-profile with the --includePath argument:
  config/truststore
  config/ads-truststore
  config/encryption-settings.pin
  config/tools.properties.orig
  config/encryption-settings/encryption-settings-db
  config/keystore.p12
  config/tools.properties
  config/encryption-settings/encryption-settings-db.old
  config/keystore.pin
  config/keystore
  config/ads-truststore.pin
  config/truststore.p12
  config/truststore.pin

  The generated profile can be found at /tmp/pd.profile
  ```

!!! Info "Note other paths that are not included"
    The `manage-profile generate-profie` command outputs valuable information about what is and isn't included in the generated profile.

!!! warning "Don't put secrets in your profile!"
    Secrets should not be included in your profile, so they are not included in the profile generation by default.
    However, If you have not already added encryption secrets or keystores to your environment, you can use the `--includePath` argument to collect items from the running server. These items should then be provided to the server on it's next restart via some secrets management tool.

### Extract Generated Profile

Following the kubernetes example, you can copy out the generated profile with:

  ```sh
  kubectl cp pingdirectory-0:/tmp/pd.profile pd.profile
  ```

  Sample output:

  ```sh
  % tree
  .
  └── pd.profile
      ├── dsconfig
      │   └── 00-config.dsconfig
      ├── ldif
      │   └── userRoot
      ├── misc-files
      │   └── README
      ├── server-root
      │   ├── post-setup
      │   └── pre-setup
      │       ├── PingDirectory.lic
      │       ├── README.md
      │       └── config
      │           ├── encryption-settings.pin ## Added via --includePath
      │           ├── keystore.pin ## Added via --includePath
      │           └── schema
      │               ├── 80-format-counter-metrics.ldif
      │               ├── 87-local-identities.ldif
      │               ├── 88-grants.ldif
      │               ├── 89-sessions.ldif
      │               └── 90-oauth-clients.ldif
      ├── server-sdk-extensions
      ├── setup-arguments.txt ## REMOVE this
      └── variables-ignore.txt

  11 directories, 13 files
  ```

`setup-arguments.txt` is generated by our Docker Image at startup and isn't needed in the profile. So it should be removed from the profile.

  ```sh
  rm pd.profile/setup-arguments.txt
  ```

!!! Info "userRoot data is not included"
    You may notice that userRoot data (i.e. users) is not included. Profiles should contain _configuration_ only, not data.

### Store Profile

Now you can put `pd.profile` at the [root of your profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingdirectory). Or `/opt/in/pd.profile` if mounted.

### Other Files

Aside from what is generated via `manage-profile generate-profie`, you may want to include other files. These files should be siblings to `pd.profile` at the root of the profile. see [baseline](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingdirectory) for an example structure.

## What is in a Profile

"A good PingDirectory profile includes all the **configuration** needed for starting up a server in a **new** or **existing** replication topology."

Let's play "Should it be in My Profile?":

**dsconfig commands**

Yes! This is how the PingDirectory server is configured. `manage-profile generate-profile` outputs all of the dsconfig commands of a running server into one file ` 00-config.dsconfig`.

Keeping dsconfig commands in one file makes sense because they are ingested altogether but run in order by the server's inherent dependency knowledge of itself. You can work on PingDirectory in a dev environment and make many changes while working toward your desired configuration. Then `generate-profile` exports a representation of your work.

You may see multiple files containing dsconfig commands in our profiles. This serves mainly just to _show_ logical separation in our demos. Also our demos may be built of multiple layers coming form different repositories so this prevents overwriting.

**users**

No. Data is expected to change at runtime. There is even protection built in to enforce this. `ldif/userRoot/*` is only imported on `GENESIS` - The first start of the **first** PingDirectory in a topology.

The exceptions to this rule are ephemeral dev and demo environments. This is why you see user files in our sample profiles. These files are intended for bootstrapping demo and test instances. If you are in this category and wanted to include users you could use:

  ```sh
  kubectl exec -it pingdirectory-0 -- export-ldif --backendID userRoot --ldifFile /tmp/userRoot.ldif --doNotEncrypt

  kubectl cp pingdirectory-0:/tmp/userRoot.ldif pd.profile/ldif/userRoot/00-users.ldif
  ```

**schema**

Yes. You may want to manage your schema as code, and `pd.profile/server-root/pre-setup/config/schema` is where to do that.

**encryption keys, keystores, truststores, and other secrets**

NO!! Any and all secrets should be provided by some sort of secrets management (Vault, bitnami sealed secrets, or at least kubernetes secrets). PingDirectory allows you to define file paths to secrets so they do not need to be in the profile.
