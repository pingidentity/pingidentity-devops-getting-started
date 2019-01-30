#!/bin/bash -x
cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared ; pwd )

# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingfederate variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

# prepare the docker network (something all our containers have to do)
test -f "${SHARED}/prepare-network.sh.fragment" && source "${SHARED}/prepare-network.sh.fragment"

if ! test -d "${OUT_DIR}" ; then
	mkdir -p "${OUT_DIR}"
fi

if test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
	docker run -d \
		--network ${NETWORK_NAME} \
		-p ${PORT_HTTP}:9031 \
		-p ${PORT_ADMIN}:9999 \
		--name ${CONTAINER_NAME} \
		--env SERVER_PROFILE_URL=${SERVER_PROFILE_URL} \
		--volume ${OUT_DIR}:/opt/out \
		pingidentity/pingfederate
	sleep 30
elif test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q )" ; then
	docker start ${CONTAINER_NAME}
	sleep 15
else
	echo "Container ${CONTAINER_NAME} is already running"
fi
	
open https://localhost:${PORT_ADMIN}/pingfederate/app
