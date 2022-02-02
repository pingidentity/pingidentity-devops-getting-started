---
title: PingOne Worker App and User Config
---

# PingOne Worker App and User Config

## PingOne Worker App Configuration

To manage PingOne resources other than yourself, you are required to have a PingOne Worker App.

You have 3 options to authenticate to PingOne from pingctl:

* [Authorization Code (w/ PKCE) Flow](#authorization-code-w-pkce-flow-settings) (Recommended and most secure) - Via a PingOne Admin User
* [Implicit Flow](#implicit-flow-settings) - Via a PingOne Admin User
* [Client Credentials Flow](#client-credentials-flow-settings) (Easiest, but most insecure, as a user isn't required)

Additionally, you must set up the proper [roles for your Worker App](#worker-app-roles-settings)

### Authorization Code (w/ PKCE) Flow Settings

The following shows an example of a Worker App setup for Authorization Code (w/ PKCE) Flow:

![](images/pingone-worker-app-authorization_code.png)

### Implicit Flow Settings

The following shows an example of a Worker App setup for Implicit Flow:

![](images/pingone-worker-app-implicit.png)

### Client Credentials Flow Settings

The following shows an example of a Worker App setup for Client Credentials Flow:

![](images/pingone-worker-app-client-credentials.png)

### Worker App Roles Settings

The following shows an example of the minimum roles required.  Typically, these are set up by default.

![](images/pingone-worker-app-roles.png)

## PingOne User Config

When using Authorization Code or Implicit Flows, you need to log in with an Administrative user to use the
Worker App.

The most important item is to add the proper administrative roles to the user.  The following shows
an example of this:

![](images/pingone-user-roles.png)