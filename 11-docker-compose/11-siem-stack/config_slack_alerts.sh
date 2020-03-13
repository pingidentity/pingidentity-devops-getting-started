#!/bin/bash
# Author : Ryan Ivis
# This config script will ask for a webhook and pass it to the ES nodes

echo "------------------------------------------------------------------------------ "
echo "Welcome to the Ping Identity ElasticSearch Slack Integration bootstrap process "
echo "Please Enter Your Slack Webhook Full URL ex. https://your.webhook.url/ "
echo "---- Enter Now (Or leave blank to avoid updating the exiting configuration---- "
read -p "Enter Slack Webhook URL: " SLACK_WEB_HOOK

if [[ $SLACK_WEB_HOOK != "" ]]; then
	echo "Loading Slack Webhook into ElasticSearch Keystore."
	docker exec es01 /bin/sh -c ". /usr/share/elasticsearch/bootstrap/keystore_bootstrap.sh $SLACK_WEB_HOOK"
	docker exec es02 /bin/sh -c ". /usr/share/elasticsearch/bootstrap/keystore_bootstrap.sh $SLACK_WEB_HOOK"
fi

echo "------------------------------------------------------------------------------ "
echo "Please Enter Your 'elastic' user password, this is used to load watchers...  "
echo "---- Enter Now ----"
read -s -p "Enter 'elastic' password :" EP

if [[ $EP != "" ]]; then
	echo "Load in ElasticSearch Watchers"
	sleep 5
	#Loading Saved Watchers
	for f in ./elasticsearch-siem/watchers/*.json
	do	
	  echo "Processing watcher file (full path) $f "
	  echo "start"
	  fn=$(basename $f)
	  n="${fn%.*}"

	  echo "Processing file name $n "
	  curl -X PUT "https://localhost:9201/_watcher/watch/$n?pretty" --insecure -u elastic:$EP  -H 'Content-Type: application/json' -d"@$f"
	done
fi