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

    echo "#    ${_msg}"
  done

  echo "##################################################################################"
}

# exit and print an error message
exit_error()
{
    echo_red "$*"
    exit 1
}


kubectl_apply()
{
    _yaml="${1}" && shift
    _msg="${1}"

    test ! -f ${_yaml} && exit_error "File '${_yaml}' not found"

    echo_header "${_msg}"

    envsubst < "${_yaml}" > "${_yaml}.tmp"
    kubectl apply -f "${_yaml}.tmp"

    rm "${_yaml}.tmp"
}
