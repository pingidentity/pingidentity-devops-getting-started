#!/bin/bash

numTools=0
numOk=0
numMissing=0

# function to check for the existence of a tool command
check_tool()
{
    toolName="${1}" && shift
    #toolCmd="${1}" && shift
    toolMsg="${1}" && shift
    
    numTools=$((numTools + 1))
    #${toolCmd} 2>/dev/null >/dev/null
    command -v "${toolName}" &>/dev/null
    RESULT=$?

    pad=$(printf '%0.1s' "."{1..80})
    printf "%s" "${toolName}"
    printf "%*.*s" 0 $((72-${#toolName}-3)) "${pad}"

    #if [ "${RESULT}" == "127" ]; then
    if test ${RESULT} -ne 0; then
        echo -e "[ ${RED}MISSING${NC} ]"
        echo "INFO: ${toolMsg}" | sed 's/^/      /'
        echo ""
        numMissing=$((numMissing + 1))
    else
        echo -e "[   ${GREEN}OK${NC}    ]"
        numOk=$((numOk + 1))
    fi
}


################################################################################
# get_value (variable)
#
# Get the value of a vaiable, preserving the spaces
################################################################################
get_value ()
{
    IFS="%%"
    eval printf '%s' "\${${1}}"
    unset IFS
}

################################################################################
# add_bash_aliases
#
# Ensure that the bash_alias file is a part of .bash_profile
################################################################################
add_bash_aliases()
{

    echo "
################################################################################
#                         Ping Identity DevOps Alias Files
################################################################################"

    # Touch the .bash_profile incase it's not setup yet
    BASH_PROFILE="${HOME}/.bash_profile"

    touch "${BASH_PROFILE}"

    grep "bash_profile_devops" "${BASH_PROFILE}" > /dev/null

    if test "${?}" == "1"; then
        echo "Let's add helper alias' and functions to your shell.  
We are assuming you use bash and will add these to your ${BASH_PROFILE}
"

        echo -n "  OK if we add a 'source bash_profile_devops' command to your ${BASH_PROFILE} (y/n) [y] ? "
        read answer

        if [ "${answer}" == "" ] || [ "${answer}" == "Y" ] || [ "${answer}" == "y" ]; then
            echo "
# Ping Identity DevOps Aliases - Added with setup on `date`
source ${THIS_DIR}/bash_profile_devops" >> "${BASH_PROFILE}"
        fi
    else
        echo_green "  Great! You already have 'source bash_profile_devops' in your ${BASH_PROFILE}"
    fi

    grep "sourcePingIdentityFiles" "${BASH_PROFILE}" >/dev/null

    if test "$?" = "1"; then
        echo -n "  OK if we add a 'sourcePingIdentityFiles' command to your ${BASH_PROFILE} (y/n) [y] ? "
        read answer
        if [ "${answer}" == "" ] || [ "${answer}" == "Y" ] || [ "${answer}" == "y" ]; then
            echo "
# Source PingIdentity Files Alias - Added with setup on `date`
sourcePingIdentityFiles" >> "${BASH_PROFILE}"
        fi
    else
        echo_green "  Great! You already have 'sourcePingIdentityFiles' in your ${BASH_PROFILE}"
    fi
}

################################################################################
# devops_add_config (file, variable, default, prompt)
#
# Add a config variale to the devops file
################################################################################
function devops_add_config()
{
  PROPS_FILE="${1}" && shift
  VAR_TO_SET="${1}" && shift
  VAR_DEFAULT="${1}" && shift
  VAR_PROMPT="${*}"

  CURRENT_VALUE=$(get_value ${VAR_TO_SET})
  test -z "${CURRENT_VALUE}" && CURRENT_VALUE="${VAR_DEFAULT}"

  echo -n "${VAR_PROMPT} [${CURRENT_VALUE}] ? "
  read answer
  if test ! -z "${answer}"; then
    if test "${answer}" = "-"; then
      eval "unset \${VAR_TO_SET}"
      echo "${VAR_TO_SET}=" >> ${PROPS_FILE}
    else
      eval "export \${VAR_TO_SET}=${answer}"
      echo "${VAR_TO_SET}=${answer}" >> ${PROPS_FILE}
    fi
  else
    echo "${VAR_TO_SET}=${CURRENT_VALUE}" >> ${PROPS_FILE}
  fi
}

################################################################################
# devops_add_comment (file, message)
#
# Add a comment to the devops file
################################################################################
function devops_add_comment()
{
  _TFILE="${1}" && shift
  _MSG="${@}"

  echo ${_MSG}
  echo ${_MSG} >> ${_TFILE}
}




RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo_red()
{
    echo -e "${RED}$*${NC}"
}

echo_green()
{
    echo -e "${GREEN}$*${NC}"
}

