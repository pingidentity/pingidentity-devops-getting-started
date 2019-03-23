#!/usr/bin/env sh
CMD="$( basename "${0}" )"
CONTAINER="${1}"
FORCE="${2}"
cd "$( dirname "${0}" )"
CONTAINER_DIR=$( pwd )
SHARED_DIR=$( cd FF-shared && pwd )

usage()
{
cat <<EO_USAGE

Usage: ${CMD} { container name } [ --force ]
       container_name: pingdirectory
                       pingfederate
                       pingaccess
                       pingdataconsole
                       all - cleanup all containers

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
        ./${CMD} "${INSTANCE}" "${FORCE}"
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

# load the shared variables
#shellcheck source=/dev/null
test -f "${SHARED_DIR}/env_vars" && . "${SHARED_DIR}/env_vars"

# load the pingdirectory variables
#shellcheck source=/dev/null
test -f "${CONTAINER_DIR}/env_vars" && . "${CONTAINER_DIR}/env_vars"

# shellcheck disable=2086
if ! test -z "$(docker container ls -a --filter name=${CONTAINER_NAME} -q)" ; then 
    docker container rm "${CONTAINER_NAME}" "${FORCE}"
fi

for directory in "${IN_DIR}" "${OUT_DIR}" "${RT_ROOT}/${CONTAINER_NAME}"; do 
    if ! test -z "${directory}" ; then
       if test "${FORCE}" = "--force" ; then
          rm -rf "${directory}"
       else
         printf "Would you like to remove the input directory %s (y/n) ? " "${directory}"
         read -r answer
         # shellcheck disable=2060
         answer=$( echo "${answer}" | tr [A-Z] [a-z] )
         case "${answer}" in
             y|yes)
                 rm -rf "${directory}"
                 ;;
             *)
                 ;;
         esac
       fi
    fi
done
