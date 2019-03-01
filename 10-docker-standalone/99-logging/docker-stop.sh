#!/usr/bin/env sh
set -x

# shellcheck disable=2046
cd $( dirname "${0}" ) || exit 1

# shellcheck disable=2164
SHARED=$( cd ../FF-shared;pwd )

# load the shared variables
# shellcheck source=../FF-shared/env_vars
test -f "${SHARED}/env_vars" && . "${SHARED}/env_vars"

for container in logspout logstash kibana elasticsearch stash_config ; do
    if ! test -z "$( docker container ls -q --filter name=${container} )" ; then
        docker container stop ${container}
    fi
    if ! test -z "$( docker container ls -a -q --filter name=${container} )" ; then
        docker container rm ${container}
    fi
done
