---
title: Using DevOps Hooks
---

# Frequently asked questions

## No egress

**"My container environment isn't allowed to make any external calls to services such as Github or Docker Hub. Can I still use Ping Identity containers?"**

Yes. This is common in production scenarios. To use Ping Identity containers in this situation:

1. [Use an Existing License](../how-to/existingLicense.md)
2. Use an empty remote profile `SERVER_PROFILE_URL=""`
   Optionally, you can [build your profile into the image](../how-to/containerAnatomy.md#built-into-the-image)
3. Turn off license verification with `MUTE_LICENSE_VERIFICATION="true"`
4. Turn off calls to the Message of the Day (MOTD) with `MOTD_URL=""`
