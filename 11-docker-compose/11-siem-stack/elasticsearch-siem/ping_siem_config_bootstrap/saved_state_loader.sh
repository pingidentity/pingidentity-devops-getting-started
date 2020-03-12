#!/bin/bash
# Simple script to load elasticsearch templates and kibana saved ndjson.
# Author: Ryan Ivis -- Ping Identity

es_status="red"
kib_status="red"

#Wait for ElasticSearch API to go Green before importing templates
while [ "$es_status" != "green" ]
do
  echo "Status Not Green Yet"
  sleep 3
  health=$(curl -s -u elastic:$ELASTIC_PASSWORD --insecure https://es01:9200/_cluster/health)
  es_status=$(expr "$health" : '.*"status":"\([^"]*\)"')
done

echo $health
echo "Loading! -- ElasticSearch Index Templates"
curl -X PUT "https://es01:9200/_template/pf_audit?pretty" --insecure -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@/usr/share/elasticsearch/config/es_config/pf_template.json"
curl -X PUT "https://es01:9200/_template/pd_access?pretty" --insecure -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@/usr/share/elasticsearch/config/es_config/pd_template.json"
curl -X PUT "https://es01:9200/_template/pa_audit?pretty" --insecure -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@/usr/share/elasticsearch/config/es_config/pa_template.json"

#Wait for Kibana API to go Green before importing saved objects
echo "Waiting for Kibana status green, prior to loading saved objects..."
while [ "$kib_status" != "Looking good" ]
do
	echo "Status Not Looking green Yet Kibana"
	sleep 3
	health=$(curl -s -u elastic:$ELASTIC_PASSWORD --insecure https://kibana:5601/api/status)
	echo $health
	kib_status=$(expr "$health" : '.*"nickname":"\([^"]*\)"')
done

echo "Loading! -- Kibana Saved Objects."
curl -X POST "https://kibana:5601/api/saved_objects/_import" --insecure -u elastic:$ELASTIC_PASSWORD -H "kbn-xsrf: true" --form file="@/usr/share/elasticsearch/config/kibana_config/kib_base.ndjson"

echo "bootstrap execution complete."

