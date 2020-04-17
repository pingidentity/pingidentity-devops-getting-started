#!/bin/bash
# Author: Ryan Ivis -- Ping Identity

# !!!! ENDLESS LOOP
# THIS WILL PULL THREAT INTEL EVERY X SECONDS AND PLACE IN THE ENRICHMENT CACHE FOLDER
# AN ENHANCEMENT NEEDS TO OCCUR TO THIS LOGIC TO NEVER WRITE EMPTY YML FILES. IF AN EMPTY FILE IS WRITTEN LOGSTASH CRASHES.

echo "starting and running enrichment process"

touch /usr/share/elasticsearch/enrichment/TorNodes.yml
touch /usr/share/elasticsearch/enrichment/AlienVaultIP.yml

while [ 1 -eq 1 ]
do
  echo "Starting enrichment pull..."
  python /usr/share/elasticsearch/config/bootstrap/enrichment.py
  sleep $THREAT_INTEL_PULL_INTERVAL
done