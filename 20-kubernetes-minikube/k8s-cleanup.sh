#!/usr/bin/env sh
set -x

cd "$( dirname "${0}" )" || exit 1
set -o allexport
. env_vars
set -o allexport

# Clean up anything from a prior run
kubectl delete configmaps,secrets,jobs,statefulsets,deployments,persistentvolumes,persistentvolumeclaims,services,pods \
  -l "app=pingdirectory" \
  --grace-period=0 \
  --force