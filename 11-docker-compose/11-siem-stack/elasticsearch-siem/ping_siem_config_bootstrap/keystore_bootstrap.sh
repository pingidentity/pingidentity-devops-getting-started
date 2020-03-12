#!/bin/bash
# Author: Ryan Ivis
# Configure Slack webhook into the elasticsearch
# keystore so watchers will fire correctly.

es_status="red"

if [[ $1 != "" ]]; then
	#Wait for ElasticSearch API to go Green before adding settings
	while [ "$es_status" != "green" ]
	do
	    echo "Waiting for Node Health to Go Green..."
	    sleep 3
	    health=$(curl -s -u elastic:$ELASTIC_PASSWORD --insecure https://localhost:9200/_cluster/health)
	    es_status=$(expr "$health" : '.*"status":"\([^"]*\)"')

	    if [[ "$es_status" == "green" ]]; then 
		  	echo "Load in Slack Settings to Keystore!"
			echo "$1" | bin/elasticsearch-keystore add --stdin xpack.notification.slack.account.monitoring.secure_url
			curl -s -u elastic:$ELASTIC_PASSWORD --insecure -X POST "https://localhost:9200/_nodes/reload_secure_settings?pretty"
    	fi
	done
fi