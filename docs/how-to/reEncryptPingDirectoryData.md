# Re-encrypting backend data for a set of PingDirectory pods

PingDirectory uses encryption settings definitions to manage how data is encrypted in the database. When setting a new preferred encryption settings definition, the new definition will be used for all subsequent data encryption, but existing data remains encrypted with an older key.

In many cases this is acceptable, and no additional work needs to be done. However in cases such as when an existing key might have been compromised, you will want to completely transition to using the new definition. This page describes the steps necessary to do this.

For PingDirectory documentation on this scenario, see https://docs.pingidentity.com/r/en-us/pingdirectory-93/pd_sec_re-encrypt_database

This page will describe how to follow the steps listed on the above page in a Kubernetes environment with several PingDirectory pods.

## Example starting Helm values using the ping-devops Helm chart

For demonstration, we will be using these Helm values with the ping-devops Helm chart:
```
pingdirectory:
  enabled: true
  container:
    replicaCount: 3
  envs:
    SERVER_PROFILE_URL: https://path/to/profile.git
    SERVER_PROFILE_PATH: my-profiles/pingdirectory
    ENCRYPTION_PASSWORD_FILE: /opt/staging/.sec/encryption-passphrase1.txt
```

## Updating the encryption settings database with the new preferred definition

The first step is to update the encryption settings database with your new preferred encryptions settings definition. For details on doing this manually, see the [PingDirectory documentation](https://docs.pingidentity.com/r/en-us/pingdirectory-93/pd_sec_manage_encrypt_settings).

If you are using the `ENCRYPTION_PASSWORD_FILE` environment variable to control encryption for your pods, you can simply point that variable to a different file with a new passphrase and restart the pods. After the restart, the pods will use the new definition based on the `ENCRYPTION_PASSWORD_FILE` value. For example, with the environment variable updated:

```
pingdirectory:
  enabled: true
  container:
    replicaCount: 3
  envs:
    SERVER_PROFILE_URL: https://path/to/profile.git
    SERVER_PROFILE_PATH: my-profiles/pingdirectory
    ENCRYPTION_PASSWORD_FILE: /opt/staging/.sec/encryption-passphrase2.txt
```

Whatever method you use to update the encryption settings database, ensure that each pod has the new definition in the encryption settings database before continuing. Use the `encryption-settings` command-line tool to view the contents of the encryption settings database.

## Disabling replication and deleting the replication database

Now replication must be disabled between the pods before the data is exported and re-imported, and the replication database must be deleted to ensure there are no remaining entries encrypted with the old definition.

Exec into one of the pods and use the `dsreplication disable` command to disable replication between each of the servers. Ensure that each server is in its own single-server topology using the `dsreplication status` command.

Run `rm -r /opt/out/instance/changelogDb/` on each of the pods individually, to remove any lingering entries from the replication database that may have been encrypted with the old definition.

## Scaling down to one pod and re-importing the data

The data must now be exported and re-imported with the server offline. To do this, we will scale down to a single pod (however we *do not* need to delete the persistent volumes of the other pods). We will also force the final pod to export and re-import its data so that it is encrypted with the new preferred definition. The `PD_FORCE_DATA_REIMPORT` environment variable can be used to force an export and re-import of the data before the server starts up.

```
pingdirectory:
  enabled: true
  container:
    replicaCount: 1
  envs:
    SERVER_PROFILE_URL: https://path/to/profile.git
    SERVER_PROFILE_PATH: my-profiles/pingdirectory
    ENCRYPTION_PASSWORD_FILE: /opt/staging/.sec/encryption-passphrase2.txt
    PD_FORCE_DATA_REIMPORT: "true"
```

## Scaling back up

Now we can scale back up to the full number of pods, and stop forcing the data export and re-import. When the removed pods restart, they will rejoin the topology and will initialize their data from the seed pod (pod 0), which will be encrypted with the new preferred definition.

```
pingdirectory:
  enabled: true
  container:
    replicaCount: 3
  envs:
    SERVER_PROFILE_URL: https://path/to/profile.git
    SERVER_PROFILE_PATH: my-profiles/pingdirectory
    ENCRYPTION_PASSWORD_FILE: /opt/staging/.sec/encryption-passphrase2.txt
```

The backend data will now be encrypted with the new preferred definition.

Note that in some cases an encryption settings definition may be used for more than encrypting backend data. For example, files can be encrypted using encryption settings definitions. By default some pin files in the server root will be encrypted if encryption was enabled during the first setup of the server, such as `config/keystore.pin`. If you need to manage how files are encrypted with encryption settings definitions, run `encrypt-file --help` for more information.
