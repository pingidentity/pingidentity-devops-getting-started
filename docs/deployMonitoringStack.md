# Monitoring the Ping Stack

This use case describes how to use Cloud Native Computing Foundation (CNCF) monitoring tools with a PingDirectory stack.

Monitoring tools used:
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Alertsmanager](https://github.com/prometheus/alertmanager)
- [cAdvisor](https://github.com/google/cadvisor)
- [prometheus/statsd_exporter](https://github.com/prometheus/statsd_exporter)

> Much of the generic Prometheus work is taken from [vegasbrianc/prometheus](https://github.com/vegasbrianc/prometheus)

## What you'll do

PingDirectory produces a wide array of metrics. These metrics can be delivered in statsd format to a location of your choosing using the StatsD monitoring endpoint for PingDirectory.

> See the PingDirectory documentation[StatsD Monitoring Endpoint](https://docs.ping.directory/PingDirectory/8.0.0.0/config-guide/statsd-monitoring-endpoint.html#Properties) for more information. 

To get metrics on a dashboard in Grafana, you'll: 
1. Turn on the statsd monitoring endpoint in PingDirectory.
2. Push metrics in stats to a statsd_exporter, which formats and hosts the metrics.
3. Have Prometheus scrape the /metrics endpoint on statsd_exporter.
4. Have a dashboard in Grafana visualize the metrics from Prometheus. 

## Deploy the monitoring stack

1. From `pingidentity-devops-getting-started/11-docker-compose/10-monitoring-stack` run:
    ```
    docker-compose up -d
    ```

2. Wait for PingDirectory to become healthy. For example:

    ```shell
    docker container ls --filter name=pingdirectory_1 --format 'table {{.Names}}\t{{.Status}}'                                
    
    NAMES                                 STATUS
    10-monitoring-stack_pingdirectory_1   Up 2 hours (healthy)
    ```
### Learn about the configuration

  There is a lot that can be discussed regarding the configuration. We'll focus on what is key to making this use case functional with minimal intervention, and describe what you may want to edit. 
  
  > All of the relevant configurations are located in your local `pingidentity-devops-getting-started/11-docker-compose/10-monitoring-stack/configs`.
  
  1. PingDirectory
      ```
      pingdirectory
          └── pd.profile
              └── dsconfig
                  └── 15-prometheus-stats.dsconfig
      ```

      PingDirectory is made up of: 1. the baseline server profile. 2. single file with two dsconfig commands to create the statsd monitoring endpoint, and define where to push the metrics. 
      > Traditional profile layering is thought of as multiple github URLs, but sending a portion of a profile via /opt/in and the rest from a github URL can still be considered layering. 

  2. StatsD-Exporter - the configuration file `pingdirectory-statsd-mapping.yml` defines which metrics to ingest and how to format them for Prometheus. This the file is mounted to a location that is pointed at from an argument passed to the startup command via the docker-compose.yaml file.

  3. Prometheus - `prometheus.yml` simply defines when and where to look for metrics and any relevant alerting files. 

  4. cAdvisor - Specifically for compose, cadvisor mounts to the actual docker processes. 

  5. alertmanager - this can be used to set thresholds on metrics and optionally send notifications. An example threshold is defined in `configs/prometheus/alert.rules`. and referenced on prometheus.yml. Sending notifications is defined in `configs/alertmanager/config.yml`

  6. Grafana - Since Grafana is a data visualizer, in the grafana configs we find: 1. the definition of datasources: `datasources/datasource.yml` 2. definitions of dashboards. 
    Grafana and Prometheus runtime data is stored in a docker volume, so if you start and stop these containers you will not lose your work. But it is still a good practice that If you build another dashboard in Grafana, to export it and add the `.json` file to the `dashboards` folder. 

### Generate load

  Now that the stack is running, we could go in to Grafana and view the dashboards, but there isn't much valuable data on the Ping dashboards until there is actual traffic going through the containers. 

  We will generate traffic on PingDirectory with a tool that is shipped with the product as well as pingidentity/ldap-sdk-tools.
  To run the tool, first exec into the PingDirectory container: 
  ```
  docker container exec -it 10-monitoring-stack_pingdirectory_1 sh
  ```
  Then run the `modrate` tool
  > this will run in the foreground in the container, so be ready to open another terminal if necessary to avoid stopping `modrate`
    
    ```
    modrate \
    --hostname localhost --port 636 --bindDN cn=administrator --bindPassword 2FederateM0re \
    --entryDN "uid=user.[0-4],ou=people,dc=example,dc=com" \
    --useSSL --trustAll \
    --attribute description --valueLength 12 --numThreads 10 --ratePerSecond 20
    ```
  you will see output similar to:

    ```shell
    PingDirectory:ca3f124e78aa:/opt
    > modrate \
    >   --hostname localhost --port 636 --bindDN cn=administrator --bindPassword 2FederateM0re \
    >   --entryDN "uid=user.[0-4],ou=people,dc=example,dc=com" \
    >   --useSSL --trustAll \
    >   --attribute description --valueLength 12 --numThreads 10 --ratePerSecond 20
          Recent       Recent       Recent      Overall      Overall
        Mods/Sec   Avg Dur ms   Errors/Sec     Mods/Sec   Avg Dur ms
    ------------ ------------ ------------ ------------ ------------
          19.998        5.880        0.000       19.998        5.880
          19.998        4.214        0.000       19.998        5.047
          19.999        3.793        0.000       19.998        4.629
          20.001        3.608        0.000       19.999        4.374
    ```
  > you can come back and tweak this command later to watch the changes in Grafana. 

### Watch traffic metrics

Now you can visit a multitude of URLs where metrics are being generated:

  * Grafana - The data formed into nice dashboards: `http://localhost:3000`
    * log in: admin/2FederateM0re
  * PingDirectory - Raw statsd data: `http://localhost:9102/metrics`
  * cAdvisor - for docker container resource metrics: `http://localhost:8080`
  * node-exporter - Raw Node metrics: `http://localhost:9100/metrics`
  * Alertmanager -  `http://localhost:9093/#/alerts`
  * Prometheus - for querying collected data: `https://localhost:9090`

You will see dashboards that correspond to what is in: `configs/grafana/provisioning/dashboards`

## Cleanup

```
docker-compose down
docker volume rm 10-monitoring-stack_grafana_data
docker volume rm 10-monitoring-stack_prometheus_data
```