#!/bin/sh
cd $( dirname ${0} )
HERE=$( pwd )
SHARED=$( cd ../FF-shared;pwd )

# load the shared variables
test -f "${SHARED}/env_vars" && source "${SHARED}/env_vars"

# load the pingdirectory variables
test -f "${HERE}/env_vars" && source "${HERE}/env_vars"

# prepare the docker network (something all our containers have to do)
test -f "${SHARED}/prepare-network.sh.fragment" && source "${SHARED}/prepare-network.sh.fragment"

# wipe the input dir
if ! test -z "${IN_DIR}" && ! test "${IN_DIR}" = "/" ; then 
	test -d "${IN_DIRE}" && rm -rf "${IN_DIR}"
fi
# prepare the Docker local volume mounts
mkdir -p "${IN_DIR}" "${OUT_DIR}"

# prepare the input data for the container
echo "${PASSWORD_ROOT}" > "${IN_DIR}/root-user-password"
echo "${PASSWORD_REPLICATION}" > "${IN_DIR}/admin-user-password"
# copy the file from the server profile into the input volume

OPTIONS="-d"
if test "${1}" = "--debug" ; then
	OPTIONS="-it --entrypoint /bin/sh"
fi

if test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
	docker run  \
		${OPTIONS} \
		--name ${CONTAINER_NAME} \
		--network ${NETWORK_NAME} \
		--publish ${PORT_LDAP}:389 \
		--publish ${PORT_LDAPS}:636 \
		--publish ${PORT_HTTPS}:443 \
		--env SERVER_PROFILE_URL=${SERVER_PROFILE_URL} \
		--env ROOT_USER_PASSWORD_FILE=/opt/in/root-user-password \
		--env ADMIN_USER_PASSWORD_FILE=/opt/in/admin-user-password \
		--volume ${IN_DIR}:/opt/in \
		--volume ${OUT_DIR}:/opt/out \
		pingidentity/pingdirectory
elif test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q )" ; then
	docker start ${CONTAINER_NAME}
else
	echo "Container ${CONTAINER_NAME} already running"
fi
echo
echo
echo For live logs, execute:
echo docker container logs -f ${CONTAINER_NAME}
echo
echo For a terminal into the container, execute:
echo docker container exec -it ${CONTAINER_NAME} /bin/sh
