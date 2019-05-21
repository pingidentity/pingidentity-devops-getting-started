#!/bin/sh 
SCRIPT_HOME=$(dirname $0)

source ./lib.sh

# Export environment variables
ENV_VARS_FILE="${SCRIPT_HOME}/env_vars"

set -o allexport
source "${ENV_VARS_FILE}"
set +o allexport

echo_header "Tearing down 
        namespace=${USER}
            label=app=ds-topology"

# Clean up anything from a prior run
kubectl delete configmaps,secrets,jobs,statefulsets,deployments,persistentvolumes,persistentvolumeclaims,services,pods \
  -l "app=ds-topology" \
  -n "${USER}" \
  --grace-period=0 --force
