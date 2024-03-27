---
title: PingDirectory Metrics with Prometheus
---
# Enabling PingDirectory Metrics with Prometheus

In the past, enabling metrics for PingDirectory required a manual process to setup the **statsd** configuration to enable the data to be made available to Prometheus. However, PingDirectory now includes an HTTP servlet extension that can be enabled to expose metrics in Prometheus format.

You can refer to the [documentation](https://docs.pingidentity.com/r/en-us/pingdirectory-92/pd_ds_monitor_server_metrics_prometheus) for the `dsconfig` commands to enable the Prometheus metrics.  The link above is for PingDirectory 9.2, but the process is the same for newer versions.

These `dsconfig` commands can be included in a server profile to ensure that the configuration is applied when the server is started.
