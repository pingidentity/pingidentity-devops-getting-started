#!/bin/sh
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

if ! test -z "$(docker stack ls --filter name=${1} -q )" ; then
    docker stack rm ${1}
    echo you may want to remove the runtime state of this stack at /tmp/Swarm/${stackName}
    echo rm -rf /tmp/Swarm/${stackName}
fi