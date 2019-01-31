#!/bin/bash
cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared;pwd )
WS=$( cd ../../.. ; pwd )

# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingdirectory variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

if ! test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q)" ; then 
    docker container stop ${CONTAINER_NAME}
fi
