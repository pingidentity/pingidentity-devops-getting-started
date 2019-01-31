#!/bin/bash
cd $( dirname ${0} )
HERE=$( pwd )
THIS=$( basename ${0} )

usage ()
{
    cat <<END
    usage: ${THIS} <stack-name>
END
    exit 79
}

test -z "${1}" && usage

if ! test -z "$( docker stack ls --format '{{.Name}}' | grep ${1} )" ; then
    docker stack rm ${1}
    echo "Would you like to remove the runtime state of this stack at /tmp/Swarm/${1}? (y/n)"
    read answer
    answer=$( echo "${answer}" | tr [A-Z] [a-z] )
    case "${answer}" in
        y|yes)
            rm -rf /tmp/Swarm/${1}
            ;;
        *)
            ;;
    esac
fi
