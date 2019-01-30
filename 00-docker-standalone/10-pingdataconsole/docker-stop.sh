#!/bin/bash
cd $( dirname ${0} )
HERE=$( pwd )
WS=$( cd ../.. ; pwd )
CONTAINER_NAME=pingdataconsole

if ! test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q)" ; then 
    docker container stop ${CONTAINER_NAME}
fi
