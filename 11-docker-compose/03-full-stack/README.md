# 03-full-stack

This is the full stack of the Ping Identity solutions you can deploy and their connection information.

    > The user credentials needed for each solution are preset and provided in this document. You can change these credentials, however, it may make it more difficult for us to help you if you encounter issues.

## PingDirectory

When the status of the PingDirectory instance shows that it is healthy and running, you can use any of the following solutions or methods to connect to PingDirectory:

* Use OAuthPlayground:

  1. In a browser, enter [https://localhost:9031/OAuthPlayground](https://localhost:9031/OAuthPlayground).
  2. Click the `implicit` link.
  3. Click `Submit`.
  4. Log in with these credentials: 
  
    * User: `user.0`
    * Password: `2FederateM0re`

* Use PingDataConsole to manage PingDirectory:

  1. In a browser, enter [https://localhost:8443/console](https://localhost:8443/console)
  2. Log in using these credentials:
  
    * Server: `pingdirectory` 
    * User: `Administrator` 
    * Password: `2FederateM0re`

* Use Apache Directory Studio:

  * LDAP Port: 1389
  * LDAP BaseDN: dc=example,dc=com
  * Root Username: cn=administrator
  * Root Password: 2FederateM0re

* View the LDAP traffic for PingDirectory. This is exposed on LDAP port 1636:

  * In a browser, enter [https://localhost:1636/dc=example,dc=com](https://localhost:1636/dc=example,dc=com).

## PingFederate

When the status of the PingFederate instance shows that it is healthy and running, you can display the PingFederate management console:

  1. In a browser, enter [https://localhost:9999/pingfederate/app](https://localhost:9999/pingfederate/app).
  2. Log in with these credentials: `Administrator / 2FederateM0re`

## PingAccess

When the status of the PingFederate instance shows that it is healthy and running, you can display the PingAccess management console:

  1. In a browser, enter [https://localhost:9000](https://localhost:9000).
  2. Log in with these credentials: `Administrator / 2FederateM0re`
  
    > You will be asked to accept the license agreement and to change the password.
