# Ping Identity DevOps Message of the Day (MOTD)

A message of the day json can be used to provide a motd file to Ping Identity product containers when they start.

The name and location of the file should be in the Github `pingidentity-devops-getting-started` repo in the `motd/motd.json` file.

Additionally, if there is a `motd` file in the top level of the server-profile, it will be appended to the `/etc/motd` file of the image.

When modifying this file, the author can test the new messages using the `test-motd.sh` script.

## test-mod.sh script

To test the mod.json on Github, run:

    ./test-motd.sh github

To test the mod.json locally, run:

    ./test-motd.sh local

The script provides the `JQ_EXPR` used that should always match that found in the `09-build-motd.sh` hook.

## Example motd.json

The example below is an example of messages that will be shown for all types of images (i.e. devops) and pingfederate images.  Note that the messages will only be shown starting on the `validFrom` date to the `validTo` date.

```
{
    "devops" : [
        {
            "validFrom": 20190701,
            "validTo": 20190730,
            "subject": "General Message 1",
            "message": ["This is line # 1",
                        "",
                        "This is line # 3",]
        },     
        {
            "validFrom": 20190801,
            "validTo": 20190830,
            "subject": "Genearl Message 2",
            "message": ["Message goes here"]
        }
    ],
    "pingfederate" : [
        {
            "validFrom": 20190701,
            "validTo": 20190830,
            "subject": "PingFederate Message 1",
            "message": ["Message goes here"]
        }
    ]
}
```

## Copyright

Copyright © 2024 Ping Identity. All rights reserved.
