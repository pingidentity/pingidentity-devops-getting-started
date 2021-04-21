---
title: Adding a Message of the Day (MOTD)
---
# Adding a MOTD

You can create a message of the day (MOTD) JSON file to be used to provide an MOTD file to our product containers when they start.

## Prerequisites

* You've already been through [Get Started](../get-started/getStarted.md) to set up your DevOps environment and run a test deployment of the products.

## Use a MOTD File

You can employ a MOTD file in these ways by editing our existing `motd.json` file used by our example use cases, or creating a `motd.json` file in the location of your server profile:

1. To use the MOTD with our example uses cases, edit the
`motd/motd.json` file located in your local `pingidentity-devops-getting-started/motd`.
2. To use a MOTD file for your server profile, create a `motd.json` file in the directory where the `docker-compose.yaml` file you're using for the server profile is located. This `motd.json` file will be appended to the `/etc/motd` file used by the DevOps image.

## Test the MOTD File

Test the new messages in the `motd.json` file using the `test-motd.sh` script. The script supplies the `JQ_EXPR` value used to pass the message data to the Devops image.

1. To test the `motd.json` file locally for our example use cases, from the `pingidentity-devops-getting-started/motd` directory, enter:

    ```sh
    ./test-motd.sh local
    ```

1. To test the `motd.json` file you created in your server profile directory:

    1. Copy the `test-motd.sh` script located in the `pingidentity-devops-getting-started/motd` directory to your server profile directory.

    1. Enter:

        ```sh
        ./test-motd.sh local
        ```

1. To test the `motd.json` with a server profile located in a Github repository:

    1. Ensure the `test-motd.sh` script is located in the local, cloned repository.

    1. From the local, cloned repository, enter:

        ```sh
        ./test-motd.sh github
        ```

## Example motd.json

The example below shows the messages that will be displayed for all product images. For this example, the messages will only be shown from the `validFrom` to `validTo` dates:

```json
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
            "subject": "General Message 2",
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
