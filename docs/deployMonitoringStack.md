# Deploy a monitoring stack

This example illustrates how to use Cloud Native Computing Foundation (CNCF) monitoring tools with a PingDirectory stack.

There are tools in this stack to:

**Monitor**:
  - Ping Identity software

**Collect metrics**:
  - [Prometheus](https://prometheus.io/)
  - [Alertsmanager](https://github.com/prometheus/alertmanager)
  - [cAdvisor](https://github.com/google/cadvisor)
  - [prometheus/statsd_exporter](https://github.com/prometheus/statsd_exporter)
  - [InfluxDB](https://www.influxdata.com/)

**Display metrics**:
  - [Grafana](https://grafana.com/)

**Generate load**:
  - `pingidentity/ldap-sdk-tools`
  - `pingidentity/apache-jmeter`


> Much of the generic Prometheus work is taken from the [vegasbrianc/prometheus](https://github.com/vegasbrianc/prometheus) repository.

## Prerequisites

* You've already been through [Get started](getStarted.md) to set up your DevOps environment and run a test deployment of the products.
* Pull our [pingidentity-getting-started repo](https://github.com/pingidentity/pingidentity-devops-getting-started) to ensure you have the latest sources.
 
## What you'll do

- Deploy the stack
- Watch the load it generates
- Learn a bit about using the tools
- Display the metrics
- Clean up the stack

PingDirectory produces a wide array of metrics. These metrics can be delivered in StatsD format to a location of your choosing using the StatsD monitoring endpoint for PingDirectory.

> See the PingDirectory documentation [StatsD Monitoring Endpoint](https://docs.ping.directory/PingDirectory/8.0.0.0/config-guide/statsd-monitoring-endpoint.html#Properties) for more information. 

## Deploy the monitoring stack

1. From `pingidentity-devops-getting-started/11-docker-compose/10-monitoring-stack` run:
    ```
    docker-compose up -d
    ```

   Running this command will:
    
    a. Deploy the PingIdentity software.

    b. Pull metrics from the Ping Identity software into Prometheus-enabled endpoints (such as,  StatsD metrics using `statsd_exporter`, which formats and hosts the metrics).
    
    c. Have Prometheus scrape the `/metrics` endpoint on `statsd_exporter`.

    d. Generate load to have metrics worth looking at, and push the metrics from the client application (JMeter) to InfluxDB.
    
    e. Deploy a dashboard in Grafana to visualize the metrics from Prometheus and other tools.


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
  
* The PingDirectory configuration looks like this:

   ```text
   pingdirectory
       └── pd.profile
           └── dsconfig
               └── 15-prometheus-stats.dsconfig
   ```

   * The baseline server profile. 
   
   * A single file with two `dsconfig` commands to create the StatsD monitoring endpoint and define where to push the metrics. 
      
    > Traditional profile layering is thought of as getting the profiles from multiple Git repos. However, sending a portion of a profile using the mounted `/opt/in` volume, and getting the rest of the profile information from a Git repo can still be considered layering. 

* StatsD-Exporter

  The configuration file `pingdirectory-statsd-mapping.yml` defines which metrics to ingest and how to format them for Prometheus. This file is mounted to a location that is referenced from an argument passed to the startup command from the `docker-compose.yaml` file.

* Prometheus 

  `prometheus.yml` defines when and where to look for metrics and any relevant alerting files. 

* InfluxDB
  `influxdb.conf` prepares InfluxDB to receive metrics from JMeter. 

* cAdvisor 

  Specifically for Docker Compose, cAdvisor mounts to the actual Docker processes. 

* alertmanager 

  This can be used to set thresholds on metrics, and optionally send notifications. An example threshold is defined in `configs/prometheus/alert.rules`, and referenced in `prometheus.yml`. Sending notifications is defined in `configs/alertmanager/config.yml`.

* Grafana 

  Grafana is a data visualizer. In the Grafana configurations, you'll find: 
  
  - The definition of datasources: `datasources/datasource.yml`. 
  - The definitions of dashboards. 
    
  Grafana and Prometheus runtime data is stored in a Docker volume, so if you start and stop the containers, you'll not lose your work. However, it's still a good practice when building dashboards in Grafana to export the dashboard and add the JSON file to the `dashboards` folder. 

### How load is generated

#### Auto-generated load

Traffic is generated in PingDirectory using our `ldap-sdk-tools` or `apache-jmeter` images. 
When PingDirectory is healthy, these tools will run as individual services based on the use case being implemented.

You can view the logs of any of these services directly with `docker-compose logs -f <service_name>`. For example:

```shell
docker-compose logs -f searchrate
```

#### Generating your own load

* **Option 1** 

  The most common way to generate load is by using the `pingidentity/apache-jmeter` image. To be effective with this tool, see [JMeter usage](../docs/docker-images/apache-jmeter/README.md).

* **Option 2** 

  To run another test using the `ldap-sdk-tools` utility, see [ldap-sdk-tools](../docs/docker-images/ldap-sdk-tools/README.md).

* **Option 3** 

  Use tools available on the PingDirectory server:

  1. Shell into the PingDirectory server:
   
     ```shell
     docker container exec -it 10-monitoring-stack_pingdirectory_1 sh
     ```

  2. Run the `modrate` tool. Enter:

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

     > You also can return to the terminal running `modrate` after you change the `modrate` parameter settings to see the effect in Grafana. 

### Display the traffic metrics

Now that you actually have some data worth looking at....

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

In Grafana, go to Dashboards -> Manage. The pre-populated dashboards with your live load results are displayed.

## Clean up the stack

To bring down the stack and remove the data stored in the Docker volumes, enter:

```shell
docker-compose down
docker volume rm 10-monitoring-stack_grafana_data
docker volume rm 10-monitoring-stack_prometheus_data
```
