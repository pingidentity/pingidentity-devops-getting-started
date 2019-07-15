#!/bin/bash

# echo colorization options
RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
# BLUE_COLOR='\033[0;34m'
# PURPLE_COLOR='\033[0;35m'
NORMAL_COLOR='\033[0m'

# a function to echo a message in the color red
echo_red ()
{
    # shellcheck disable=SC2039
    echo -e "${RED_COLOR}$*${NORMAL_COLOR}"
}

# a function to echo a message in the color green
echo_green ()
{
    # shellcheck disable=SC2039
    echo -e "${GREEN_COLOR}$*${NORMAL_COLOR}"
}

# echo a header
echo_header()
{
  echo "##################################################################################"

  while (test ! -z "${1}")
  do
    _msg=${1} && shift

    echo "#   ${_msg}"
  done

  echo "##################################################################################"
}

# exit and print an error message
exit_error()
{
    echo_red "$*"
    exit 1
}

# exit, print an error message & usage
exit_usage()
{
    echo_red "$*"
    echo
    usage
    exit 1
}

# echo a message stdout and indent 4 spaces
echo_indent ()
{
    echo "${1}" | sed 's/^/    /'
}

# echo a header
echo_header()
{
  echo "##################################################################################"

  while (test ! -z "${1}")
  do
    _msg=${1} && shift

    echo "#    ${_msg}"
  done

  echo "##################################################################################"
}


#
create_namespace()
{
    test -z "${1}" && echo "Need a namespace passed" && exit
    namespace="${1}"

    namespaceFile="/tmp/k8s.namespace.${namespace}.yaml"

    echo "
apiVersion: v1
kind: Namespace
metadata:
  name: $USER
" >> "${namespaceFile}"

    res=$( kubectl apply -f "${namespaceFile}" )

    rm "${namespaceFile}"

    
    res=$( kubectl config set-context $(kubectl config current-context) --namespace ${namespace} )
}

#
echo_environment()
{
    k8sContext=$( kubectl config current-context )
    k8sNamespace=$( kubectl config view | grep namespace: | sed 's/.*namespace: //' )

    echo "
##################################################################################
#        Ping Identity DevOps Kubernetes Tool
#
#       Kubernetes Context: ${k8sContext}
#                Namespace: ${k8sNamespace}
##################################################################################
"
}
