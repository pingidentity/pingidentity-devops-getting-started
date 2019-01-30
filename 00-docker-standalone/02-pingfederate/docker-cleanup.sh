#!/bin/bash
cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared;pwd )
WS=$( cd ../../.. ; pwd )
# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingdirectory variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

if ! test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q)" ; then 
    docker container rm ${CONTAINER_NAME}
fi

for directory in "${RT_ROOT}/${CONTAINER_NAME}"; do 
    echo "would you like to wipe the input directory ${directory} ? (y/n)"
    read answer
    answer=$( echo "${answer}" | tr [A-Z] [a-z] )
    case "${answer}" in
        y|yes)
            rm -rf ${directory}
            ;;
        *)
            ;;
    esac
done