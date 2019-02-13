#!/bin/bash
CONTAINER="${1}"
FORCE="${2}"
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
		$0 pingdirectory   ${FORCE}
		$0 pingfederate    ${FORCE}
		$0 pingaccess      ${FORCE}
		$0 pingdataconsole ${FORCE}
		;;
	*)
		echo "Usage: ${0} { container name } [ --force ]"
		echo
		echo "	container_name: pingdirectory"
		echo "	                pingfederate"
		echo "	                pingaccess"
		echo "	                pingdataconsole"
		echo "	                all - performs cleanup of all containers"
		echo
		echo "	      --force : Force Cleanup & Removal of IN/OUT directories"
		echo
		exit
esac

# load the shared variables
test -f "${SHARED_DIR}/env_vars" && source "${SHARED_DIR}/env_vars"

# load the pingdirectory variables
test -f "${CONTAINER_DIR}/env_vars" && source "${CONTAINER_DIR}/env_vars"

if ! test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q)" ; then 
    docker container rm ${CONTAINER_NAME} ${FORCE}
fi

for directory in "${IN_DIR}" "${OUT_DIR}" "${RT_ROOT}/${CONTAINER_NAME}"; do 
    if [ "${FORCE}" == "--force" ]; then
       rm -rf ${directory}
    else
       echo -n "Would you like to remove the input directory ${directory} (y/n) ? "
       read answer
       answer=$( echo "${answer}" | tr [A-Z] [a-z] )
       case "${answer}" in
           y|yes)
               rm -rf ${directory}
               ;;
           *)
               ;;
       esac
    fi
done
