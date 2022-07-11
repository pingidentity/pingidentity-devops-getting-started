---
title: Adding a Message of the Day (MOTD)
---
# Adding a MOTD

You can create a message of the day (MOTD) JSON file to be provide a MOTD file to our product containers when they start.

## Before you begin

You must:

* Complete the [Get Started](../get-started/introduction.md) example to set up your DevOps environment and run a test deployment of the products.

## Using a MOTD file

To employ a MOTD file:

1. Edit the existing `motd.json` file:
    1. Edit the motd/motd.json file located in your local `pingidentity-devops-getting-started/motd` folder.

1. Create a `motd.json` file in the location of your server profile:
    1. Create a `motd.json` file in the root of the server profile directory being referenced.

    This `motd.json` file will be appended to the `/etc/motd` file used by the provided image.

## Testing the MOTD file

Test the new messages in the `motd.json` file using the `test-motd.sh` script. The script supplies the `JQ_EXPR` value used to pass the message data to the container.

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

The example below shows the messages that are displayed for all product images.

For this example, the messages are only shown from the `validFrom` to `validTo` dates:

```json
{
    "devops" : [
        {
            "validFrom": 20220701,
            "validTo": 20220730,
            "subject": "General Message 1",
            "message": ["This is line # 1",
                        "",
                        "This is line # 3",]
        },
        {
            "validFrom": 20220801,
            "validTo": 20220830,
            "subject": "General Message 2",
            "message": ["Message goes here"]
        }
    ],
    "pingfederate" : [
        {
            "validFrom": 20220701,
            "validTo": 20220830,
            "subject": "PingFederate Message 1",
            "message": ["Message goes here"]
        }
    ]
}
```
