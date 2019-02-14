#!/bin/bash
CMD="${0}"
STACK_YAML_FILE="${1}"
cd $( dirname ${0} )
SCRIPT_NAME=$( basename ${0} )
STACK_NAME=${STACK_YAML_FILE%.*}

run ()
{
    echo $*
    $*
}
usage ()
{
    cat <<END

Usage: ${SCRIPT_NAME} <stack-name>

Example:

   ${SCRIPT_NAME} basic1

END
exit 79
}

test ! -f "${STACK_YAML_FILE}" && echo "Error: Stack yaml file '${STACK_YAML_FILE}' not found" && usage

for PRODUCT in access federate directory datasync ; do
    run mkdir -p /tmp/Swarm/${STACK_NAME}/ping${PRODUCT}
done

run docker stack deploy -c ${STACK_YAML_FILE} ${STACK_NAME}
