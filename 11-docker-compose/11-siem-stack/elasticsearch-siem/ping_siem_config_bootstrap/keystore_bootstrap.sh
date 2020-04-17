#!/bin/bash
# Author: Ryan Ivis -- Ping Identity

# Configure Slack webhook into the elasticsearch
# keystore so watchers will fire correctly.
# This script is called by an external script and executes within the ES CONTAINERS directly. It loads in Slack Web Hook details into the elasticsearch Keystore.
# This script is executed manually, and can't be automated as you do not have the customers WEBHOOK url for slack.

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
			echo "$1" | bin/elasticsearch-keystore add -f --stdin xpack.notification.slack.account.monitoring.secure_url
			curl -s -u elastic:$ELASTIC_PASSWORD --insecure -X POST "https://localhost:9200/_nodes/reload_secure_settings?pretty"
    	fi
	done
fi