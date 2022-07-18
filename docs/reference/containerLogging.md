---
title: Container Logging
---

# Container Logging

This document provides an outline of how logging is handled in containerized environments.  Please refer to the provided links at the end of this page for details on implementing a logging solution for your deployments.

## Problem statement

In a containerized deployment model, it is expected that containers (or pods under Kubernetes) will be ephemeral.  Further, the standard practice for application logging in a container is to use `stdout` and, in some cases, `stderr` as the means of streaming logs. Ping product containers follow this practice. As a result, no logs will persist outside the lifecycle of the container or pod.  In particular, if a pod is failing or in crashloop due to a misconfiguration or error, it is impossible to troubleshoot the cause as the logs that might provide information on the crash are lost each time the pod attempts to restart. **It is important, then, to insure that logs are stored external to the container.**

!!! error "In Case You Missed It"
    If a container is stopped for any reason, including crashes, all logging information from the container that is not stored elsewhere is lost.

## Viewing logs

In a Kubernetes deployment, you can view the streaming logs (stdout/stderr) of a container in a pod by issuing the `kubectl logs` command.  This function is useful for quickly examining logs from operational containers.

## Persisting logs

Because you cannot rely on the logs from the container itself for long-term use, you must implement some means of storing the logging information apart from the container itself.

## Logging sidecar

In the Kubernetes model, a common method of maintaining logs is to use the [sidecar model](../deployment/deployK8sUtilitySidecar.md). A logging sidecar is included in the pod and configured to grab the stdout/stderr streams from the application container and persist them to the logging service. Many vendors provide a Docker image for this sidecar that contains the agent for their product. In addition, they usually provide support for configuring the container to connect to their service and format the logs for consumption, such as through environment variables, Kubernetes ConfigMaps, or other means.

Advantages:

- Logs can be sent to different locations at the same time using multiple sidecars
- Access to the cluster node is not required - particularly useful for hosted Kubernetes environments
- No update to the application is required, assuming it dumps logging information to stdout/stderr

Disadvantage:

- Additional resources are required for running the extra container(s), though they tend to be lightweight

## The TAIL_LOG_FILES environment variable

Many Ping products were designed and built for a server-deployed implementation.  As a result, they write log information to files (the old model for logging), rather than to `stdout`.  To ease containerization, an environment variable (**`TAIL_LOG_FILES`**) is included in the Docker images and this variable is fed to a function that streams these files to `stdout` as they are written.

While Ping includes key log files as defaults, this variable can be modified.  You can add additional log files to this variable to include them in the `stdout` stream.  See [each product Dockerfile](https://github.com/pingidentity/pingidentity-docker-builds) for the default value of this variable for the product in question.

## References

The list below is not intended to be comprehensive but should provide a good starting point for understanding how logging works and what you can do to retain logs from your deployments.  

!!! note "Examples only"
    Any vendor listed here should not be considered an endorsement or recommendation by Ping Identity for that service. Refer to the documentation for the image in question for further assistance.

- [Kubernetes Logging Documentation](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- [Docker Logging Documentation](https://docs.docker.com/config/containers/logging/)
- Docker Hub images, listed alphabetically:
    - [AWS Cloudwatch](https://hub.docker.com/r/amazon/cloudwatch-agent)
    - [Datadog](https://hub.docker.com/r/datadog/agent)
    - [Fluentd](https://hub.docker.com/_/fluentd)
    - [Graylog](https://hub.docker.com/u/graylog)
    - [Rsyslog](https://hub.docker.com/u/rsyslog)
    - [Sematext](https://hub.docker.com/u/sematext)
    - [Splunk Forwarder](https://hub.docker.com/r/splunk/universalforwarder/)
    - [Sumologic](https://hub.docker.com/r/sumologic/collector)
