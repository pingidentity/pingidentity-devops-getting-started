# Deploy a monitoring stack

This example illustrates how to use Cloud Native Computing Foundation (CNCF) monitoring tools with a PingDirectory stack.

Tools in this stack:

**Gets monitored:**
  - Ping Identity Software

**Collects Metrics:**
  - [Prometheus](https://prometheus.io/)
  - [Alertsmanager](https://github.com/prometheus/alertmanager)
  - [cAdvisor](https://github.com/google/cadvisor)
  - [prometheus/statsd_exporter](https://github.com/prometheus/statsd_exporter)
  - [InfluxDB](https://www.influxdata.com/)

**Displays Metrics:**
  - [Grafana](https://grafana.com/)

**Generates Load:**
  - `pingidentity/ldap-sdk-tools`
  - `pingidentity/apache-jmeter`


> Much of the generic Prometheus work is taken from the [vegasbrianc/prometheus](https://github.com/vegasbrianc/prometheus) repository.

## What you'll do


- Deploy the stack
- Watch the load it generates
- learn a bit about using the tools presented

PingDirectory produces a wide array of metrics. These metrics can be delivered in StatsD format to a location of your choosing using the StatsD monitoring endpoint for PingDirectory.

> See the PingDirectory documentation [StatsD Monitoring Endpoint](https://docs.ping.directory/PingDirectory/8.0.0.0/config-guide/statsd-monitoring-endpoint.html#Properties) for more information. 

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Pull our [pingidentity-getting-started repo](https://github.com/pingidentity/pingidentity-devops-getting-started) to ensure you have the latest sources.
 
## Deploy the monitoring stack

1. From `pingidentity-devops-getting-started/11-docker-compose/10-monitoring-stack` run:
    ```
    docker-compose up -d
    ```

  Just running this command will:
    1. Deploy PingIdentity software 

    2. Pull metrics from the Ping Identity software into Prometheus enabled endpoints. (E.g. statsd metrics with `statsd_exporter`, which formats and hosts the metrics.)
    
    3. Have Prometheus scrape the `/metrics` endpoint on `statsd_exporter`.

    4. Generate load to have metrics worth looking at. Push metrics from the client application (jmeter) to InfluxDB.
    
    5. Deploy a dashboard in Grafana to visualize the metrics from Prometheus and other tools


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

* InfluxDB
  `influxdb.conf` prepares influxdb to receive metrics from jmeter 

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

#### auto-generated
Traffic is generated in PingDirectory using our `ldap-sdk-tools` or `apache-jmeter` images. 
Once PingDirectory is healthy, these tools will run as individual services based on the use case they are achieving.

You can view the logs of any of these services directly with `docker-compose logs -f <service_name>`.
Example:

  ```
  docker-compose logs -f searchrate
  ```

#### BYO Load

**Option 1** 
The most common way to generate load is by using the pingidentity/apache-jmeter image.
To be effective with this tool check out the docs on [usage](../docs/docker-images/apache-jmeter/README.md)

**Option 2** 
To run some other test from the `ldap-sdk-tools` utility, check out the [image docs](../docs/docker-images/ldap-sdk-tools/README.md)

**Option 3** 
Or you can find tools directly on the pingdirectory server:
1. 
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
Now that you actually have some data worth looking at... 

Metrics are displayed at these URLs:

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
