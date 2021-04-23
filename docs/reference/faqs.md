---
title: Using DevOps Hooks
---

# Frequently Asked Questions

## No Egress

**My container environment isn't allowed to make any external calls to things like Github or Docker Hub. Can I still use PingIdentity containers?**

Yes. This is rather common in production scenarios. Here's what you'll want to do:

1. [Use an Existing License](../how-to/existingLicense.md)
2. Use an empty remote profile `SERVER_PROFILE_URL=""`. Optionally you can [build your profile into the image](../how-to/containerAnatomy.md#built-into-the-image)
3. Turn off license verification with `MUTE_LICENSE_VERIFICATION="true"`
4. Turn of calls to the Message of the Day with `MOTD_URL=""`
