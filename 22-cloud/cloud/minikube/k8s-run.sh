#!/usr/bin/env sh
echo 
cd "$( dirname "${0}" )" || exit 1
set -o allexport
. env_vars
set +o allexport

${VERSBOE} && set -x

. utils.sh

# if envsubst is not present, we'll install it to /tmp
command -v envsubst >/dev/null || install_envsubst

# Generate topology file based on variables and number of replicas
WORKSPACE="/tmp/Kubernetes/pingdirectory"
PD_SP="${WORKSPACE}/server-profile/"
mkdir -p "${PD_SP}"

# clean up anything left from previous runs
sh k8s-cleanup.sh

# Create and label the config map for the server profile
# ds config map
# kubectl create configmap server-profile-pingdirectory-kubernetes --from-file=${PD_SP}
# kubectl label configmap server-profile-pingdirectory-kubernetes app=${PINGDIRECTORY_SET_NAME} 

# Create the pingdirectory topology
PATH=/tmp:${PATH}
envsubst < deployment.yaml.subst > "${WORKSPACE}/deployment.yaml"
kubectl apply -f "${WORKSPACE}/deployment.yaml"