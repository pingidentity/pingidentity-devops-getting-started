# Monitoring our product stacks

This use case describes how to use Cloud Native Computing Foundation (CNCF) monitoring tools with a PingDirectory stack.

Monitoring tools used:
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Alertsmanager](https://github.com/prometheus/alertmanager)
- [cAdvisor](https://github.com/google/cadvisor)
- [prometheus/statsd_exporter](https://github.com/prometheus/statsd_exporter)

> Much of the generic Prometheus work is taken from the [vegasbrianc/prometheus](https://github.com/vegasbrianc/prometheus) repository.

## What you'll do

PingDirectory produces a wide array of metrics. These metrics can be delivered in StatsD format to a location of your choosing using the StatsD monitoring endpoint for PingDirectory.

> See the PingDirectory documentation [StatsD Monitoring Endpoint](https://docs.ping.directory/PingDirectory/8.0.0.0/config-guide/statsd-monitoring-endpoint.html#Properties) for more information. 

To get metrics on a dashboard in Grafana, you'll: 

1. Turn on the StatsD monitoring endpoint in PingDirectory.

2. Push metrics in stats to `statsd_exporter`, which formats and hosts the metrics.

3. Have Prometheus scrape the `/metrics` endpoint on `statsd_exporter`.

4. Have a dashboard in Grafana visualize the metrics from Prometheus. 

## Deploy the monitoring stack

1. From `pingidentity-devops-getting-started/11-docker-compose/10-monitoring-stack` run:
    ```
    docker-compose up -d
    ```

2. Wait for PingDirectory to become healthy. For example:

    ```shell
    docker container ls --filter name=pingdirectory_1 --format 'table {{.Names}}\t{{.Status}}'                                
    ```

   The results displayed will be similar to this:
   
    ```shell
    NAMES                                 STATUS
    10-monitoring-stack_pingdirectory_1   Up 2 hours (healthy)
    ```

### About the configuration

There's a lot that can be discussed regarding the configuration. We'll focus on what is key to making this use case functional with minimal intervention, and describe what you may want to edit. 
  
> All of the relevant configurations are located in your local `pingidentity-devops-getting-started/11-docker-compose/10-monitoring-stack/configs` directory.
  
* The PingDirectory configuration comprises:

   ```text
   pingdirectory
       └── pd.profile
           └── dsconfig
               └── 15-prometheus-stats.dsconfig
   ```

   * The baseline server profile. 
   
   * A single file with two `dsconfig` commands to create the StatsD monitoring endpoint and define where to push the metrics. 
      
    > Traditional profile layering is thought of as getting the profiles from multiple Git repos, but sending a portion of a profile via `/opt/in` and the rest from a Git repo can still be considered layering. 

* StatsD-Exporter

  The configuration file `pingdirectory-statsd-mapping.yml` defines which metrics to ingest and how to format them for Prometheus. This the file is mounted to a location that is pointed at from an argument passed to the startup command via the docker-compose.yaml file.

* Prometheus 

  `prometheus.yml` simply defines when and where to look for metrics and any relevant alerting files. 

* cAdvisor 

  Specifically for Docker Compose, cadvisor mounts to the actual Docker processes. 

* alertmanager 

  This can be used to set thresholds on metrics and optionally send notifications. An example threshold is defined in `configs/prometheus/alert.rules`. and referenced in `prometheus.yml`. Sending notifications is defined in `configs/alertmanager/config.yml`

* Grafana 

  Grafana is a data visualizer. In the Grafana configurations, you'll find: 
  
  - The definition of datasources: `datasources/datasource.yml`. 
  
  - The definitions of dashboards. 
    
  Grafana and Prometheus runtime data is stored in a Docker volume, so if you start and stop the containers, you'll not lose your work. However, it's still a good practice when building dashboards in Grafana, to export the dashboard and add the JSON file to the `dashboards` folder. 

### Generate load

When the stack is running, you *can* go to Grafana URL and view the dashboards, but there's little useful data in the dashboards until traffic is going through the containers. 

You can generate traffic in PingDirectory using our `ldap-sdk-tools` utility. 

> See [The `ldap-sdk-tools` utility](ldapsdkUtil.md) for more information.

1. To run the `ldap-sdk-tools` utility, open a shell in the PingDirectory container: 

   ```shell
   docker container exec -it 10-monitoring-stack_pingdirectory_1 sh
   ```

2. Then run the `modrate` tool. Enter:

   ```shell
   modrate \
   --hostname localhost --port 636 --bindDN cn=administrator --bindPassword 2FederateM0re \
   --entryDN "uid=user.[0-4],ou=people,dc=example,dc=com" \
   --useSSL --trustAll \
   --attribute description --valueLength 12 --numThreads 10 --ratePerSecond 20
   ```

   > `modrate` runs in the foreground in the container, so be ready to open another terminal if necessary to avoid stopping `modrate`.

   You'll see output similar to:

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

   > You can return to this after you've displayed these traffic metrics, and change the `modrate` parameter settings to see the effect in Grafana. 

### Display the traffic metrics

The metrics are displayed at these URLs:

| Tool | Description | URL | Credentials |
| --- | --- | --- | --- |
| Grafana | Data displayed in dashboards. | `http://localhost:3000` | admin / 2FederateM0re |
| PingDirectory | Raw StatsD data. | `http://localhost:9102/metrics` | administrator / 2FederateM0re |
| cAdvisor | Container resource metrics. | `http://localhost:8080` | n/a |
| node-exporter | Raw node metrics. | `http://localhost:9100/metrics` | n/a |
| alertmanager | Alerts displayed. | `http://localhost:9093/#/alerts` | n/a |
| Prometheus | To query collected data. | `https://localhost:9090` | n/a |

> The Grafana dashboards correspond to the dashboard definitions in `configs/grafana/provisioning/dashboards`.

## Cleanup the stack

To bring down the stack and remove the data stored in the Docker volumes, enter:

```shell
docker-compose down
docker volume rm 10-monitoring-stack_grafana_data
docker volume rm 10-monitoring-stack_prometheus_data
```