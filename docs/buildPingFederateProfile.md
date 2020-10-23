# Building a PingFederate Profile From your Current Deployment.

The term "profile" can vary in many instances. Here we will focus on two types of profiles for PingFederate: configuration archive, and bulk export. We will discuss the similarities and differences between two as well as how to build either from a running PingFederate environment.

## Prerequisite

* You've already been through [Get Started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
  
* You understand our [product container anatomy](containerAnatomy.md).

* Recommended: You've read through [Customizing Server Profiles](profiles.md)

## Similarities

The two profile methods we are covering are:
- **bulk api export** - the resulting `.json` from the admin api at /bulk/export. typically saved as `data.json`
- **configuration archive** Pulled either from the admin UI - Server > Configuration Archive or from the admin API at `/configArchive`. We'll call the result of this output `data.zip` or the `/data` folder. 

<!-- INSERT LINK ON NEXT LINE FOR PF CONFIG DEPLOYMENTS -->
> Deciding which method you use should be based on how you plan to [deploy configurations updates](LINKNEEDED)

Both of these methods are considered file-based profiles. This means a "complete profile" looks like a **subset** of files that you would typically find in a running pingfederate filesystem. Again, this is a **subset** of files. Specifically, the minimial number of files needed to achieve your PingFederate configuration. All additional files that are not specific to your configuration should be left out as they will be filled in by the PingFederate docker image. (Refer to [container anatomy](containerAnatomy.md) for additional details).

Considering the above, familiarity with the PingFederate filesystem will help you achieve the optimal profile. Some key information can be found in [profile structures](profileStructures.md). But, to put it simply, you want to at least save every file outside of `pingfederate/server/default/data` that you've edited

Additionally, all files that are included in the profile should also be environment agnostic. This typically means turning hostnames and secrets into [variables that can be delivered from the orchestration layer](profileSubstitution.md).

## Bulk API Export Profile Method

#### What You'll Do

A summary of the resulting process: 
1. Export a `data.json` from /bulk/export
2. Configure and run bulkconfig tool
3. Export Key Pairs
4. base64 encode exported key pairs
5. add `data.json.subst` to your profile at `instance/bulk-config/data.json.subst`

> Before addressing the above steps, we will look at this in a more comprehensive way

A PingFederate Admin/Console will import a `data.json` on startup if it finds it in `instance/bulk-config/data.json`. 

The PF admin api `/bulk/export` endpoint will output a large json blob that is representative of the entire `pingfederate/server/default/data` folder, pingfederate 'core config', or a representation of anything you would configure from the pingfederate UI. You could consider it "the configuration archive in json format". 

So, you could just: 
1. Go to a running pingfederate, run: 
  ```shell
  curl --location --request GET 'https://pingfederate-admin.ping-devops.com/pf-admin-api/v1/bulk/export' \
    --header 'X-XSRF-Header: PingFederate' \
    --user "administrator:${passsword}" > data.json
  ```
2. Save data.json into a profile at `instance/bulk-config/data.json`
3. delete everything except `pf.jwk` in `instance/server/default/data`

And you will have a bulk api export "profile". This is handy because the entire config is on a single file and if you store it in source control you then only have to compare differences on one file. However, there's _much more_ hidden value beyond being on one file.

### Make the Bulk API Export "Profile Worthy"


By default, the resulting `data.json` from the export contains encrypted values, and to import this file, your pingfederate needs to have the corresponding master key (`pf.jwk`) in `pingfederate/server/default/data`. Note, in the devops world, we call this folder `instance/server/default/data`. However, each of the encrypted values also have the option to be replaced with an unencrypted form and, when required, a corresponding password. 

For example the ssl server cert from the [pingfederate baseline profile](https://github.com/pingidentity/pingidentity-server-profiles/tree/master/baseline/pingfederate) when exported to data.json looks like: 

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

But this master key dependent form can be converted to:

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

What happened:
1. Exported the private key+cert of the server cert with alias `sslservercert`. Upon export, a password is requested and `2FederateM0re` was used. This results in download of a pssword protected `.p12` file. 
2. on data.json key name `encryptedPassword` converted to just `password`
3. the value for `fileData` is replaced with a base64 encoded version of the exported `.p12` file.

This is a process that can be used for all encrypted items and environment specific items:
- Key Pairs (.p12)
- Trusted Certs (x509)
- Admin Password
- Data Store Passwords
- Integration Kit Properties
- Hostnames

Now, if you follow this through the entire data.json, it would take a while, and you would be left with a file that is unacceptable for source control (since it's completely unencrypted). So, the next logical step is to abstract the unencrypted values and replace with variables. Then the values can be stored in a secrets management and the variablized file can be in source control. 

Doing all this would manually would take a long time, fortunately, there's a [tool for this!](../99-helper-scripts/ping-bulkconfigtool)
Detailed steps for using the tool are documented next to where it is stored. The general concept is to point the tool at the `data.json` and a config file. After running you will be left with a `data.json.subst` and a list of environment variables waiting to be filled. 

The `data.json.subst` form of our example above will look like:
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

The variablized `data.json.subst` is now a good candidate to for commiting to source control. The resulting `env_vars` file can be used as a guideline for secrets that should be managed externally and only delivered to the container/image as needed for it's specific environment. 

### Additional Notes

- The bulk api export is intended to be used as aa _bulk_ import. The `/bulk/import` endpoint is destructive and overwrites the entire current admin config.
- If you are in a clustered environment, the pingfederate image will import the `data.json` and also replicate the configuration to engines in the cluster. 


## Config Archive Profiles
