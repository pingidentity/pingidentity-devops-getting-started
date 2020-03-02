# The `ldap-sdk-tools` utility

The `ldap-sdk-tools` Docker image gives you easy access to our LDAP Client SDK tools for use with PingDirectory.

## Setup

1. The first time you run the `ldapsdk` script, you'll be prompted to configure your settings. From your local `pingidentity-devops-getting-started` directory, enter:

   ```bash
   ./ldapsdk
   ```
   To edit the settings in the future, enter:

   ```bash
   ldapsdk configure
   ```

2. You can then start the `ldap-sdk-tools` Docker image by entering:

```bash
docker run  -it --rm  --network pingnet  pingidentity/ldap-sdk-tools:latest
```

3. Enter `ls` to list the available tools.