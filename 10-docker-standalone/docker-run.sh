#!/usr/bin/env sh
CMD="$( basename "${0}" )"
CONTAINER="${1}"
DEBUG="${2}"
cd "$( dirname "${0}" )"
CONTAINER_DIR=$( pwd )
SHARED_DIR=$( cd FF-shared && pwd )
DEVOPS_PROPS="${HOME}/.pingidentity/devops"

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
    ./${CMD} "${INSTANCE}"
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

# load the devops variables
#shellcheck source=/dev/null
test -f "${DEVOPS_PROPS}" && . "${DEVOPS_PROPS}"

# lood the shared variables
#shellcheck source=/dev/null
test -f "${SHARED_DIR}/env_vars" && . "${SHARED_DIR}/env_vars"

# load the pingdirectory variables
#shellcheck source=/dev/null
test -f "${CONTAINER_DIR}/env_vars" && . "${CONTAINER_DIR}/env_vars"

# prepare the docker network (something all our containers have to do)
#shellcheck source=FF-shared/prepare-network.sh.fragment
test -f "${SHARED_DIR}/prepare-network.sh.fragment" && . "${SHARED_DIR}/prepare-network.sh.fragment"

# Docker Image that will be run
DOCKER_IMAGE="pingidentity/${CONTAINER_NAME}:${PING_IDENTITY_DEVOPS_TAG:-edge}"

# check to see if the debug option is passed
SHARED_DOCKER_OPTIONS=" --detach " 
if test "${DEBUG}" = "--debug" ; then
    SHARED_DOCKER_OPTIONS=" -it --entrypoint /bin/sh "
fi

echo "
###########################################################
#         Docker Environment Variables
#    
#              DOCKER_IMAGE : ${DOCKER_IMAGE}
#              NETWORK_NAME : ${NETWORK_NAME}
#        SERVER_PROFILE_URL : ${SERVER_PROFILE_URL}
#       SERVER_PROFILE_PATH : ${SERVER_PROFILE_PATH}
#     SERVER_PROFILE_BRANCH : ${SERVER_PROFILE_BRACH}
#    
#                    IN_DIR : ${IN_DIR}
#                   OUT_DIR : ${OUT_DIR}
#
#   (Following items are set using 'setup' command)
#
# PING_IDENTITY_DEVOPS_USER : ${PING_IDENTITY_DEVOPS_USER}
#  PING_IDENTITY_DEVOPS_TAG : ${PING_IDENTITY_DEVOPS_TAG}
#    
###########################################################
"

SHARED_DOCKER_OPTIONS="
        ${SHARED_DOCKER_OPTIONS} 
        --name ${CONTAINER_NAME} 
        --network ${NETWORK_NAME} 
"

if test -f ${DEVOPS_PROPS} ; then
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env-file ${DEVOPS_PROPS} "
fi

if ! test -z "${SERVER_PROFILE_URL}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env SERVER_PROFILE_URL=${SERVER_PROFILE_URL} "
fi

if ! test -z "${SERVER_PROFILE_BRANCH}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env SERVER_PROFILE_BRANCH=${SERVER_PROFILE_BRANCH} "
fi

if ! test -z "${SERVER_PROFILE_PATH}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env SERVER_PROFILE_PATH=${SERVER_PROFILE_PATH} "
fi

if ! test -z "${PING_IDENTITY_DEVOPS_USER}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env PING_IDENTITY_DEVOPS_USER=${PING_IDENTITY_DEVOPS_USER} "
fi

if ! test -z "${PING_IDENTITY_DEVOPS_KEY}" ; then 
    SHARED_DOCKER_OPTIONS="${SHARED_DOCKER_OPTIONS}  --env PING_IDENTITY_DEVOPS_KEY=${PING_IDENTITY_DEVOPS_KEY} "
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
if test -z "$(docker container ls -a --filter name=^${CONTAINER_NAME}$ -q )" ; then
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
