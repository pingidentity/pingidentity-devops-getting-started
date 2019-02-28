#!/bin/sh -x 
cd $( dirname $0 )
SCRIPT_HOME=$( pwd )
set -o allexport
source env_vars
set -o allexport

# Clean up anything from a prior run
kubectl delete configmaps,secrets,jobs,statefulsets,deployments,persistentvolumes,persistentvolumeclaims,services,pods \
  -l "app=${PINGDIRECTORY_SET_NAME}" \
  --grace-period=0 \
  --force