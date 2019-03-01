#!/usr/bin/env sh
CMD="${0}"
CONTAINER="${1}"
DEBUG="${2}"
CONTAINER_DIR=$(cd "$( dirname "${0}" )" && pwd )
SHARED_DIR=$( cd FF-shared && pwd )

usage()
{
cat <<EO_USAGE

Usage: ${CMD} { container name } [ --debug ]
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - runs all containers

             --debug : Provide debugging details and drop into container shell
                       This option is not used in conjunction with all
Examples

  Run a standalone PingDirectory container

    ${CMD} pingdirectory

  Run a standalone PingFederate container, with debug.  This will start the container
  and drop the user into the container shell, rather than installing/running the 
  PingFederate instance

    ${CMD} pingfederate --debug

EO_USAGE
}

run_cmd() {
    INSTANCE="${1}"

    echo "Running ${CMD} ${INSTANCE}..."
    ${CMD} "${INSTANCE}"
}

case ${CONTAINER} in
    "pingdirectory")
        CONTAINER_DIR="${CONTAINER_DIR}/01-pingdirectory"
        ;;
    "pingfederate")
        CONTAINER_DIR="${CONTAINER_DIR}/02-pingfederate"
        ;;
    "pingaccess")
        CONTAINER_DIR="${CONTAINER_DIR}/03-pingaccess"
        ;;
    "pingdataconsole")
        CONTAINER_DIR="${CONTAINER_DIR}/10-pingdataconsole"
        ;;
    "all")
        run_cmd pingdirectory
        run_cmd pingfederate
        run_cmd pingaccess
        run_cmd pingdataconsole
        ;;
    *)
        usage
        exit
esac
    
# lood the shared variables
#shellcheck source=/dev/null
test -f "${SHARED_DIR}/env_vars" && . "${SHARED_DIR}/env_vars"

# load the pingdirectory variables
#shellcheck source=/dev/null
test -f "${CONTAINER_DIR}/env_vars" && . "${CONTAINER_DIR}/env_vars"

# prepare the docker network (something all our containers have to do)
#shellcheck source=FF-shared/prepare-network.sh.fragment
test -f "${SHARED_DIR}/prepare-network.sh.fragment" && . "${SHARED_DIR}/prepare-network.sh.fragment"

# wipe the input dir
# if ! test -z "${IN_DIR}" && ! test "${IN_DIR}" = "/" ; then 
#     test -d "${IN_DIRE}" && rm -rf "${IN_DIR}"
# fi

# Docker Imange that will be run
DOCKER_IMAGE="pingidentity/${CONTAINER_NAME}"

# check to see if the -d option is passed
SHARED_DOCKER_OPTIONS=" --detach " 
if test "${DEBUG}" = "--debug" ; then
    SHARED_DOCKER_OPTIONS=" -it --entrypoint /bin/sh "

    echo "###########################################################"
    echo "#         Docker Environment Variables"
    echo "#    "
    echo "#        CONTAINER_NAME : ${CONTAINER_NAME}"
    echo "#          NETWORK_NAME : ${NETWORK_NAME}"
    echo "#    SERVER_PROFILE_URL : ${SERVER_PROFILE_URL}"
    echo "# SERVER_PROFILE_BRANCH : ${SERVER_PROFILE_BRANCH}"
    echo "#   SERVER_PROFILE_PATH : ${SERVER_PROFILE_PATH}"
    echo "#          DOCKER_IMAGE : ${DOCKER_IMAGE}"
    echo "#    "
    echo "#                IN_DIR : ${IN_DIR}"
    echo "#               OUT_DIR : ${OUT_DIR}"
    echo "#    "
    echo "###########################################################"
fi

SHARED_DOCKER_OPTIONS="
        ${SHARED_DOCKER_OPTIONS} 
        --name ${CONTAINER_NAME} 
        --network ${NETWORK_NAME} 
"

if ! test -z "${SERVER_PROFILE_URL}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env SERVER_PROFILE_URL=${SERVER_PROFILE_URL} "
fi

if ! test -z "${SERVER_PROFILE_BRANCH}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env SERVER_PROFILE_BRANCH=${SERVER_PROFILE_BRANCH} "
fi

if ! test -z "${SERVER_PROFILE_PATH}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env SERVER_PROFILE_PATH=${SERVER_PROFILE_PATH} "
fi

if ! test -z "${IN_DIR}" ; then 
    mkdir -p "${IN_DIR}" 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --volume ${IN_DIR}:/opt/in "
fi

if ! test -z "${OUT_DIR}" ; then 
    mkdir -p "${OUT_DIR}" 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS} --volume ${OUT_DIR}:/opt/out "
fi

# pull, run or start the container
# shellcheck disable=2086
if test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q )" ; then
    docker pull "${DOCKER_IMAGE}"

    docker run  \
        ${DOCKER_OPTIONS} \
        ${SHARED_DOCKER_OPTIONS} \
        ${DOCKER_IMAGE}

elif test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q )" ; then
    docker start "${CONTAINER_NAME}"
else
    echo "Container ${CONTAINER_NAME} already running"
fi

echo "
# For live logs, execute:

docker container logs -f ${CONTAINER_NAME}

# For a terminal into the container, execute:

docker container exec -it ${CONTAINER_NAME} /bin/sh

${POST_INSTRUCTIONS}
"
