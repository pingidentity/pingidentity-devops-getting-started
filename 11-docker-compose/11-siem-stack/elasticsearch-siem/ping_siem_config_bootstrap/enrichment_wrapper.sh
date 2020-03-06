#!/bin/bash
#
# Author: Ryan Ivis -- Ping Identity
# !!!! ENDLESS LOOP
# THIS WILL PULL THREAT INTEL EVERY X SECONDS AND PLACE IN THE ENRICHMENT CACHE FOLDER
#

echo "starting and running enrichment process"

while [ 1 -eq 1 ]
do
  echo "Starting enrichment pull..."
  python /usr/share/elasticsearch/config/bootstrap/enrichment.py
  sleep $THREAT_INTEL_PULL_INTERVAL
done