#!/bin/sh
##########################################################################################
#
# This script helps to deploy pingdirectory across clusters
#
#   create      - creates pingdirectory in a cluster
##########################################################################################
TOOL_NAME=$( basename "${0}" )
cd "$( dirname "${0}" )" || exit 1


##########################################################################################
usage ()
{
    echo "$*"	

	cat <<USAGE

Usage: ${TOOL_NAME} OPERATION {options}
   where OPERATION in:
        create
        apply
        delete
        
   where options in:
        --cluster {cluster}  - Cluster name used to identify different env_vars.pingdirecory
                               files

        --context {context}  - Name of Kubernetes context.
                                  Defaults to current context: $(kubectx -c)

        -d,--dry-run            - Provides the commands

Example:
    ${TOOL_NAME} create --cluser us-east-2
USAGE
	exit 1
}


test -z "${1}" && usage

_operation=${1} && shift
_context=$(kubectx -c)
_dryRun=false
_envVars=env_vars.pingdirectory

while ! test -z "${1}" ; do
    case "${1}" in
        --cluster)
            shift
            _cluster=${1}
            _envClusterFile="${_envVars}.${_cluster}"
            test ! -f "${_envClusterFile}" && echo "Cannot find '${_envClusterFile}'" && usage
            cat ${_envVars}.multi-cluster ${_envClusterFile} > multi-cluster/${_envVars}
            ;;

        --context)
            shift
            _context=${1}
            ;;

        -d|--dry-run)
            _dryRun=true
            ;;

        *)
            usage
            ;;
    esac
    shift
done

# Validate OPERATION
case "${_operation}" in
    create|apply|delete)
        ;;
    *)
        echo "Uknown OPERATION"
        usage
        ;;
esac

test -z ${_cluster} && echo "Missing --cluster argument" && usage

echo "
##########################################################################################
# Multi-Cluster Helper Script
#
#                     OPERATION: ${_operation}
#                       DRY-RUN: ${_dryRun}
#              ENVIRONMENT FILE: ${_envClusterFile}
#                       CONTEXT: ${_context}
#"
grep -v "^#" ${_envClusterFile}
grep -v "^#" multi-cluster/${_envVars}
echo "
##########################################################################################"

_contextDir="multi-cluster"

test ! -d ${_contextDir} && echo "Missing multi-cluster directory '${_contextDir}'." && exit


_cmd="kustomize build multi-cluster | envsubst"
echo "Running:"

if test ${_dryRun} == true; then
    _cmd="${_cmd} > output-${_cluster}.yaml"
    echo "${_cmd}"
    eval "${_cmd}"
else
    _cmd="${_cmd} | kubectl ${_operation} -f - --context=${_context}"
    echo "${_cmd}"
    eval "${_cmd}"
fi

# Cleanupt temporary multi-cluster/env_vars.pingdirectory file
rm -rf multi-cluster/${_envVars}

