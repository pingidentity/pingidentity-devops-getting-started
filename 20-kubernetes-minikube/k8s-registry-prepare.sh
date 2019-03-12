#!/usr/bin/env sh
usage ()
{
    cat <<END
usage: $( basename "${0}" ) registryIP:registryPort [tag]
END
    exit ${1:-76}
}

test ! -z "${VERBOSE}" && ${VERBOSE} && set -x

test -z "$( docker container ls --filter name=insecure-registry -q )" && docker run -d -p 5000:5000 --name insecure-registry registry && sleep 15

c=ping
p=${c}identity
# by default on virtualbox (which is the default driver for minikube)
registry=${1:-192.168.99.1:5000}
tag=${2:-ubuntu}
for i in access federate directory datasync ; do
    name=${c}${i}
    image=${p}/${name}:${tag}
    docker image tag ${image} ${registry}/${name}:${tag}
    docker push ${registry}/${name}:${tag}
done