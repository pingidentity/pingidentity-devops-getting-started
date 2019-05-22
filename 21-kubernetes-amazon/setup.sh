#!/bin/bash
cd $( dirname ${0} )
SCRIPT_HOME=$( pwd )

source ./lib.sh

set -o allexport
source "./env_vars"
set +o allexport

kubectl_apply "fullstack/namespace.yaml"    "Making namesapce ${USER}"

kubectl config set-context $(kubectl config current-context) --namespace ${USER}

# Cleanup before we start - make sure start from clean slate
sh teardown.sh

kubectl_apply "fullstack/pingdataconsole.yaml"          "Creating PingDataConsole"
kubectl_apply "fullstack/pingdirectory.yaml"            "Creating PingDirectory"
kubectl_apply "fullstack/pingfederate_admin.yaml"       "Creating PingFederate-Admin"
kubectl_apply "fullstack/pingfederate_engine.yaml"      "Creating PingFederate-Engine"
kubectl_apply "fullstack/pingaccess.yaml"               "Creating PingAccess"

echo_header "Getting Everything"

kubectl get all,pv,pvc,configmap,secret,endpoints \
 --show-labels \
 -o wide

