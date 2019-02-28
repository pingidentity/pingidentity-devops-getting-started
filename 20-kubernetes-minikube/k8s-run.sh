#!/bin/bash
cd $( dirname ${0} )
SCRIPT_HOME=$( pwd )
set -o allexport
source env_vars
set +o allexport

source utils.sh

install_envsubst

# Generate topology file based on variables and number of replicas
WORKSPACE=/tmp/Kubernetes/pingdirectory
PD_SP=${WORKSPACE}/server-profile/
TOP_FILE=${PD_SP}/topology.json
mkdir -p ${PD_SP}

# clean up anything left from previous runs
sh k8s-cleanup.sh

# Create and label the config map for the server profile
# ds config map
kubectl create configmap server-profile-pingdirectory-kubernetes --from-file=${PD_SP}
kubectl label configmap server-profile-pingdirectory-kubernetes app=${PINGDIRECTORY_SET_NAME} 

# Create the pingdirectory topology
/tmp/envsubst < deployment.yaml.template > ${WORKSPACE}/deployment.yaml
kubectl apply -f ${WORKSPACE}/deployment.yaml