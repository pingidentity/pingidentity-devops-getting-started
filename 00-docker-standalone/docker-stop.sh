#!/bin/bash
CONTAINER="${1}"
CONTAINER_DIR=$(cd $( dirname ${0} );pwd )
SHARED_DIR=$( cd FF-shared;pwd )

case ${CONTAINER} in
	"pingdirectory")
		CONTAINER_DIR+="/01-pingdirectory"
		;;
	"pingfederate")
		CONTAINER_DIR+="/02-pingfederate"
		;;
	"pingaccess")
		CONTAINER_DIR+="/03-pingaccess"
		;;
	"pingdataconsole")
		CONTAINER_DIR+="/10-pingdataconsole"
		;;
	"all")
		$0 pingdirectory
		$0 pingfederate
		$0 pingaccess
		$0 pingdataconsole
		;;
	*)
		echo "Usage: ${0} { container name }"
		echo
		echo "	container_name: pingdirectory"
		echo "	                pingfederate"
		echo "	                pingaccess"
		echo "	                pingdataconsole"
		echo "	                all - stops all containers"
		echo
		exit
esac

# load the shared variables
test -f "${SHARED_DIR}/env_vars" && source "${SHARED_DIR}/env_vars"

# load the pingdirectory variables
test -f "${CONTAINER_DIR}/env_vars" && source "${CONTAINER_DIR}/env_vars"

if ! test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q)" ; then 
    docker container rm ${CONTAINER_NAME} -f
fi

if ! test -z "$(docker container ls --filter name=${CONTAINER_NAME} -q)" ; then 
    docker container stop ${CONTAINER_NAME}
fi
