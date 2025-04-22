# S3 Archive of a PingDirectory Backup

!!! error "Demonstration Only"
    This guide is for demonstration purposes only and is not intended for production use and is just one of many ways of archiving files to S3.  Other storage options might be available, depending on your provider.

## Before you begin

Prior to attempting these steps, you must:

* Complete the [Getting Started](../get-started/introduction.md) steps to set up your DevOps environment and run a test deployment of the products
* Have some means of authenticating the sidecar container to S3.  This authentication can use an IAM role or another method and is left for the user to implement.

## High-level backup steps

* Configure some means of creating a backup of PingDirectory.  For this guide, an extension of the [PingDirectory Backup and Sidecar](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingdirectory-backup/pingdirectory-periodic-backup.yaml) is used.
* After the backup is made, use an archive script to upload the backup to S3.
* (Optional) Clean up the image filesystem of backups.

## File exploration

In the `30-helm/s3-sidecar` directory of this repository, you will find the following files:

### Dockerfile

This file extends the PingToolkit image, adding the AWS CLI and a few other utilities for demonstration purposes.  You can use any platform that meets your requirements.

```sh
## Dockerfile for AWS CLI
## For demonstration purposes only
## Not intended for production use
FROM pingidentity/pingtoolkit:latest

USER root

# Install AWS CLI
RUN apk add --no-cache \
    aws-cli \
    bash \
    curl \
    less \
    groff \
    shadow \
    sudo \
    unzip

USER 9031:0

```

To build a multi-architecture image, you can use the following command.  In order to create an image for a different architecture, you will need to have the `buildx` plugin installed and configured, and the image will have to be pushed at build time:

```sh
docker buildx build --platform linux/arm64,linux/amd64 -t <registry>/<image>:<tag> --push .
```

!!! note "Image Availability"
    Ensure that the registry is accessible to the Kubernetes cluster.

### pd-archive-backup-to-s3.yaml

This file will not be repeated in full here.  The top section creates ConfigMaps that define four sample scripts:

* **archive.sh** - This demonstration script is called by the _backup.sh_ script to archive the backup to S3.  The bucket name and path will need to be updated to match your environment.
* **fetch.sh** - This demonstration script is called by the _restore.sh_ script to fetch backup files from S3.  The bucket name and path will need to be updated to match your environment.
* **backup.sh** - This demonstration script is called by the sidecar container to create a backup of PingDirectory.  It then calls the _archive.sh_ script (with no error handling or testing).
* **restore.sh** - This demonstration script would be executed either by a job or in the sidecar container to restore a backup of PingDirectory.

These scripts are placed into the sidecar image under the _/opt/in_ directory.

Lines 222 and 223 will need modification to point to the registry and tag for the image that has the AWS cli installed as in the `buildx` command above.

## Backup Operation

If this demonstration is implemented, the process is straightforward.  As per the crontab entry, every 6 hours:

* A backup of the PingDirectory data is created
* The backup is archived to S3

PingDirectory handles the removal of old backups based on the parameters set in the backup script.

If you are observing the cluster at the time the backup takes place, an additional pod launches to execute the cronjob.  This pod terminates after the backup is complete.

Over time, the S3 bucket will appear similar to the following screenshot.  To create this image, the backup and archive process ran every 2 minutes:

![S3 archive contents](../images/s3Sample.png)

## Restore Operation

In the event that a restore operation is needed, the **restore.sh** script can be used.  This script will:

* Download the backup from S3
* Restore the backup to the PingDirectory data directory

A sample run of the script is shown below:

```sh
PingToolkit:demo-pingdirectory-0:/opt
> /opt/in/restore.sh <admin-password>
download: s3://<bucket-name>/<folder>/userRoot/backup.info to ../tmp/restore/userRoot/backup.info
download: s3://<bucket-name>/<folder>/userRoot/backup.info.save to ../tmp/restore/userRoot/backup.info.save
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421213402Z to ../tmp/restore/userRoot/userRoot-backup-20250421213402Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421213202Z to ../tmp/restore/userRoot/userRoot-backup-20250421213202Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421213002Z to ../tmp/restore/userRoot/userRoot-backup-20250421213002Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421213602Z to ../tmp/restore/userRoot/userRoot-backup-20250421213602Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421213802Z to ../tmp/restore/userRoot/userRoot-backup-20250421213802Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421212802Z to ../tmp/restore/userRoot/userRoot-backup-20250421212802Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421214202Z to ../tmp/restore/userRoot/userRoot-backup-20250421214202Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421214802Z to ../tmp/restore/userRoot/userRoot-backup-20250421214802Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421214402Z to ../tmp/restore/userRoot/userRoot-backup-20250421214402Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421215002Z to ../tmp/restore/userRoot/userRoot-backup-20250421215002Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421214602Z to ../tmp/restore/userRoot/userRoot-backup-20250421214602Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421215202Z to ../tmp/restore/userRoot/userRoot-backup-20250421215202Z
download: s3://<bucket-name>/<folder>/userRoot/userRoot-backup-20250421214002Z to ../tmp/restore/userRoot/userRoot-backup-20250421214002Z
Replication is not enabled
userRoot
Restoring to the latest backups under /tmp/restore
Restore order of backups: /tmp/restore/userRoot

----- Doing a restore from /tmp/restore/userRoot -----
Restore task 2025042121535304 scheduled to start immediately

NOTE:  This tool is running as a task.  Killing or interrupting this tool will not have an impact on the task
If you wish to cancel the running task, that may be accomplished using the command:  manage-tasks --no-prompt --hostname localhost --port 1636 --bindDN "cn=administrator" --bindPassword "********" --cancel "2025042121535304"

[21/Apr/2025:21:53:53 +0000] severity="SEVERE_WARNING" msgCount=0 msgID=1880227932 message="Administrative alert type=backend-disabled id=fc5694f2-7b52-4cf9-8214-89edb41708bb class=com.unboundid.directory.server.core.BackendConfigManager msg='Backend userRoot is disabled'"
[21/Apr/2025:21:53:53 +0000] severity="NOTICE" msgCount=1 msgID=1880555611 message="Administrative alert type=config-change id=71fc9c87-4030-427a-ab9c-cf631157d210 class=com.unboundid.directory.server.admin.util.ConfigAuditLog msg='A configuration change has been made in the Directory Server:  [21/Apr/2025:21:53:53.124 +0000] conn=-4 op=7407 dn='cn=Internal Client,cn=Internal,cn=Root DNs,cn=config' authtype=[Internal] from=internal to=internal command='dsconfig set-backend-prop --backend-name userRoot --set enabled:false''"
[21/Apr/2025:21:53:54 +0000] severity="NOTICE" msgCount=2 msgID=8847445 message="Restored: .environment-open from backup with id '20250421215202Z' (size 76)"
[21/Apr/2025:21:53:54 +0000] severity="NOTICE" msgCount=3 msgID=8847445 message="Restored: 00000000.jdb from backup with id '20250421215202Z' (size 12997816)"
[21/Apr/2025:21:53:54 +0000] severity="NOTICE" msgCount=4 msgID=8847445 message="Restored: esTokenizer.ping from backup with id '20250421215202Z' (size 39)"
[21/Apr/2025:21:53:54 +0000] severity="SEVERE_WARNING" msgCount=5 msgID=1880227932 message="Administrative alert type=je-environment-not-closed-cleanly id=8f35bade-1f67-42ca-a506-79ee377a0ace class=com.unboundid.directory.server.backends.jeb.RootContainer msg='The server has detected that the Berkeley DB JE environment located in directory '/opt/out/instance/db/userRoot' may not have been closed cleanly the last time it was opened (or that the backend has just been restored from a backup taken with the server online).  The database environment may need to replay changes from the end of the transaction log to guarantee the integrity of the data, and in some cases this may take a significant amount of time to complete'"
[21/Apr/2025:21:53:54 +0000] severity="NOTICE" msgCount=6 msgID=8847402 message="The database backend userRoot using Berkeley DB Java Edition 7.5.12 and containing 20008 entries has started"
[21/Apr/2025:21:53:54 +0000] severity="NOTICE" msgCount=7 msgID=1879507338 message="Starting group processing for backend userRoot"
[21/Apr/2025:21:53:54 +0000] severity="NOTICE" msgCount=8 msgID=1879507339 message="Completed group processing for backend userRoot"
[21/Apr/2025:21:53:54 +0000] severity="INFORMATION" msgCount=9 msgID=1891631108 message="Starting access control processing for backend userRoot"
[21/Apr/2025:21:53:54 +0000] severity="INFORMATION" msgCount=10 msgID=12582962 message="Added 2 Access Control Instruction (ACI) attribute types found in context 'dc=example,dc=com' to the access control evaluation engine"
[21/Apr/2025:21:53:54 +0000] severity="NOTICE" msgCount=11 msgID=1880555611 message="Administrative alert type=config-change id=550d224f-f8f9-45f5-ace3-4933ca74a76d class=com.unboundid.directory.server.admin.util.ConfigAuditLog msg='A configuration change has been made in the Directory Server:  [21/Apr/2025:21:53:54.939 +0000] conn=-4 op=7415 dn='cn=Internal Client,cn=Internal,cn=Root DNs,cn=config' authtype=[Internal] from=internal to=internal command='dsconfig set-backend-prop --backend-name userRoot --set enabled:true''"
Restore task 2025042121535304 has been successfully completed
Restore complete
```
