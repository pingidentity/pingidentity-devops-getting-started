#!/bin/bash
cd $( dirname ${0} )
HERE=$( pwd )
THIS=$( basename ${0} )
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
    echo creating /tmp/Swarm/${stackName}/ping${p}
    mkdir -p /tmp/Swarm/${stackName}/ping${p}
done

echo docker stack deploy -c ${stackFile} ${stackName}
docker stack deploy -c ${stackFile} ${stackName}
