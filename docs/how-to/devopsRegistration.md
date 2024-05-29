---
title: Ping Identity DevOps Registration
---

!!! info "Getting Support"
    The team responsible for the Ping DevOps program does not have access to the user account system on the Ping Identity website.  If you have trouble with your account and are unable to follow these instructions to enroll, the issue is probably with your credentials in our system.  Please contact your sales representative at [Ping Identity Support](https://support.pingidentity.com/s/).

# Ping Identity DevOps Registration

Registering for Ping Identity's DevOps Program provides you with credentials that enable you to easily deploy and evaluate Ping Identity products using trial licenses automatically using tools and platforms like Helm or Kubernetes.

To register for the DevOps Program:

* Make sure you have a registered account with Ping Identity.  If you're not sure, click the link to [Sign On](https://www.pingidentity.com/en/account/sign-on.html) and follow the instructions to access your account.
  * If you don't have an account, create one [here](https://www.pingidentity.com/en/account/register.html).
  * When signing on, select **Support and Community** in the **Select Account** list.
  * After you're signed on, you're directed to your profile [page](https://support.pingidentity.com/s/).
  * In the right-side menu, click **Register for DevOps Program**.
  ![Register for DevOps](../images/DEVOPS_REGISTRATION.png)

A confirmation message will be shown and the DevOps credentials will be forwarded to the email address associated with your Ping Identity account.

!!! info "Saving Credentials"
    When you receive your key, follow the instructions below for saving these with the `pingctl` utility.

Example:

* `PING_IDENTITY_DEVOPS_USER=jsmith@example.com`
* `PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2`

## Saving Your DevOps User and Key

The recommended way to save your DevOps User/Key is to use the Ping Identity DevOps utility `pingctl`.

!!! info "pingctl setup"
    You can find installation instructions for `pingctl` in the [pingctl Tool](../tools/pingctlUtil.md) document.

To save your DevOps credentials, run `pingctl config` and supply your credentials when prompted.

When `pingctl` is installed and configured, it places your DEVOPS USER/KEY into a Ping Identity property file found at
`~/.pingidentity/config`  with the following variable names set (see the following example).

```text
PING_IDENTITY_DEVOPS_USER=jsmith@example.com
PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
```

After you've configured these settings, you can view them with the `pingctl info` command (credential values are masked by default, use `pingctl info -v` to show unmasked).


## Resending your DevOps User and Key

If you have misplaced or lost your DevOps User/Key, there are two convenient ways to recover it.

* If you have configured `pingctl`, the `PING_IDENTITY_DEVOPS_USER` and `PING_IDENTITY_DEVOPS_KEY` can be printed by entering the following command:
    ```text
    pingctl info -v
    ```

* If you did not save the credentials in the `pingctl` tool, you can recover your credentials by logging in to your Ping Identity account.
  * Navigate to [Sign On](https://www.pingidentity.com/en/account/sign-on.html) and follow the instructions to access your account.
  * When signing on, select **Support and Community** in the **Select Account** list.
  * After you're signed on, you're directed to your profile [page](https://support.pingidentity.com/s/).
  * In the right-side menu, click **Register for DevOps Program** again.  A confirmation message will be shown and the same DevOps credentials will be resent to the email address associated with your Ping Identity account.
