---
title: Ping Identity DevOps Registration
---
# Ping Identity DevOps Registration

Registering for Ping Identity's DevOps Program grants you credentials that, when supplied to product containers automatically, retrieve an evaluation license on startup.

To register for the DevOps Program:

* Make sure you have a registered account with Ping Identity.  If you're not sure, click the link to [Sign On](https://www.pingidentity.com/en/account/sign-on.html) and follow the instructions.
  * If you don't have an account, create one [here](https://www.pingidentity.com/en/account/register.html).
  * Otherwise, sign on.
  * When signing on, select **Support and Community** in the **Select Account** list.
  * After you're signed on, you're directed to your profile [page](https://support.pingidentity.com/s/).
  * In the right-side menu, click **REGISTER FOR DEVOPS PROGRAM**.
  ![Register for DevOps](../images/DEVOPS_REGISTRATION.png)
  * You'll receive a confirmation message, and your credentials will be forwarded to the email address associated with your Ping Identity account.

!!! info "Saving Credentials"
    When you receive your key, follow the instructions below for saving these with the `ping-devops` utility.

Example:

* `PING_IDENTITY_DEVOPS_USER=jsmith@example.com`
* `PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2`

## Saving Your DevOps User and Key

The best way to save your DevOps User/Key is to use the Ping Identity DevOps utility `ping-devops`.

!!! info "ping-devops Setup"
    You can find installation instructions for `ping-devops` in the [ping-devops Tool](pingDevopsUtil.md) document.

To save your DevOps credentials, run `ping-devops config` and supply your credentials when prompted.

When `ping-devops` is installed and configured, it places your DEVOPS USER/KEY into a Ping Identity property file found at
`~/.pingidentity/devops`  with the following variable names set (see the following example).

```text
PING_IDENTITY_DEVOPS_USER=jsmith@example.com
PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
```

After you've configured these settings, you can view them with the `ping-devops info` command.
