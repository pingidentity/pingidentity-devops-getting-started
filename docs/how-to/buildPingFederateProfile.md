# Building a PingFederate profile from your current deployment

The term "profile" can vary in many instances. Here we will focus on two types of profiles for PingFederate: configuration archive, and bulk export. We will discuss the similarities and differences between two as well as how to build either from a running PingFederate environment.

## Before you begin

You must:

* Complete [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products
* Understand our [Product Container Anatomy](../reference/config.md)

You should:

* Review [Customizing Server Profiles](profiles.md)

## Overview of profile methods

There are two file-based profile methods that we cover:

* Bulk API Export
    * The resulting `.json` from the admin API at /bulk/export
    * Typically saved as `data.json`
* Configuration Archive
    * Pulled either from the admin UI - Server > Configuration Archive or from the admin API at `/configArchive`
    * We call the result of this output `data.zip` or the `/data` folder

<!-- TODO INSERT LINK ON NEXT LINE FOR PF CONFIG DEPLOYMENTS -->
<!-- Deciding which method you use should be based on how you plan to [deploy configurations updates](LINKNEEDED) -->

A file-based profile means a "complete profile" looks like a **subset** of files that you would typically find in a running PingFederate filesystem.

This subset of files represents the minimal number of files needed to achieve your PingFederate configuration. All additional files that aren't specific to your configuration should be left out because the PingFederate Docker image filles them in. For more information, see [Container Anatomy](containerAnatomy.md).

Familiarity with the PingFederate filesystem will help you achieve the optimal profile. For more information, see [profile structures](../reference/profileStructures.md).

!!! note "Save files"
    You should save every file outside of `pingfederate/server/default/data` that you've edited.

Additionally, all files that are included in the profile should also be environment agnostic. This typically means turning hostnames and secrets into variables that can be delivered from the [Orchestration Layer](profilesSubstitution.md).

## The Bulk API Export Profile Method

### About this method

You will:

1. Export a `data.json` from /bulk/export
1. Configure and run bulkconfig tool
1. Export Key Pairs
1. base64 encode exported key pairs
1. Add `data.json.subst` to your profile at `instance/bulk-config/data.json.subst`

> Rather than just following the above steps, we will look at this comprehensively to understand purpose. Use the steps for reference as needed.

A PingFederate Admin Console imports a `data.json` on startup if it finds it in `instance/bulk-config/data.json`.

The PF admin API `/bulk/export` endpoint outputs a large .json blob that is representative of the entire `pingfederate/server/default/data` folder, PingFederate 'core config', or a representation of anything you would configure from the PingFederate UI. You could consider it "the configuration archive in .json format".

#### Steps

1. Go to a running PingFederate, and run:

    ```sh
    curl \
      --location \
      --request GET 'https://pingfederate-admin.ping-devops.com/pf-admin-api/v1/bulk/export' \
      --header 'X-XSRF-Header: PingFederate' \
      --user "administrator:${passsword}" > data.json
    ```

1. Save data.json into a profile at `instance/bulk-config/data.json`.
1. Delete everything except `pf.jwk` in `instance/server/default/data`.

#### Result

You have a bulk API export "profile". This is handy because the entire config is in a single file and if you store it in source control, then you only have to compare differences in one file. However, there is more value than being in one file.

### Making the bulk API export "profile-worthy"

By default, the resulting `data.json` from the export contains encrypted values, and to import this file, your PingFederate needs to have the corresponding master key (`pf.jwk`) in `pingfederate/server/default/data`.

!!! Note "Encrypted values in single file"
    In the DevOps world, we call this folder `instance/server/default/data`. However, each of the encrypted values also have the option to be replaced with an unencrypted form and, when required, a corresponding password.

#### Example

The SSL Server Certificate from the [PingFederate Baseline Profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingfederate) when exported to data.json has the following syntax:

```json
{
    "resourceType": "/keyPairs/sslServer",
    "operationType": "SAVE",
    "items": [
        {
            "id": "sslservercert",
            "fileData": "MIIRBwIBAzCCEMAGCSqGSIb3DQEHAaCCELEEghCtMIIQqTCCCeUGCSqGSIb3DQEHAaCCCdYEggnSMIIJzjCCCcoGCyqGSIb3DQEMCgECoIIJezCCCXcwKQYKKoZIhvcNAQwBAzAbBBQu6vDERQZX3uujWa7v_q3sYN4Q0gIDAMNQBIIJSFtdWbvLhzYrTqeKKiJqiqROgE0E4mkVvmEC6NwhhPbcH37IDNvVLu0umm--CDZnEmlyPpUucO345-U-6z-cskw4TbsjYIzM10MwS6JdsyYFTC3GwqioqndVgBUzDh8xGnfzx52zEehX8d-ig1F6xYsbEc01gTbh4lF5MA7E7VfoTa4hWqtceV8PQeqzJNarlZyDSaS5BLn1J6G9BYUze-M1xGhATz7F2l-aAt6foi0mwIBlc2fwsdEPuAALZgdG-q_V4gOJW2K0ONnmWhMgMLpCL42cmSb
            ... more encrypted text ...
            Yxpzp_srpy4LHNdgHqhVBhqtDrjeKJDRfc1yk21P5PpfEBxn5MD4wITAJBgUrDgMCGgUABBQLBpq8y79Pq1TzG1Xf6OAjZzBZaQQUC4kD4CkcrH-WTQhJHud850ddn08CAwGGoA==",
            "encryptedPassword": "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2Iiwia2lkIjoiRW1JY1UxOVdueSIsInZlcnNpb24iOiIxMC4xLjEuMCJ9..l6PJ55nSSvKHl0vSWTpkOA.i7hpnnu2yIByhyq_aGBCdaqS3u050yG8eMRGnLRx2Yk.Mo4WSkbbJyLISHq6i4nlVA"
        }
    ]
}
```

You can convert this master key dependent form to:

```json
{
    "operationType": "SAVE",
    "items": [{
        "password": "2FederateM0re",
        "fileData": "MIIRCQIBAzCCEM8GCSqGSIb3DQEHAaCCEMAEghC8MIIQuDCCC28GCSqGSIb3DQEHBqCCC2AwggtcAgEAMIILVQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYwDgQIjXWLRGuGNIQCAggAgIILKOgCQ9onDqBPQsshsaS50OjWtj\/7s47BUYal1YhO70fBup1a82WGHGhAvb\/SY1yOhqQR+TloEBOPI5cExoGN\/Gvw2Mw5\/wkQZZMSHqxjz68KhN4B0hrsOf4rqShB7jsz9ebSml3r2w0sUZWR73GBtBt1Y3wIlXLS2WtqdtHra9VnUqp1eOk+xenjuWM+u2ndDD43GgKB3n8mNBSSVBqx6ne7aSRJRuAUd+HAzLvSeXjTPMObI1Jod2F+7
        ... more base64 encoded exported .p12 ...
        5QJ15OJp2iEoVBWxogKf64s2F0iIYPoo6yjNvlidZCevP564FwknWrHoD7R8cIBrhlCJQbEOpOhPg66r4MK1CeJ2poaKRlMS8HGcMRaTpaqD+pIlgmUS6xFw49vr9Kwfb7KteRsTkNR+I8A7HjUpuCMSUwIwYJKoZIhvcNAQkVMRYEFOb7g1xwDka5fJ4sqngEvzTyuWnpMDEwITAJBgUrDgMCGgUABBRlJ+D+FR\/vQbaTGbKDFiBK\/xDbqQQIAjLc+GgRg44CAggA",
        "id": "sslservercert"
    }],
    "resourceType": "/keyPairs/sslServer"
}
```

The process:

1. You exported the private key+cert of the server cert with alias `sslservercert`. Upon export, a password is requested and `2FederateM0re` was used. This results in download of a password protected `.p12` file.
1. The data.json key name `encryptedPassword` converted to just `password`.
1. The value for `fileData` is replaced with a base64 encoded version of the exported `.p12` file.

This is a process that can be used for all encrypted items and environment specific items:

* Key Pairs (.p12)
* Trusted Certs (x509)
* Admin Password
* Data Store Passwords
* Integration Kit Properties
* Hostnames

Leaving these confidential items as unencrypted text is unacceptable for source control. The next logical step is to abstract the unencrypted values and replace them with variables. Then, the values can be stored in a secrets management tool (such as Hashicorp Vault) and the variablized file can be in source control.

Converting each of the encrypted keys for their unencrypted counterparts and hostnames with variables is cumbersome and can be automated. As we know in DevOps, if it _can_ be automated, it _must_ be automated. For more information, see [Using Bulk Config Tool](#using-bulk-config-tool).

A variablized `data.json.subst` is a good candidate for committing to source control after removing any unencrypted text. 

### Using Bulk Config Tool

The [ping-bulkconfig-tool](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/99-helper-scripts/ping-bulkconfigtool) reads your data.json and can optionally:
    
  - Search and replace (e.g. hostnames)
  - Clean, add, and remove json members as required.
  - Tokenize the configuration and maintain environment variables.

The bulk export tool can process a bulk `data.json` export according to a configuration file with functions above. After running the tool, you are left with a `data.json.subst` and a list of environment variables waiting to be filled.

The `data.json.subst` form of our previous example will look like:
```json
{
    "operationType": "SAVE",
    "items": [{
        "password": "${keyPairs_sslServer_items_sslservercert_sslservercert_password}",
        "fileData": "${keyPairs_sslServer_items_sslservercert_sslservercert_fileData}",
        "id": "sslservercert"
    }],
    "resourceType": "/keyPairs/sslServer"
}
```

!!! Note "Bulk Config Tool Limitations"
    The bulk config tool can manipulate data.json but it cannot populate the resulting password or fileData variables because there is no API available on PingFederate to extract these. These variables can be filled using with externally generated certs and keys using tools like `openssl`, but that is out of scope for this document.

The resulting `env_vars` file can be used as a guideline for secrets that should be managed externally and only delivered to the container/image as needed for its specific environment.

#### Prerequisites
<!-- TODO: This docker image should be next to the rest of our images -->

1. The bulk export utility comes in pre-compiled source code. Build an image with:

    ```
    docker build -t ping-bulkexport-tools:latest .
    ```

2. Your [data.json](#steps) copied to `pingidentity-devops-getting-started/99-helper-scripts/ping-bulkconfigtool/shared/data.json`
#### Example

A sample command of the ping-bulkconfig-tool

```
docker run --rm -v $PWD/shared:/shared ping-bulkexport-tools:latest /shared/pf-config.json /shared/data.json /shared/env_vars /shared/data.json.subst > /shared/convert.log
```

Where:

- `-v $PWD/shared:/shared` - bind mounts `ping-bulkconfigtool/shared` folder to /shared in the container
- `/shared/pf-config.json` - input path to [config file](#configure-bulk-tool) which defines how to process the bulk export `data.json` file from PingFederate.
- `/shared/data.json` - input path to data.json result of /pf-admin-api/v1/bulk/export PingFederate API endpoint.
- `/shared/env_vars` - output path to store environment variables generated from processing
- `/shared/data.json.subst` - output path to processed data.json

After running the above command, you will see `env_vars` and `data.json.subst` in the `ping-bulkconfigtool/shared` folder.

#### Configure Bulk Tool
Instructions to the bulk config tool are sent via pf-config.json file. Where available commands include:
##### search-replace
- A simple utility to search and replace string values in a bulk config json file.
- Can expose environmental variables.

Example: replacing an expected base hostname with a substition.
```
  "search-replace":[
    {
      "search": "data-holder.local",
      "replace": "${BASE_HOSTNAME}",
      "apply-env-file": false
    }
  ]
```
##### change-value
- Searches for elements with a matching identifier, and updates a parameter with a new value.

Example: update keyPairId against an element with name=ENGINE.
```
  "change-value":[
  	{
          "matching-identifier":
          {
          	"id-name": "name",
          	"id-value": "ENGINE"
          },
  	  "parameter-name": "keyPairId",
  	  "new-value": 8
  	}
  ]
```

##### remove-config
- Allows us to remove configuration from the bulk export.

Example: you may wish to remove the ProvisionerDS data store:
```
  "remove-config":[
  	{
  	  "key": "id",
	  "value": "ProvisionerDS"
  	}
  ]
```

Example: you may wish to remove all SP Connections:
```
  "remove-config":[
  	{
  	  "key": "resourceType",
	  "value": "/idp/spConnections"
  	}
  ]
```

##### add-config
- Allows us to add configuration to the bulk export.

Example: you may wish to add the CONFIG QUERY http listener in PingAccess
```
  "add-config":[
	  {
	    "resourceType": "httpsListeners",
	    "item":
			{
			    "id": 4,
			    "name": "CONFIG QUERY",
			    "keyPairId": 5,
			    "useServerCipherSuiteOrder": true,
			    "restartRequired": false
			}
	  }
  ]
```

Example: you may wish to add an SP connection
```
  "add-config":[
	  {
	    "resourceType": "/idp/spConnections",
	    "item":
		{
                    "name": "httpbin3.org",
                    "active": false,
		    ...
		}
	  }
  ]
```

##### expose-parameters
- Navigates through the JSON and exchanges values for substitions.
- Exposed substition names will be automatically created based on the json path.
    - E.g. ${oauth_clients_items_clientAuth_testclient_secret}
- Can convert encrypted/obfuscated values into clear text inputs (e.g. "encryptedValue" to "value") prior to substituting it. This allows us to inject values in its raw form.

Example: replace the "encryptedPassword" member with a substitution enabled "password" member for any elements with "id" or "username" members. The following will remove "encryptedPassword" and create "password": "${...}".
```
    {
      "parameter-name": "encryptedPassword",
      "replace-name": "password",
      "unique-identifiers": [
          "id",
          "username"
      ]
    }
```

##### config-aliases
- The bulk config tool generates substitution names, however sometimes you wish to simplify them or reuse existing environment variables.

Example: Renaming the Administrator's substitution name to leverage the common PING_IDENTITY_PASSWORD environmental variable.
```
  "config-aliases":[
	{
	  "config-names":[
	    "administrativeAccounts_items_Administrator_password"
	  ],
  	  "replace-name": "PING_IDENTITY_PASSWORD",
  	  "is-apply-envfile": false
  	}
  ]
```

##### sort-arrays
- Configure the array members that need to be sorted. This ensures the array is created consistently to improve git diff.

Example: Sort the roles and scopes arrays.
```
  "sort-arrays":[
        "roles","scopes"
  ]
```

<!-- ####TODO:  Script It

If desired, use of the bulk config tool can be included in a script. `pingidentity-devops-getting-started/99-helper-scripts/ping-bulkconfigtool/pf-profile.sh` is an example of this.

```
sh pf-profile.sh --release mypingfed --password 2FederateM0re
``` -->


### Additional Notes

* The bulk API export is intended to be used as a _bulk_ import. The `/bulk/import` endpoint is destructive and overwrites the entire current admin config.
* If you are in a clustered environment, the PingFederate image imports the `data.json` and replicates the configuration to engines in the cluster.
* Your data.json.subst `"metadata": {"pfVersion": "10.1.2.0"}` should match the PingFederate profile version.
## The Configuration Archive Profiles Method

### About configuration archive-based profiles
You should weigh the pros and cons of configuration archive-based profiles compared to bulk API export profiles. Aside from DevOps principle purists, most people find bulk API export profiles to be more advantagous in most scenarios.

Pros:
* The `/data` folder, opposed to a `data.json` file, is better for [profile layering](profilesLayered.md).
* Configuration is available on engines at startup, which:
    * lowers dependency on the admin at initial cluster startup.
    * enables mixed configurations in a single cluster. Canary-like "roll-out" instead of config pushed to all engines at once.

Cons:

* The `/data` folder contains key pairs in a `.jks`, which makes externally managing keys very difficult.
* Encrypted data is scattered throughout the folder, creating dependency on the master encryption key.

### About this method

You will:

1. Export a `data.zip` archive.
1. Optionally, variablize.
1. Replace the data folder.

<!-- 1. Export a configuration archive.
This can be done through the UI `System > Server > Configuration Archive`
Or via Admin API:
  ```
  curl -u administrator:2FederateM0re -H "X-XSRF-Header: PingFederate" -k https://pingfederate-admin.com/pf-admin-api/v1/configArchive/export --output "${HOME}/Downloads/data.zip"
  ```

  ```
  unzip -d data /path/to/data.zip
  ``` -->
  
## Installing PingFederate Integration Kits

By default, PingFederate is shipped with a handful of integration kits and adapters. If you need other integration kits or adapters in the deployment, manually download them and place them inside `server/default/deploy` of the server profile. You can find these resources in the product download page [here](https://www.pingidentity.com/en/resources/downloads/pingfederate.html).
