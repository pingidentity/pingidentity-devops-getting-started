#!/bin/bash
STACK_YAML_FILE="${1}"
SCRIPT_NAME=$( basename "${0}" )
STACK_NAME=${STACK_YAML_FILE%.*}
cd "$( dirname "${0}" )" || exit 1

run ()
{
    echo $*
    $*
}
usage ()
{
    cat <<END

Usage: ${SCRIPT_NAME} <stack-name>.yaml

Example:

   ${SCRIPT_NAME} basic1.yaml

END
    exit 79
}

test ! -f "${STACK_YAML_FILE}" && echo "Error: Stack yaml file '${STACK_YAML_FILE}' not found" && usage

for PRODUCT in access federate directory datasync ; do
    run mkdir -p "/tmp/Swarm/${STACK_NAME}/ping${PRODUCT}"
done

# shellcheck disable=2086
run docker stack deploy -c "${STACK_YAML_FILE}" ${STACK_NAME}
