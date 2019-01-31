#!/bin/bash
cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared;pwd )

# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingaccess variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

if ! test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q)" ; then 
    docker stop ${CONTAINER_NAME}
    docker container rm ${CONTAINER_NAME}
fi

for directory in "${RT_ROOT}/${CONTAINER_NAME}"; do 
    echo "Would you like to remove the input directory ${directory} ? (y/n)"
    read answer
    answer=$( echo "${answer}" | tr [A-Z] [a-z] )
    case "${answer}" in
        y|yes)
            test "${dirctory}" != "/" && rm -rf ${directory}
            ;;
        *)
            ;;
    esac
done
