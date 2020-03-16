#!/bin/bash
# Simple script to load elasticsearch templates, ilm, policies, 
# indexes and kibana saved ndjson.
# Author: Ryan Ivis -- Ping Identity

es_status="red"
kib_status="red"

echo "Starting ElasticSearch Loading Process..."

#Wait for ElasticSearch API to go Green before importing templates
while [ "$es_status" != "green" ]
do
  echo "Status Not Green Yet"
  sleep 3
  health=$(curl -s -u elastic:$ELASTIC_PASSWORD --insecure https://es01:9200/_cluster/health)
  es_status=$(expr "$health" : '.*"status":"\([^"]*\)"')
done

#Load in Index Lifecycle polices
echo "Loading! -- ElasticSearch ILM Policies"
for f in /usr/share/elasticsearch/ilm_policies/*.json
do	
  echo "Processing index lifecycle policy file (full path) $f "
  echo "start"
  fn=$(basename $f)
  n="${fn%.*}"

  echo "Processing file name $n "
  curl -X PUT "https://es01:9200/_ilm/policy/$n?pretty" --insecure -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@$f"
done

#Load in Index Templates This includes mappings, settings, etc.
echo "Loading! -- ElasticSearch Index Templates"
for f in /usr/share/elasticsearch/index_templates/*.json
do	
  echo "Processing index template file (full path) $f "
  echo "start"
  fn=$(basename $f)
  n="${fn%.*}"

  echo "Processing file name $n "
  curl -X PUT "https://es01:9200/_template/$n?pretty" --insecure -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@$f"
done

#Bootstrap all required indexes
echo "Loading! -- Bootstraping Indexes"
for f in /usr/share/elasticsearch/index_bootstraps/*.json
do	
  echo "Processing index bootstrap file (full path) $f "
  echo "start"
  fn=$(basename $f)
  n="${fn%.*}"

  echo "Processing file name $n "
  curl -X PUT "https://es01:9200/$n-000001?pretty" --insecure -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@$f"
done

#Bootstrap all required roles
echo "Loading! -- Bootstraping Roles"
for f in /usr/share/elasticsearch/role_bootstraps/*.json
do  
  echo "Processing role bootstrap file (full path) $f "
  echo "start"
  fn=$(basename $f)
  n="${fn%.*}"

  echo "Processing file name $n "
  curl -X PUT "https://es01:9200/_security/role_mapping/$n" --insecure -u elastic:$ELASTIC_PASSWORD -H 'Content-Type: application/json' -d"@$f"
done

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

echo "Bootstrap Execution complete."