#!/bin/bash
# Author : Ryan Ivis
# This config script will ask for a webhook and pass it to the ES nodes

echo "------------------------------------------------------------------------------ "
echo "Welcome to the Ping Identity ElasticSearch Slack Integration bootstrap process "
echo "Please Enter Your Slack Webhook Full URL ex. https://your.webhook.url/ "
echo ">> ---- Enter Now ----"
read SLACK_WEB_HOOK

if [[ $SLACK_WEB_HOOK != "" ]]; then
	echo "Loading Slack Webhook into ElasticSearch Keystore."
	docker exec es01 /bin/sh -c ". /usr/share/elasticsearch/bootstrap/keystore_bootstrap.sh $SLACK_WEB_HOOK"
	docker exec es02 /bin/sh -c ". /usr/share/elasticsearch/bootstrap/keystore_bootstrap.sh $SLACK_WEB_HOOK"
fi
