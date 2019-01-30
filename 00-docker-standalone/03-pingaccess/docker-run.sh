#!/bin/bash -x
cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared ; pwd )
WS=$( cd ../../.. ; pwd )

# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingfederate variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

# server-profile root
SP_ROOT=$( cd ${WS}/server-profile/pingaccess ; pwd ) 

if ! test -d "${OUT_DIR}" ; then
	mkdir -p "${OUT_DIR}"
fi

if test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
	docker run -d \
		--network ${NETWORK_NAME} \
		-p ${PORT_ADMIN}:9000 \
		-p ${PORT_HTTPS}:443 \
		--name ${CONTAINER_NAME} \
		--volume ${SP_ROOT}:/opt/in \
		--volume ${OUT_DIR}:/opt/out \
		pingidentity/pingaccess
elif test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q )" ; then
	docker start ${CONTAINER_NAME}
else
	echo "Container ${CONTAINER_NAME} is already running"
fi

url="https://localhost:${PORT_ADMIN}/"	
echo For the admin console, go to ${url}
open ${url}

url="https://localhost:${PORT_ADMIN}/pa-admin-api/v3/api-docs/"
echo For the admin API swagger, go to ${url}
open ${url}