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

if ! test -z "$( docker stack ls --format '{{.Name}}' | grep ${STACK_NAME} )" ; then
    docker stack rm ${STACK_NAME}
fi

if test -d /tmp/Swarm/${STACK_NAME}; then
    echo -n "Would you like to remove the runtime state of this stack at /tmp/Swarm/${STACK_NAME} (y/n) ? "
    read answer
    answer=$( echo "${answer}" | tr [A-Z] [a-z] )
    case "${answer}" in
        y|yes)
            rm -rf /tmp/Swarm/${STACK_NAME}
            ;;
        *)
            ;;
    esac
fi
