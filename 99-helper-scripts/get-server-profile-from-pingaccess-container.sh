#!/usr/bin/env sh
if test -z "${1}" ; then
    echo the first argument must be a container id
    exit 1
fi

if test -z "${2}" ; then
    echo "The second argument must the path to the server profile"
    exit 2
fi

if ! test -d "${2}" ; then
  echo the path to the server profile does not exist
  exit 3
fi

if ! test $(basename "${2}") = "instance" ; then
    echo "the server profile path should end with 'instance' (i.e. </path/to/pa-server-profile>/instance)"
    exit 4
fi
containerId="${1}"
serverPofilePath="${2}"

# check the container is live
if docker container ls --format '{{.ID}}' --filter id=${containerId} |grep "${containerId}" >/dev/null ; then 
    docker cp ${containerId}:/opt/out/instance/data/archive/latest.data.zip /tmp
    unzip -d "${serverPofilePath}" /tmp/latest.data.zip
else
    echo the provided container ID ${containerId} does not appear to be running locally
    exit 5
fi