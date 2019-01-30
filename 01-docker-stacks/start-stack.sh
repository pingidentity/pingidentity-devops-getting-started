#!/bin/bash
cd $( dirname ${0} )
HERE=$( pwd )
THIS=$( basename ${0} )
run ()
{
    echo $*
    $*
}
usage ()
{
    cat <<END
usage: ${THIS} <stack-name>.yaml
END
exit 79
}

stackFile="${1}"
stackName=${stackFile%.*}

test -z "${1}" && usage
for p in access federate directory sync ; do
    run mkdir -p /tmp/Swarm/${stackName}/ping${p}
done

run docker swarm init
run docker stack deploy -c ${stackFile} ${stackName}
