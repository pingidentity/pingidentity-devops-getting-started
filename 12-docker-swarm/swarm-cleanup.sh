#!/usr/bin/env sh
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

# shellcheck disable=2086
if ! test -z "$( docker stack ls --format '{{.Name}}' | grep ${STACK_NAME} )" ; then
    docker stack rm ${STACK_NAME}
fi

if test -d "/tmp/Swarm/${STACK_NAME}" ; then
    printf "Would you like to remove the runtime state of this stack at /tmp/Swarm/%s (y/n) ?" "${STACK_NAME}"
    read -r answer
    # shellcheck disable=2060
    answer=$( echo "${answer}" | tr [A-Z] [a-z] )
    case "${answer}" in
        y|yes)
            rm -rf "/tmp/Swarm/${STACK_NAME}"
            ;;
        *)
            ;;
    esac
fi
