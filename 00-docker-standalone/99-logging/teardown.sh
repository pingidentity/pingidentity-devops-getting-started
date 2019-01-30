#!/bin/bash -x

cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared;pwd )
WS=$( cd ../../.. ; pwd )
# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingdirectory variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

# prepare the docker network (something all our containers have to do)
test -f "${SHARED}/prepare-network.sh.fragment" && source "${SHARED}/prepare-network.sh.fragment"

for container in logspout logstash kibana elasticsearch stash_config ; do
    if ! test -z "$( docker container ls -q --filter name=${container} )" ; then
        docker container stop ${container}
    fi
    if ! test -z "$( docker container ls -a -q --filter name=${container} )" ; then
        docker container rm ${container}
    fi
done
