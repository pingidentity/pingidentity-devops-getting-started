#!/bin/sh
cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared ; pwd )

# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingfederate variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

# prepare the docker network (something all our containers have to do)
test -f "${SHARED}/prepare-network.sh.fragment" && source "${SHARED}/prepare-network.sh.fragment"


CONTAINER_NAME=pingdataconsole
if test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q)" ; then
	if test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q)" ; then
		docker run -d --network ${NETWORK_NAME} -p 8080:8080 --name pingdataconsole pingidentity/pingdataconsole
	else
		docker start ${CONTAINER_NAME}
	fi
	sleep 15
else
	echo "Container ${CONTAINER_NAME} already running"
fi
open http://localhost:8080/admin-console