#!/usr/bin/env sh
test ! -z "${VERBOSE}" && ${VERBOSE} && set -x

usage ()
{
    cat <<END
usage: $( basename "${0}" ) [options]
    --vmware
    --memory integer in megabytes
END
    exit ${1:-76}
}

cd "$( dirname "${0}" )" || usage 77

test -f env_vars && . env_vars

memory="4096"
# default uses virtualbox
driver=""
while test ! -z "$@" ; do 
    case "${1}" in
        --vmware)
            driver="--vm-driver vmwarefusion"
            shift
            ;;
        --memory)
            shift
            if test ! -z "${1}" ; then
                memory=${1}
            else
                usage 78
            fi
            shift
            ;;
        *)
            usage 79
    esac
done

minikube start ${driver}  --memory ${memory} --insecure-registry ${REGISTRY%/} --alsologtostderr