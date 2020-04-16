#!/bin/bash

#This script is here to ensure the input and filter plugins are intstalled prior to the launch of the container.
echo "Install latest Elasticsearch Filter Plugin"
bin/logstash-plugin install logstash-filter-elasticsearch

echo "Start Logstash Entrypoint"
exec /usr/local/bin/docker-entrypoint