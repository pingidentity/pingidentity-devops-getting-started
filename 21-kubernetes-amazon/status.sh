#!/bin/bash
cd $( dirname ${0} )
SCRIPT_HOME=$( pwd )

source ./lib.sh

# Export environment variables
ENV_VARS_FILE=env_vars

set -o allexport
source "${ENV_VARS_FILE}"
set +o allexport

kubectl get all,pv,pvc,configmap,secret,endpoints \
 --show-labels \
 -o wide
