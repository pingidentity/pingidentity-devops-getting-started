---
title: Ping Identity DevOps Registration
---
# Ping Identity DevOps Registration

Registering for Ping Identity's DevOps Program grants you credentials that when supplied to product containers will automatically retrieve an evaluation license upon startup.

Follow the steps listed below to register

* Ensure you have a registered account with Ping Identity.  Not sure, click the link to [Sign On](https://www.pingidentity.com/en/account/sign-on.html) and follow instructions.
  * If you don't have an account, please create one [Here](https://support.pingidentity.com/s/).
  * Otherwise, sign-in.
  * When signing in select **'Support and Community'** from the account type dropdown
  * Once logged in, you'll be directed to your profile [Page](https://support.pingidentity.com/s/)
  * In the right-side menu, click the 'REGISTER FOR DEVOPS PROGRAM' button
  ![Register for DevOps](../images/DEVOPS_REGISTRATION.png)
  * You'll receive a confirmation message.
  * Your credentials will be forwarded to the email address associated with your Ping Identity account.

!!! info "Saving Credentials"
    Upon receiving your key, ensure that you follow the instructions below for saving these via the `ping-devops` utility.

Example:

* `PING_IDENTITY_DEVOPS_USER=jsmith@example.com`
* `PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2`

## Saving Your DevOps User and Key

The best way to save your DevOps User/Key is to use the Ping Identity DevOps utility `ping-devops`.

!!! info "ping-devops Setup"
    Installation instructions for `ping-devops` can be found in the [ping-devops Tool](pingDevopsUtil.md) document.

To save your DevOps credentials, run `ping-devops config` and supply your credentials when prompted.

Once `ping-devops` is installed and configured it will place your DEVOPS USER/KEY into a Ping Identity property file found at
`~/.pingidentity/devops`.  with the following variable names set (see example below).

```text
PING_IDENTITY_DEVOPS_USER=jsmith@example.com
PING_IDENTITY_DEVOPS_KEY=e9bd26ac-17e9-4133-a981-d7a7509314b2
```

You can always view these settings with the `ping-devops info` command after you've configured them.
