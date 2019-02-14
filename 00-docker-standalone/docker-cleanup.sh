#!/bin/sh
CMD="${0}"
CONTAINER="${1}"
FORCE="${2}"
CONTAINER_DIR=$(cd $( dirname ${0} );pwd )
SHARED_DIR=$( cd FF-shared;pwd )

function usage()
{
cat <<EO_USAGE

Usage: ${CMD} { container name } [ --force ]
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - runs all containers

             --force : Force Cleanup & Removal of IN/OUT directories

Examples

  Cleanup a standalone PingDirectory container

    ${CMD} pingdirectory

  Cleanup all containers and force the cleanup, no questions are asked

    ${CMD} all --force

EO_USAGE
}

run_cmd() {
        INSTANCE=$1

        echo "Running ${CMD} ${INSTANCE} ${FORCE}..."
        ${CMD} ${INSTANCE} ${FORCE}
}

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
		run_cmd pingdirectory
		run_cmd pingfederate
		run_cmd pingaccess
		run_cmd pingdataconsole
		;;
	*)
		usage
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
    if ! test -z ${directory}; then
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
    fi
done
