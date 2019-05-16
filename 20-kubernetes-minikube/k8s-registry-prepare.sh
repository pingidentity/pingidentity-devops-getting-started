#!/usr/bin/env sh
test ! -z "${VERBOSE}" && ${VERBOSE} && set -x

#
# Usage printing function
#
usage()
{
cat <<END_USAGE
Usage: $( basename "${0}" ) {options}
    where {options} include:

    -h, --hostname
        The hostname or ip address for the registry server.  
        Default is 192.168.99.1 (default from virtualbox)
    -p, --port
        The port for the registry server.
        Default is 5000
    -t, --tag
        The docker tag used from the local repository to push to the reistry
        Default is ubuntu
    --help
        Display general usage information
END_USAGE
exit 99
}

regHost=192.168.99.1
regPort=5000
repoTag="ubuntu"
#
# Parse the provided arguments, if any
#
while ! test -z "${1}" ; do
    case "${1}" in
        -h|--hostname)
            shift
            if test -z "${1}" ; then
                echo "You must provide a hostnam or ip address"
                usage
            fi
            regHost="${1}"
            ;;

        -p|--port)
            shift
            if test -z "${1}" ; then
                echo "You must provide a port"
                usage
            fi
            regPort="${1}"
            ;;

        -t|--tag)
            shift
            if test -z "${1}" ; then
                echo "You must provide a tag from local repo to push"
                usage
            fi
            repoTag="${1}"
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unrecognized option"
            usage
            ;;
    esac
    shift
done


test -z "$( docker container ls --filter name=insecure-registry -q )" && docker run -d -p 5000:5000 --name insecure-registry registry && sleep 15

c=ping
p=${c}identity
registry="${regHost}:${regPort}"

for i in access federate directory datasync ; do
    name=${c}${i}
    image=${p}/${name}:${repoTag}
    docker image tag ${image} "${registry}/${name}:${repoTag}"
    docker push "${registry}/${name}:${repoTag}"
done
